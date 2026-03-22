import '../../core/services/updated_check_service.dart';
import '../repositories/device_repository.dart';

/// Caso de uso que comprueba si el firmware está actualizado y actualiza
/// el campo `updated` del dispositivo en la base de datos.
class UpdateDeviceUpdatedUseCase {
  final DeviceRepository _repository;
  final UpdatedCheckService _updatedCheckService;

  UpdateDeviceUpdatedUseCase(
    this._repository, {
    UpdatedCheckService? updatedCheckService,
  }) : _updatedCheckService =
            updatedCheckService ?? UpdatedCheckService.instance;

  /// Ejecuta la comprobación y actualiza el campo updated en Supabase.
  ///
  /// [deviceId] es el ID único del dispositivo físico (device_id en la tabla).
  /// Retorna true si la actualización se realizó correctamente.
  Future<bool> execute(String deviceId) async {
    final isUpdated = await _updatedCheckService.isFirmwareUpdated();

    if (isUpdated == null) {
      return false;
    }

    return await _repository.updateUpdated(deviceId, isUpdated);
  }
}
