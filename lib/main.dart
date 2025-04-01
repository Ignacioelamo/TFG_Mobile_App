import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:app_permissions_monitor/app_permissions_monitor.dart';
import 'controller/controller.dart';
import 'view/my_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database/migration_manager.dart';
import 'config/app_config.dart';
import 'models/file_manager.dart';
import 'injection_container.dart' as di;
import 'domain/entities/device.dart';
import 'domain/usecases/register_device_usecase.dart';

/// Callback function to handle background tasks executed by Workmanager.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return await Controller.instance.handleWorkmanagerTask(task);
  });
}

/// Requests notification permissions from the user.
Future<void> _requestPermissions() async {
  if (await Permission.notification.request().isDenied) {
    await Permission.notification.request();
  }
}

/// Main entry point of the application.
void main() async {
  // Ensures that Flutter binding is initialized before calling any plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar FileManager para logs
  try {
    await FileManager.instance.createFile(AppConfig.logFileName);
    await FileManager.instance.writeToLog("[App] Iniciando aplicación\n");
  } catch (e) {
    print("Error al inicializar archivo de logs: $e");
  }

  // Inicialización Supabase
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
    // Considera mostrar un mensaje de error amigable aquí
  }

  // Inicializar contenedor de inyección de dependencias
  await di.init();
  await FileManager.instance.writeToLog(
      "[App] Contenedor de inyección de dependencias inicializado\n");

  // Intentar registrar el dispositivo
  try {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(AppConfig.sharedPreferencesIdDevice);

    // Si no tenemos un ID, lo obtenemos directamente sin usar Workmanager
    if (deviceId == null) {
      await FileManager.instance.writeToLog(
          "[App] ID de dispositivo no encontrado, obteniendo uno nuevo...\n");
      deviceId = await AppPermissionsMonitor().getDeviceId();

      if (deviceId != null) {
        await prefs.setString(AppConfig.sharedPreferencesIdDevice, deviceId);
        await FileManager.instance.writeToLog(
            "[App] ID de dispositivo obtenido y guardado: $deviceId\n");
      } else {
        await FileManager.instance
            .writeToLog("[App] ERROR: No se pudo obtener ID de dispositivo\n");
      }
    } else {
      await FileManager.instance
          .writeToLog("[App] ID de dispositivo encontrado: $deviceId\n");
    }

    // Ahora que tenemos ID, intentamos registrar el dispositivo
    if (deviceId != null) {
      await FileManager.instance
          .writeToLog("[App] Registrando dispositivo con ID: $deviceId\n");

      final registerDeviceUseCase = di.sl<RegisterDeviceUseCase>();
      final device = Device(
        deviceId: deviceId,
        lastActive: DateTime.now(),
      );

      final result = await registerDeviceUseCase.execute(device);

      if (result != null) {
        await FileManager.instance.writeToLog(
            "[App] Dispositivo registrado exitosamente con ID en DB: $result\n");
      } else {
        await FileManager.instance
            .writeToLog("[App] Error al registrar dispositivo\n");
      }
    }
  } catch (e) {
    await FileManager.instance
        .writeToLog("[App] Error al obtener/registrar dispositivo: $e\n");
    print("Error con el dispositivo: $e");
  }

  // Ejecución migraciones base de datos
  final migrationManager = MigrationManager(Supabase.instance.client);
  await migrationManager.initialize();

  // Solicitar permisos necesarios
  _requestPermissions();

  // Initialize Workmanager with the callbackDispatcher function.
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );

  // Mantener la tarea de ID de dispositivo para actualizaciones periódicas
  Workmanager()
      .registerOneOffTask("RetrieveDeviceId", "retrieve_device_id_task");

  Workmanager().registerOneOffTask(
      "RequestAppPermissions", "request_app_permissions_task");

  Workmanager().registerOneOffTask("CreateAppFiles", "create_app_files_task",
      initialDelay: const Duration(seconds: 5));

  Workmanager().registerOneOffTask("WriteStaticData", "write_static_data_task",
      initialDelay: const Duration(seconds: 10));

  // Register a periodic task with Workmanager.
  Workmanager().registerPeriodicTask(
      "DetectAppPermissionsChanges", "detect_app_permissions_changes_task",
      initialDelay: const Duration(seconds: 60),
      frequency: const Duration(minutes: 20));

  Workmanager().registerPeriodicTask(
      "DetectGpsStatusChanges", "detect_gps_status_changes_task",
      initialDelay: const Duration(seconds: 15),
      frequency: const Duration(minutes: 15));

  // Run the Flutter application.
  runApp(
    MaterialApp(
      title: 'TFG MOBILE APP',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Builder(
        builder: (BuildContext context) {
          return const MyApp();
        },
      ),
    ),
  );
}
