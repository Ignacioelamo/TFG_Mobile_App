import '../entities/security_info.dart';
import '../repositories/security_repository.dart';

/// Caso de uso para guardar información de seguridad de un dispositivo
class SaveSecurityInfoUseCase {
  final SecurityRepository _repository;

  /// Constructor que recibe un repositorio de información de seguridad
  SaveSecurityInfoUseCase(this._repository);

  /// Ejecuta el caso de uso para guardar información de seguridad
  ///
  /// Retorna true si el guardado fue exitoso, false en caso contrario
  Future<bool> execute(SecurityInfo info) async {
    return await _repository.saveSecurityInfo(info);
  }
}
