import 'package:flutter/foundation.dart';

/// Representa el estado de permisos de una aplicación instalada en un momento dado
class AppPermissionSnapshot {
  /// Nombre del paquete de la aplicación
  final String packageName;

  /// Mapa de grupo de permiso -> estado (e.g. 'LOCATION' -> 'Always')
  final Map<String, String> permissionStatuses;

  /// Constructor
  AppPermissionSnapshot({
    required this.packageName,
    required this.permissionStatuses,
  });

  /// Crea una copia del objeto con algunos campos modificados
  AppPermissionSnapshot copyWith({
    String? packageName,
    Map<String, String>? permissionStatuses,
  }) {
    return AppPermissionSnapshot(
      packageName: packageName ?? this.packageName,
      permissionStatuses: permissionStatuses ?? this.permissionStatuses,
    );
  }

  @override
  String toString() {
    return 'AppPermissionSnapshot(packageName: $packageName, permissionStatuses: $permissionStatuses)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppPermissionSnapshot &&
        other.packageName == packageName &&
        mapEquals(other.permissionStatuses, permissionStatuses);
  }

  @override
  int get hashCode {
    return packageName.hashCode ^ permissionStatuses.hashCode;
  }
}
