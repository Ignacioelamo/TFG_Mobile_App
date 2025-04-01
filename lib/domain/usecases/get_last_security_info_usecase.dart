import '../entities/security_info.dart';
import '../repositories/security_repository.dart';

/// Caso de uso para obtener la última información de seguridad de un dispositivo
class GetLastSecurityInfoUseCase {
  final SecurityRepository _repository;

  /// Constructor que recibe un repositorio de información de seguridad
  GetLastSecurityInfoUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener la última información de seguridad
  ///
  /// Retorna la última información registrada o null si no hay información
  Future<SecurityInfo?> execute(String deviceId) async {
    return await _repository.getLastSecurityInfo(deviceId);
  }
}
