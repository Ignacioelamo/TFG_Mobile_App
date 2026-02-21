/// Representa un cambio detectado en los permisos de una aplicación
class PermissionChange {
  /// Identificador único en la base de datos
  final String? id;

  /// UUID del dispositivo en Supabase
  final String deviceId;

  /// Nombre del paquete de la aplicación
  final String packageName;

  /// Nombre del grupo de permiso (e.g. 'LOCATION', 'CAMERA')
  final String permissionGroup;

  /// Estado anterior del permiso (null si la app es nueva)
  final String? previousStatus;

  /// Nuevo estado del permiso
  final String newStatus;

  /// Fecha y hora del cambio
  final DateTime? changedAt;

  /// Constructor
  PermissionChange({
    this.id,
    required this.deviceId,
    required this.packageName,
    required this.permissionGroup,
    this.previousStatus,
    required this.newStatus,
    this.changedAt,
  });

  /// Crea una copia del objeto con algunos campos modificados
  PermissionChange copyWith({
    String? id,
    String? deviceId,
    String? packageName,
    String? permissionGroup,
    String? previousStatus,
    String? newStatus,
    DateTime? changedAt,
  }) {
    return PermissionChange(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      packageName: packageName ?? this.packageName,
      permissionGroup: permissionGroup ?? this.permissionGroup,
      previousStatus: previousStatus ?? this.previousStatus,
      newStatus: newStatus ?? this.newStatus,
      changedAt: changedAt ?? this.changedAt,
    );
  }

  @override
  String toString() {
    return 'PermissionChange(id: $id, deviceId: $deviceId, packageName: $packageName, permissionGroup: $permissionGroup, previousStatus: $previousStatus, newStatus: $newStatus, changedAt: $changedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PermissionChange &&
        other.id == id &&
        other.deviceId == deviceId &&
        other.packageName == packageName &&
        other.permissionGroup == permissionGroup &&
        other.previousStatus == previousStatus &&
        other.newStatus == newStatus &&
        other.changedAt == changedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceId.hashCode ^
        packageName.hashCode ^
        permissionGroup.hashCode ^
        previousStatus.hashCode ^
        newStatus.hashCode ^
        changedAt.hashCode;
  }
}
