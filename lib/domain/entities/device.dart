/// Representa un dispositivo en el dominio de la aplicación
class Device {
  /// Identificador único del dispositivo en la base de datos
  final String? id;

  /// Identificador único del dispositivo (Device ID)
  final String deviceId;

  /// Fecha de creación del registro
  final DateTime? createdAt;

  /// Última vez que el dispositivo estuvo activo
  final DateTime? lastActive;

  /// Indica si el parche de seguridad del firmware está reciente. Null = no calculado aún.
  final bool? updated;

  /// Constructor
  Device({
    this.id,
    required this.deviceId,
    this.createdAt,
    this.lastActive,
    this.updated,
  });

  /// Crea una copia del objeto con algunos campos modificados
  Device copyWith({
    String? id,
    String? deviceId,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? updated,
  }) {
    return Device(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'Device(id: $id, deviceId: $deviceId, createdAt: $createdAt, lastActive: $lastActive, updated: $updated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Device &&
        other.id == id &&
        other.deviceId == deviceId &&
        other.createdAt == createdAt &&
        other.lastActive == lastActive &&
        other.updated == updated;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceId.hashCode ^
        createdAt.hashCode ^
        lastActive.hashCode ^
        updated.hashCode;
  }
}
