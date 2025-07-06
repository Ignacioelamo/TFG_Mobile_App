import '../../database/migration_manager.dart';
import '../../models/file_manager.dart';
import 'supabase_service.dart';

/// Servicio encargado de la gestión de las migraciones de la base de datos
class MigrationService {
  /// Inicializa y ejecuta las migraciones de la base de datos
  static Future<bool> initialize() async {
    try {
      final migrationManager = MigrationManager(SupabaseService.client);
      await migrationManager.initialize();
      await FileManager.instance.writeToLog(
          "[Migration] Migraciones de base de datos inicializadas\n");
      return true;
    } catch (e) {
      await FileManager.instance
          .writeToLog("[Migration] Error al inicializar las migraciones: $e\n");
      print("Error al inicializar las migraciones: $e");
      return false;
    }
  }
}
