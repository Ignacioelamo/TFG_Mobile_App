import '../../domain/entities/app_use_time.dart';
import '../../domain/repositories/app_use_time_repository.dart';
import '../datasources/app_use_time_datasource.dart';
import '../models/app_use_time_dto.dart';

/// Implementación del repositorio de tiempo de uso de aplicaciones
class AppUseTimeRepositoryImpl implements AppUseTimeRepository {
  final AppUseTimeDataSource _dataSource;

  /// Constructor que recibe una fuente de datos de tiempo de uso
  AppUseTimeRepositoryImpl(this._dataSource);

  @override
  Future<bool> saveAppUseTimes(List<AppUseTime> items) async {
    final dtos = items.map((item) => AppUseTimeDto.fromEntity(item)).toList();
    return await _dataSource.upsertAppUseTimes(dtos);
  }

  @override
  Future<List<AppUseTime>> getAppUseTimes(
      String deviceId, DateTime date) async {
    final dtos = await _dataSource.getAppUseTimes(deviceId, date);
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
