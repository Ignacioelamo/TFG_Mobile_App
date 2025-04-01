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

  /// Constructor
  Device({
    this.id,
    required this.deviceId,
    this.createdAt,
    this.lastActive,
  });

  /// Crea una copia del objeto con algunos campos modificados
  Device copyWith({
    String? id,
    String? deviceId,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return Device(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  String toString() {
    return 'Device(id: $id, deviceId: $deviceId, createdAt: $createdAt, lastActive: $lastActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Device &&
        other.id == id &&
        other.deviceId == deviceId &&
        other.createdAt == createdAt &&
        other.lastActive == lastActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceId.hashCode ^
        createdAt.hashCode ^
        lastActive.hashCode;
  }
}
