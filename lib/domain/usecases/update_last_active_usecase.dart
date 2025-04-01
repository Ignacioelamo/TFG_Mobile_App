import '../repositories/device_repository.dart';

/// Caso de uso para actualizar el último momento activo de un dispositivo
class UpdateLastActiveUseCase {
  final DeviceRepository _repository;

  /// Constructor que recibe un repositorio de dispositivos
  UpdateLastActiveUseCase(this._repository);

  /// Ejecuta el caso de uso para actualizar el último momento activo
  ///
  /// Retorna true si la actualización fue exitosa, false en caso contrario
  Future<bool> execute(String deviceId) async {
    return await _repository.updateLastActive(deviceId);
  }
}
