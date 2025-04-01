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

    // Aquí se pueden añadir solicitudes para otros permisos si son necesarios
  }
}
