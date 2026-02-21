/// Clase de transferencia de datos (DTO) para el estado de permisos
///
/// Maneja la serialización y deserialización entre la app
/// y el formato JSON utilizado en la tabla `permission_status` de Supabase.
class PermissionStatusDto {
  final String? id;
  final String deviceId;
  final String appId;
  final String permissionGroupId;
  final String status;
  final DateTime? createdAt;

  PermissionStatusDto({
    this.id,
    required this.deviceId,
    required this.appId,
    required this.permissionGroupId,
    required this.status,
    this.createdAt,
  });

  /// Crea un PermissionStatusDto a partir de un JSON
  factory PermissionStatusDto.fromJson(Map<String, dynamic> json) {
    return PermissionStatusDto(
      id: json['id'],
      deviceId: json['device_id'],
      appId: json['app_id'],
      permissionGroupId: json['permission_group_id'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Convierte el DTO a un JSON para enviar a la base de datos
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'device_id': deviceId,
      'app_id': appId,
      'permission_group_id': permissionGroupId,
      'status': status,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }
}
