import '../../domain/entities/security_info.dart';
import '../../domain/repositories/security_repository.dart';
import '../datasources/security_datasource.dart';
import '../models/security_info_dto.dart';

/// Implementación del repositorio de información de seguridad
class SecurityRepositoryImpl implements SecurityRepository {
  final SecurityDataSource _dataSource;

  /// Constructor que recibe una fuente de datos de información de seguridad
  SecurityRepositoryImpl(this._dataSource);

  @override
  Future<bool> saveSecurityInfo(SecurityInfo info) async {
    final dto = SecurityInfoDto.fromEntity(info);
    return await _dataSource.saveSecurityInfo(dto);
  }

  @override
  Future<SecurityInfo?> getLastSecurityInfo(String deviceId) async {
    final dto = await _dataSource.getLastSecurityInfo(deviceId);
    return dto?.toEntity();
  }

  @override
  Future<List<SecurityInfo>> getSecurityInfoHistory(String deviceId,
      {int limit = 10}) async {
    final dtos =
        await _dataSource.getSecurityInfoHistory(deviceId, limit: limit);
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
