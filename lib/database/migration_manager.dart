import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/file_manager.dart';
import 'migrations/001_initial_schema.dart';
import 'migrations/002_add_indexes.dart';

abstract class Migration {
  final int version;
  final String description;

  Migration(this.version, this.description);

  Future<void> up(SupabaseClient client);
  Future<void> down(SupabaseClient client);
}

class MigrationManager {
  final SupabaseClient _client;
  final FileManager _fileManager = FileManager.instance;
  final List<Migration> _migrations = [
    InitialSchemaMigration(),
    AddIndexesMigration(),
    // Añadir nuevas migraciones aquí
  ];

  MigrationManager(this._client);

  Future<void> initialize() async {
    try {
      // Crear tabla de control de migraciones si no existe
      await _createMigrationTable();
      await _fileManager.writeToLog(
          '[Migration] Created migration control table if not exists\n');

      // Obtener la última versión aplicada
      final currentVersion = await _getCurrentVersion();
      await _fileManager.writeToLog(
          '[Migration] Current database version: $currentVersion\n');

      // Aplicar migraciones pendientes
      for (var migration in _migrations) {
        if (migration.version > currentVersion) {
          try {
            await _fileManager.writeToLog(
                '[Migration] Applying migration ${migration.version}: ${migration.description}\n');

            await migration.up(_client);
            await _updateVersion(migration.version);

            await _fileManager.writeToLog(
                '[Migration] Successfully applied migration ${migration.version}\n');
          } catch (e) {
            await _fileManager.writeToLog(
                '[Migration] Error applying migration ${migration.version}: $e\n');

            await _fileManager.writeToLog(
                '[Migration] Attempting rollback of migration ${migration.version}\n');

            try {
              await migration.down(_client);
              await _fileManager.writeToLog(
                  '[Migration] Successfully rolled back migration ${migration.version}\n');
            } catch (rollbackError) {
              await _fileManager.writeToLog(
                  '[Migration] Error during rollback of migration ${migration.version}: $rollbackError\n');
            }
            rethrow;
          }
        }
      }

      await _fileManager
          .writeToLog('[Migration] Database initialization completed\n');
    } catch (e) {
      await _fileManager.writeToLog(
          '[Migration] Fatal error during database initialization: $e\n');
      rethrow;
    }
  }

  Future<void> _createMigrationTable() async {
    await _client.rpc('create_migration_table_if_not_exists', params: {
      'query': '''
        CREATE TABLE IF NOT EXISTS schema_migrations (
          version INT PRIMARY KEY,
          applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
      '''
    });
  }

  Future<int> _getCurrentVersion() async {
    final response = await _client
        .from('schema_migrations')
        .select('version')
        .order('version', ascending: false)
        .limit(1)
        .maybeSingle();

    return response != null ? response['version'] as int : 0;
  }

  Future<void> _updateVersion(int version) async {
    await _client.from('schema_migrations').insert({
      'version': version,
    });
  }
}
