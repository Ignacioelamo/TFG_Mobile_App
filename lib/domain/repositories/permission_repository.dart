import '../entities/app_permission_snapshot.dart';
import '../entities/permission_change.dart';

/// Interfaz que define las operaciones disponibles para gestionar
/// permisos de aplicaciones
abstract class PermissionRepository {
  /// Guarda el snapshot completo de permisos de las apps instaladas
  ///
  /// Realiza UPSERT en installed_apps y permission_status.
  /// [deviceDbId] es el UUID del dispositivo en Supabase.
  /// [snapshot] es la lista de snapshots de permisos por aplicación.
  /// Retorna true si la operación se completó correctamente.
  Future<bool> savePermissionSnapshot(
      String deviceDbId, List<AppPermissionSnapshot> snapshot);

  /// Guarda los cambios detectados en permisos en el historial
  ///
  /// Inserta registros en permission_history.
  /// [deviceDbId] es el UUID del dispositivo en Supabase.
  /// [changes] es la lista de cambios detectados.
  /// Retorna true si la operación se completó correctamente.
  Future<bool> savePermissionChanges(
      String deviceDbId, List<PermissionChange> changes);
}
