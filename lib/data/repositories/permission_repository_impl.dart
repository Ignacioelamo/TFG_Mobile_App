import '../../domain/entities/app_permission_snapshot.dart';
import '../../domain/entities/permission_change.dart';
import '../../domain/repositories/permission_repository.dart';
import '../datasources/permission_datasource.dart';

/// Implementación del repositorio de permisos de aplicaciones
class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionDataSource _dataSource;

  /// Constructor que recibe una fuente de datos de permisos
  PermissionRepositoryImpl(this._dataSource);

  @override
  Future<bool> savePermissionSnapshot(
      String deviceDbId, List<AppPermissionSnapshot> snapshot) async {
    return await _dataSource.savePermissionSnapshot(deviceDbId, snapshot);
  }

  @override
  Future<bool> savePermissionChanges(
      String deviceDbId, List<PermissionChange> changes) async {
    return await _dataSource.savePermissionChanges(deviceDbId, changes);
  }
}
