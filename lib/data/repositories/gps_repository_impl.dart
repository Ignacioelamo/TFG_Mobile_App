import '../../domain/entities/gps_status.dart';
import '../../domain/repositories/gps_repository.dart';
import '../datasources/gps_datasource.dart';
import '../models/gps_status_dto.dart';

/// Implementación del repositorio de estados de GPS
class GpsRepositoryImpl implements GpsRepository {
  final GpsDataSource _dataSource;

  /// Constructor que recibe una fuente de datos de estados de GPS
  GpsRepositoryImpl(this._dataSource);

  @override
  Future<bool> saveGpsStatus(GpsStatus status) async {
    final dto = GpsStatusDto.fromEntity(status);
    return await _dataSource.saveGpsStatus(dto);
  }

  @override
  Future<GpsStatus?> getLastGpsStatus(String deviceId) async {
    final dto = await _dataSource.getLastGpsStatus(deviceId);
    return dto?.toEntity();
  }

  @override
  Future<List<GpsStatus>> getGpsStatusHistory(String deviceId,
      {int limit = 10}) async {
    final dtos = await _dataSource.getGpsStatusHistory(deviceId, limit: limit);
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
