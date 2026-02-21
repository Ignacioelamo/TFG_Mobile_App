import '../entities/permission_change.dart';
import '../repositories/permission_repository.dart';

/// Caso de uso para guardar cambios detectados en permisos de aplicaciones
class SavePermissionChangesUseCase {
  final PermissionRepository _repository;

  /// Constructor que recibe un repositorio de permisos
  SavePermissionChangesUseCase(this._repository);

  /// Ejecuta el caso de uso para guardar los cambios de permisos en el historial
  ///
  /// [deviceDbId] es el UUID del dispositivo en Supabase
  /// [changes] es la lista de cambios detectados
  /// Retorna true si el guardado fue exitoso, false en caso contrario
  Future<bool> execute(
      String deviceDbId, List<PermissionChange> changes) async {
    return await _repository.savePermissionChanges(deviceDbId, changes);
  }
}
