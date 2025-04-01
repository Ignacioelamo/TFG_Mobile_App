/// Representa el estado del GPS de un dispositivo
class GpsStatus {
  /// Identificador único en la base de datos
  final String? id;

  /// Dispositivo al que pertenece este estado
  final String deviceId;

  /// Estado del GPS (enabled, disabled, unknown)
  final String status;

  /// Fecha y hora de registro
  final DateTime recordedAt;

  /// Constructor
  GpsStatus({
    this.id,
    required this.deviceId,
    required this.status,
    required this.recordedAt,
  });

  /// Crea una copia del objeto con algunos campos modificados
  GpsStatus copyWith({
    String? id,
    String? deviceId,
    String? status,
    DateTime? recordedAt,
  }) {
    return GpsStatus(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  /// Verifica si el GPS está habilitado
  bool get isEnabled => status == 'enabled';

  /// Verifica si el GPS está deshabilitado
  bool get isDisabled => status == 'disabled';

  @override
  String toString() {
    return 'GpsStatus(id: $id, deviceId: $deviceId, status: $status, recordedAt: $recordedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GpsStatus &&
        other.id == id &&
        other.deviceId == deviceId &&
        other.status == status &&
        other.recordedAt == recordedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceId.hashCode ^
        status.hashCode ^
        recordedAt.hashCode;
  }
}
