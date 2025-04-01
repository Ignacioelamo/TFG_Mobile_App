import '../entities/device.dart';
import '../repositories/device_repository.dart';

/// Caso de uso para registrar un dispositivo en el sistema
class RegisterDeviceUseCase {
  final DeviceRepository _repository;

  /// Constructor que recibe un repositorio de dispositivos
  RegisterDeviceUseCase(this._repository);

  /// Ejecuta el caso de uso para registrar un dispositivo
  ///
  /// Retorna el ID del dispositivo en la base de datos en caso de éxito,
  /// o null en caso de error
  Future<String?> execute(Device device) async {
    return await _repository.registerDevice(device);
  }
}
