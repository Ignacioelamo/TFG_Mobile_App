import '../entities/app_permission_snapshot.dart';
import '../repositories/permission_repository.dart';

/// Caso de uso para guardar el snapshot completo de permisos de aplicaciones
class SavePermissionSnapshotUseCase {
  final PermissionRepository _repository;

  /// Constructor que recibe un repositorio de permisos
  SavePermissionSnapshotUseCase(this._repository);

  /// Ejecuta el caso de uso para guardar el snapshot de permisos
  ///
  /// [deviceDbId] es el UUID del dispositivo en Supabase
  /// [snapshot] es la lista de snapshots de permisos por aplicación
  /// Retorna true si el guardado fue exitoso, false en caso contrario
  Future<bool> execute(
      String deviceDbId, List<AppPermissionSnapshot> snapshot) async {
    return await _repository.savePermissionSnapshot(deviceDbId, snapshot);
  }
}
