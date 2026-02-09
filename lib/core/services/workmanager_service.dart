import 'package:workmanager/workmanager.dart';
import '../../controller/controller.dart';
import '../../injection_container.dart' as di;
import '../../models/file_manager.dart';
import '../services/supabase_service.dart';

/// Servicio encargado de la gestión de tareas en segundo plano con Workmanager
class WorkmanagerService {
  /// Inicializa el sistema de tareas en segundo plano
  static Future<void> initialize() async {
    // Inicializar Workmanager con la función de callback
    Workmanager().initialize(callbackDispatcher,
        isInDebugMode: true // Para mostrar notificaciones durante la depuración
        );
  }

  /// Registra todas las tareas en segundo plano necesarias para la aplicación
  static Future<void> registerTasks() async {
    // Tarea única para recuperar el ID del dispositivo
    Workmanager()
        .registerOneOffTask("RetrieveDeviceId", "retrieve_device_id_task");

    // Tarea única para solicitar permisos de aplicaciones
    Workmanager().registerOneOffTask(
        "RequestAppPermissions", "request_app_permissions_task");

    // Tarea única para crear archivos de la aplicación
    Workmanager().registerOneOffTask("CreateAppFiles", "create_app_files_task",
        initialDelay: const Duration(seconds: 5));

    // Tarea única para escribir datos estáticos
    Workmanager().registerOneOffTask(
        "WriteStaticData", "write_static_data_task",
        initialDelay: const Duration(seconds: 10));

    // Tarea periódica para detectar cambios en los permisos
    Workmanager().registerPeriodicTask(
        "DetectAppPermissionsChanges", "detect_app_permissions_changes_task",
        initialDelay: const Duration(seconds: 60),
        frequency: const Duration(minutes: 20));

    // Tarea periódica para detectar cambios en el estado del GPS
    Workmanager().registerPeriodicTask(
        "DetectGpsStatusChanges", "detect_gps_status_changes_task",
        initialDelay: const Duration(seconds: 15),
        frequency: const Duration(minutes: 15));

    // Tarea periódica para recoger el tiempo de uso de aplicaciones
    Workmanager().registerPeriodicTask(
        "DetectAppUseTime", "detect_app_use_time_task",
        initialDelay: const Duration(seconds: 30),
        frequency: const Duration(minutes: 60));
  }
}

/// Función de punto de entrada para las tareas en segundo plano
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Inicializar las dependencias en el contexto del aislado
      await FileManager.instance
          .writeToLog("[WorkManager] Inicializando dependencias en aislado\n");

      await SupabaseService.initialize();

      await di.init();

      await FileManager.instance
          .writeToLog("[WorkManager] Dependencias inicializadas en aislado\n");

      // Ejecutar la tarea
      return await Controller.instance.handleWorkmanagerTask(task);
    } catch (e) {
      await FileManager.instance
          .writeToLog("[WorkManager] Error en callbackDispatcher: $e\n");
      return false;
    }
  });
}
