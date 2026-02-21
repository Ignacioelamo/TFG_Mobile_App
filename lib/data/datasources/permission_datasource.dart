import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/app_permission_snapshot.dart';
import '../../domain/entities/permission_change.dart';
import '../models/installed_app_dto.dart';
import '../models/permission_status_dto.dart';
import '../models/permission_change_dto.dart';
import '../../models/file_manager.dart';

/// Interfaz que define las operaciones de datos para permisos de aplicaciones
abstract class PermissionDataSource {
  /// Guarda el snapshot completo de permisos:
  /// upsert en installed_apps + upsert en permission_status
  ///
  /// [deviceDbId] es el UUID del dispositivo en Supabase
  /// [snapshot] es la lista de snapshots de permisos por aplicación
  Future<bool> savePermissionSnapshot(
      String deviceDbId, List<AppPermissionSnapshot> snapshot);

  /// Guarda los cambios detectados en permisos en permission_history
  ///
  /// [deviceDbId] es el UUID del dispositivo en Supabase
  /// [changes] es la lista de cambios detectados
  Future<bool> savePermissionChanges(
      String deviceDbId, List<PermissionChange> changes);
}

/// Implementación de PermissionDataSource que utiliza Supabase
class SupabasePermissionDataSource implements PermissionDataSource {
  final SupabaseClient _client;

  static const String _installedAppsTable = 'installed_apps';
  static const String _permissionGroupsTable = 'permission_groups';
  static const String _permissionStatusTable = 'permission_status';
  static const String _permissionHistoryTable = 'permission_history';

  /// Cache del mapa nombre -> UUID para permission_groups (datos estáticos)
  Map<String, String>? _permissionGroupCache;

  /// Constructor que recibe una instancia de SupabaseClient
  SupabasePermissionDataSource(this._client);

  /// Obtiene y cachea el mapa de permission_groups {nombre -> uuid}
  ///
  /// Los permission_groups son datos estáticos de referencia (15 registros),
  /// por lo que se cachean en memoria tras la primera consulta.
  Future<Map<String, String>> _getPermissionGroupMap() async {
    if (_permissionGroupCache != null) return _permissionGroupCache!;

    final response = await _client.from(_permissionGroupsTable).select();

    _permissionGroupCache = {
      for (var row in response) row['name'] as String: row['id'] as String
    };

    await FileManager.instance.writeToLog(
        "[PermissionDataSource] Cache de permission_groups cargada: ${_permissionGroupCache!.length} grupos\n");

    return _permissionGroupCache!;
  }

  /// Hace upsert de una app en installed_apps y devuelve su UUID
  ///
  /// Usa ON CONFLICT (device_id, package_name) para evitar duplicados
  /// y actualizar last_updated en caso de que ya exista.
  Future<String?> _upsertInstalledApp(
      String deviceDbId, String packageName) async {
    final dto = InstalledAppDto(
      deviceId: deviceDbId,
      packageName: packageName,
    );

    final response = await _client
        .from(_installedAppsTable)
        .upsert(dto.toJson(), onConflict: 'device_id,package_name')
        .select('id')
        .single();

    return response['id'] as String?;
  }

  @override
  Future<bool> savePermissionSnapshot(
      String deviceDbId, List<AppPermissionSnapshot> snapshot) async {
    try {
      if (snapshot.isEmpty) return true;

      await FileManager.instance.writeToLog(
          "[PermissionDataSource] Guardando snapshot de ${snapshot.length} apps\n");

      // Obtener mapa de permission_groups
      final groupMap = await _getPermissionGroupMap();

      for (var appSnapshot in snapshot) {
        // 1. Upsert en installed_apps -> obtener app_id
        final appId =
            await _upsertInstalledApp(deviceDbId, appSnapshot.packageName);

        if (appId == null) {
          await FileManager.instance.writeToLog(
              "[PermissionDataSource] ERROR: No se pudo obtener app_id para ${appSnapshot.packageName}\n");
          continue;
        }

        // 2. Construir lista de permission_status para esta app
        final statusDtos = <Map<String, dynamic>>[];

        for (var entry in appSnapshot.permissionStatuses.entries) {
          final groupId = groupMap[entry.key];
          if (groupId == null) {
            await FileManager.instance.writeToLog(
                "[PermissionDataSource] WARN: Grupo de permiso desconocido: ${entry.key}\n");
            continue;
          }

          final statusDto = PermissionStatusDto(
            deviceId: deviceDbId,
            appId: appId,
            permissionGroupId: groupId,
            status: entry.value,
          );
          statusDtos.add(statusDto.toJson());
        }

        // 3. Batch upsert de permission_status para esta app
        if (statusDtos.isNotEmpty) {
          await _client.from(_permissionStatusTable).upsert(statusDtos,
              onConflict: 'app_id,permission_group_id');
        }
      }

      await FileManager.instance.writeToLog(
          "[PermissionDataSource] Snapshot guardado correctamente\n");
      return true;
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[PermissionDataSource] ERROR guardando snapshot de permisos: $e\n");
      return false;
    }
  }

  @override
  Future<bool> savePermissionChanges(
      String deviceDbId, List<PermissionChange> changes) async {
    try {
      if (changes.isEmpty) return true;

      await FileManager.instance.writeToLog(
          "[PermissionDataSource] Guardando ${changes.length} cambios en historial\n");

      // Convertir entidades a DTOs y luego a JSON
      final jsonList = changes
          .map((change) => PermissionChangeDto.fromEntity(change).toJson())
          .toList();

      // Batch insert en permission_history (tabla append-only)
      await _client.from(_permissionHistoryTable).insert(jsonList);

      await FileManager.instance.writeToLog(
          "[PermissionDataSource] ${changes.length} cambios guardados en historial\n");
      return true;
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[PermissionDataSource] ERROR guardando cambios de permisos: $e\n");
      return false;
    }
  }
}
