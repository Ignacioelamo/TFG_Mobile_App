import '../../domain/entities/permission_change.dart';

/// Clase de transferencia de datos (DTO) para cambios en permisos
///
/// Maneja la serialización y deserialización entre la entidad del dominio
/// y el formato JSON utilizado en la tabla `permission_history` de Supabase.
class PermissionChangeDto {
  final String? id;
  final String deviceId;
  final String packageName;
  final String permissionGroup;
  final String? previousStatus;
  final String newStatus;
  final DateTime? changedAt;

  PermissionChangeDto({
    this.id,
    required this.deviceId,
    required this.packageName,
    required this.permissionGroup,
    this.previousStatus,
    required this.newStatus,
    this.changedAt,
  });

  /// Crea un PermissionChangeDto a partir de un JSON
  factory PermissionChangeDto.fromJson(Map<String, dynamic> json) {
    return PermissionChangeDto(
      id: json['id'],
      deviceId: json['device_id'],
      packageName: json['package_name'],
      permissionGroup: json['permission_group'],
      previousStatus: json['previous_status'],
      newStatus: json['new_status'],
      changedAt: json['changed_at'] != null
          ? DateTime.parse(json['changed_at'])
          : null,
    );
  }

  /// Convierte el DTO a un JSON para enviar a la base de datos
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'device_id': deviceId,
      'package_name': packageName,
      'permission_group': permissionGroup,
      'new_status': newStatus,
    };

    if (id != null) {
      data['id'] = id;
    }

    if (previousStatus != null) {
      data['previous_status'] = previousStatus;
    }

    return data;
  }

  /// Convierte el DTO a una entidad de dominio
  PermissionChange toEntity() {
    return PermissionChange(
      id: id,
      deviceId: deviceId,
      packageName: packageName,
      permissionGroup: permissionGroup,
      previousStatus: previousStatus,
      newStatus: newStatus,
      changedAt: changedAt,
    );
  }

  /// Crea un DTO a partir de una entidad de dominio
  factory PermissionChangeDto.fromEntity(PermissionChange entity) {
    return PermissionChangeDto(
      id: entity.id,
      deviceId: entity.deviceId,
      packageName: entity.packageName,
      permissionGroup: entity.permissionGroup,
      previousStatus: entity.previousStatus,
      newStatus: entity.newStatus,
      changedAt: entity.changedAt,
    );
  }
}
