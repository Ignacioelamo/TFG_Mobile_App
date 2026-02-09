import '../entities/app_use_time.dart';

/// Interfaz que define las operaciones disponibles para gestionar
/// el tiempo de uso de aplicaciones
abstract class AppUseTimeRepository {
  /// Guarda una lista de registros de tiempo de uso de aplicaciones
  ///
  /// Realiza UPSERT: si ya existe un registro para el mismo
  /// device_id + package_name + date, se actualiza.
  /// Retorna true si la operación se completó correctamente.
  Future<bool> saveAppUseTimes(List<AppUseTime> items);

  /// Obtiene los registros de tiempo de uso para un dispositivo y fecha
  ///
  /// [deviceId] es el UUID del dispositivo en Supabase
  /// [date] es la fecha del día a consultar
  Future<List<AppUseTime>> getAppUseTimes(String deviceId, DateTime date);
}
