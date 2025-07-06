import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/file_manager.dart';
import '../services/device_registration_service.dart';
import '../services/dependency_injection_service.dart';
import '../services/migration_service.dart';
import '../services/supabase_service.dart';

/// Clase responsable de inicializar todos los componentes de la aplicación
class AppInitializer {
  /// Inicializa todos los componentes de la aplicación en el orden correcto
  static Future<void> initialize() async {
    // Asegurar que los bindings de Flutter estén inicializados
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializar sistema de logs
    await _initializeLogs();

    // Inicializar Supabase
    await SupabaseService.initialize();

    // Inicializar contenedor de inyección de dependencias
    await DependencyInjectionService.initialize();

    // Inicializar migraciones de base de datos
    await MigrationService.initialize();

    // Registrar el dispositivo
    await DeviceRegistrationService.registerDevice();
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
}
