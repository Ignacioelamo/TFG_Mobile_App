import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_config.dart';
import '../../models/file_manager.dart';
import '../../database/migration_manager.dart';
import '../../injection_container.dart' as di;
import '../services/device_registration_service.dart';

/// Clase responsable de inicializar todos los componentes de la aplicación
class AppInitializer {
  /// Inicializa todos los componentes de la aplicación en el orden correcto
  static Future<void> initialize() async {
    // Asegurar que los bindings de Flutter estén inicializados
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializar sistema de logs
    await _initializeLogs();

    // Inicializar Supabase
    await _initializeSupabase();

    // Inicializar contenedor de inyección de dependencias
    await _initializeDependencyInjection();

    // Registrar el dispositivo
    await DeviceRegistrationService.registerDevice();

    // Inicializar migraciones de base de datos
    await _initializeDatabaseMigrations();
  }

  /// Inicializa el sistema de logs
  static Future<void> _initializeLogs() async {
    try {
      await FileManager.instance.createFile(AppConfig.logFileName);
      await FileManager.instance.writeToLog("[App] Iniciando aplicación\n");
    } catch (e) {
      print("Error al inicializar archivo de logs: $e");
    }
  }

  /// Inicializa la conexión con Supabase
  static Future<void> _initializeSupabase() async {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      await FileManager.instance
          .writeToLog("[App] Supabase inicializado correctamente\n");
    } catch (e) {
      await FileManager.instance
          .writeToLog("[App] Error al inicializar Supabase: $e\n");
      print("Error al inicializar Supabase: $e");
    }
  }

  /// Inicializa el contenedor de inyección de dependencias
  static Future<void> _initializeDependencyInjection() async {
    await di.init();
    await FileManager.instance.writeToLog(
        "[App] Contenedor de inyección de dependencias inicializado\n");
  }

  /// Inicializa las migraciones de la base de datos
  static Future<void> _initializeDatabaseMigrations() async {
    final migrationManager = MigrationManager(Supabase.instance.client);
    await migrationManager.initialize();
    await FileManager.instance
        .writeToLog("[App] Migraciones de base de datos inicializadas\n");
  }
}
