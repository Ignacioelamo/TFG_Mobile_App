import '../entities/security_info.dart';

/// Interfaz que define las operaciones disponibles para gestionar información de seguridad
abstract class SecurityRepository {
  /// Guarda información de seguridad para un dispositivo
  ///
  /// Retorna true si la operación se completó correctamente,
  /// false en caso contrario
  Future<bool> saveSecurityInfo(SecurityInfo info);

  /// Obtiene la última información de seguridad registrada para un dispositivo
  ///
  /// [deviceId] es el ID único del dispositivo
  Future<SecurityInfo?> getLastSecurityInfo(String deviceId);

  /// Obtiene el historial de información de seguridad para un dispositivo
  ///
  /// [deviceId] es el ID único del dispositivo
  /// [limit] es el número máximo de registros a obtener
  Future<List<SecurityInfo>> getSecurityInfoHistory(String deviceId,
      {int limit = 10});
}
