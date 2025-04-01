import '../entities/gps_status.dart';

/// Interfaz que define las operaciones disponibles para gestionar estados de GPS
abstract class GpsRepository {
  /// Guarda un nuevo estado de GPS para un dispositivo
  ///
  /// Retorna true si la operación se completó correctamente,
  /// false en caso contrario
  Future<bool> saveGpsStatus(GpsStatus status);

  /// Obtiene el último estado registrado de GPS para un dispositivo
  ///
  /// [deviceId] es el ID único del dispositivo
  Future<GpsStatus?> getLastGpsStatus(String deviceId);

  /// Obtiene el historial de estados de GPS para un dispositivo
  ///
  /// [deviceId] es el ID único del dispositivo
  /// [limit] es el número máximo de registros a obtener
  Future<List<GpsStatus>> getGpsStatusHistory(String deviceId,
      {int limit = 10});
}
