import 'package:permission_handler/permission_handler.dart';
import '../../models/file_manager.dart';

/// Servicio encargado de la gestión de permisos de la aplicación
class PermissionService {
  /// Solicita los permisos necesarios para la aplicación
  static Future<void> requestPermissions() async {
    await FileManager.instance.writeToLog(
        "[PermissionService] Solicitando permisos de notificación\n");

    if (await Permission.notification.request().isDenied) {
      await Permission.notification.request();
      await FileManager.instance.writeToLog(
          "[PermissionService] Permiso de notificación solicitado nuevamente\n");
    } else {
      await FileManager.instance.writeToLog(
          "[PermissionService] Permiso de notificación ya concedido\n");
    }

    // Solicitar permisos de ubicación
    await FileManager.instance
        .writeToLog("[PermissionService] Solicitando permisos de ubicación\n");

    var locationStatus = await Permission.location.request();
    await FileManager.instance.writeToLog(
        "[PermissionService] Estado de permiso de ubicación: $locationStatus\n");

    if (locationStatus.isDenied) {
      await FileManager.instance.writeToLog(
          "[PermissionService] Permiso de ubicación denegado, solicitando nuevamente\n");
      await Permission.location.request();
    } else {
      await FileManager.instance.writeToLog(
          "[PermissionService] Permiso de ubicación concedido: $locationStatus\n");
    }

    // Intentar solicitar permiso de ubicación en segundo plano
    try {
      var backgroundStatus = await Permission.locationAlways.status;

      if (!backgroundStatus.isGranted) {
        await Permission.locationAlways.request();
      }
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[PermissionService] Error al solicitar permiso de ubicación en segundo plano: $e\n");
    }
  }
}
