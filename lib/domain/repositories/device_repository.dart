import '../entities/device.dart';

/// Interfaz que define las operaciones disponibles para gestionar dispositivos
abstract class DeviceRepository {
  /// Registra un nuevo dispositivo o actualiza uno existente
  ///
  /// Retorna el ID del dispositivo en la base de datos en caso de éxito,
  /// o null en caso de error
  Future<String?> registerDevice(Device device);

  /// Actualiza el estado de "último activo" del dispositivo
  ///
  /// [deviceId] es el ID único del dispositivo
  Future<bool> updateLastActive(String deviceId);

  /// Obtiene información de un dispositivo por su deviceId
  Future<Device?> getDeviceByDeviceId(String deviceId);

  /// Obtiene el ID de base de datos correspondiente a un deviceId
  ///
  /// Utilizado internamente para operaciones relacionadas
  Future<String?> getDbIdByDeviceId(String deviceId);

  /// Actualiza el campo updated del dispositivo (firmware/apps actualizados)
  ///
  /// [deviceId] es el ID único del dispositivo físico
  Future<bool> updateUpdated(String deviceId, bool updated);
}
