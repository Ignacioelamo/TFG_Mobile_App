import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_permissions_monitor/app_permissions_monitor.dart';
import '../../config/app_config.dart';
import '../../models/file_manager.dart';
import '../../domain/entities/device.dart';
import '../../domain/usecases/register_device_usecase.dart';
import '../../injection_container.dart' as di;

/// Servicio encargado de la gestión del registro del dispositivo
class DeviceRegistrationService {
  /// Obtiene el ID del dispositivo y lo registra en la base de datos
  static Future<String?> registerDevice() async {
    try {
      // Obtener o generar ID del dispositivo
      final deviceId = await _ensureDeviceId();

      if (deviceId == null) {
        await FileManager.instance.writeToLog(
            "[DeviceRegistration] No se pudo obtener ID de dispositivo\n");
        return null;
      }

      // Registrar dispositivo usando el caso de uso
      await FileManager.instance.writeToLog(
          "[DeviceRegistration] Registrando dispositivo con ID: $deviceId\n");

      final registerDeviceUseCase = di.sl<RegisterDeviceUseCase>();
      final device = Device(
        deviceId: deviceId,
        lastActive: DateTime.now(),
      );

      final result = await registerDeviceUseCase.execute(device);

      if (result != null) {
        await FileManager.instance.writeToLog(
            "[DeviceRegistration] Dispositivo registrado exitosamente con ID en DB: $result\n");
        return result;
      } else {
        await FileManager.instance.writeToLog(
            "[DeviceRegistration] Error al registrar dispositivo\n");
        return null;
      }
    } catch (e) {
      await FileManager.instance.writeToLog("[DeviceRegistration] Error: $e\n");
      return null;
    }
  }

  /// Asegura que tenemos un ID de dispositivo, obteniéndolo si es necesario
  static Future<String?> _ensureDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(AppConfig.sharedPreferencesIdDevice);

      // Si no tenemos un ID, lo obtenemos
      if (deviceId == null) {
        await FileManager.instance.writeToLog(
            "[DeviceRegistration] ID de dispositivo no encontrado, obteniendo uno nuevo...\n");
        deviceId = await AppPermissionsMonitor().getDeviceId();

        if (deviceId != null) {
          await prefs.setString(AppConfig.sharedPreferencesIdDevice, deviceId);
          await FileManager.instance.writeToLog(
              "[DeviceRegistration] ID de dispositivo obtenido y guardado: $deviceId\n");
        } else {
          await FileManager.instance.writeToLog(
              "[DeviceRegistration] ERROR: No se pudo obtener ID de dispositivo\n");
        }
      } else {
        await FileManager.instance.writeToLog(
            "[DeviceRegistration] ID de dispositivo encontrado: $deviceId\n");
      }

      return deviceId;
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[DeviceRegistration] Error al obtener ID de dispositivo: $e\n");
      return null;
    }
  }
}
