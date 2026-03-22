import '../../domain/entities/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_datasource.dart';
import '../models/device_dto.dart';

/// Implementación del repositorio de dispositivos
class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceDataSource _dataSource;

  /// Constructor que recibe una fuente de datos de dispositivos
  DeviceRepositoryImpl(this._dataSource);

  @override
  Future<String?> registerDevice(Device device) async {
    final dto = DeviceDto.fromEntity(device);
    return await _dataSource.registerDevice(dto);
  }

  @override
  Future<bool> updateLastActive(String deviceId) async {
    return await _dataSource.updateLastActive(deviceId);
  }

  @override
  Future<Device?> getDeviceByDeviceId(String deviceId) async {
    final dto = await _dataSource.getDeviceByDeviceId(deviceId);
    return dto?.toEntity();
  }

  @override
  Future<String?> getDbIdByDeviceId(String deviceId) async {
    return await _dataSource.getDbIdByDeviceId(deviceId);
  }

  @override
  Future<bool> updateUpdated(String deviceId, bool updated) async {
    return await _dataSource.updateUpdated(deviceId, updated);
  }
}
