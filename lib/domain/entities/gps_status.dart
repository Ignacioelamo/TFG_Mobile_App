/// Representa el estado del GPS de un dispositivo
class GpsStatus {
  /// Identificador único en la base de datos
  final String? id;

  /// Dispositivo al que pertenece este estado
  final String deviceId;

  /// Estado del GPS (ON, OFF)
  final String status;

  /// Fecha y hora de inicio del estado
  final DateTime startTime;

  /// Fecha y hora de fin del estado (null si es el estado actual)
  final DateTime? endTime;

  /// Constructor
  GpsStatus({
    this.id,
    required this.deviceId,
    required this.status,
    required this.startTime,
    this.endTime,
  });

  /// Crea una copia del objeto con algunos campos modificados
  GpsStatus copyWith({
    String? id,
    String? deviceId,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return GpsStatus(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  /// Verifica si el GPS está habilitado
  bool get isEnabled => status == 'ON';

  /// Verifica si el GPS está deshabilitado
  bool get isDisabled => status == 'OFF';

  /// Verifica si este es el estado actual (sin fecha de fin)
  bool get isCurrent => endTime == null;

  /// Obtiene la duración del estado (null si es el estado actual)
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  @override
  String toString() {
    return 'GpsStatus(id: $id, deviceId: $deviceId, status: $status, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GpsStatus &&
        other.id == id &&
        other.deviceId == deviceId &&
        other.status == status &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceId.hashCode ^
        status.hashCode ^
        startTime.hashCode ^
        endTime.hashCode;
  }
}
