/// Representa información de seguridad de un dispositivo
class SecurityInfo {
  /// Identificador único en la base de datos
  final String? id;

  /// Dispositivo al que pertenece esta información
  final String deviceId;

  /// Indica si la autenticación biométrica está habilitada
  final bool biometricAuthEnabled;

  /// Indica si el bloqueo de pantalla está habilitado
  final bool lockScreenEnabled;

  /// Fecha y hora de registro
  final DateTime recordedAt;

  /// Constructor
  SecurityInfo({
    this.id,
    required this.deviceId,
    required this.biometricAuthEnabled,
    required this.lockScreenEnabled,
    required this.recordedAt,
  });

  /// Crea una copia del objeto con algunos campos modificados
  SecurityInfo copyWith({
    String? id,
    String? deviceId,
    bool? biometricAuthEnabled,
    bool? lockScreenEnabled,
    DateTime? recordedAt,
  }) {
    return SecurityInfo(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      lockScreenEnabled: lockScreenEnabled ?? this.lockScreenEnabled,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  /// Evalúa el nivel de seguridad del dispositivo
  String get securityLevel {
    if (biometricAuthEnabled && lockScreenEnabled) {
      return 'high';
    } else if (lockScreenEnabled) {
      return 'medium';
    } else {
      return 'low';
    }
  }

  @override
  String toString() {
    return 'SecurityInfo(id: $id, deviceId: $deviceId, biometricAuthEnabled: $biometricAuthEnabled, lockScreenEnabled: $lockScreenEnabled, recordedAt: $recordedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecurityInfo &&
        other.id == id &&
        other.deviceId == deviceId &&
        other.biometricAuthEnabled == biometricAuthEnabled &&
        other.lockScreenEnabled == lockScreenEnabled &&
        other.recordedAt == recordedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceId.hashCode ^
        biometricAuthEnabled.hashCode ^
        lockScreenEnabled.hashCode ^
        recordedAt.hashCode;
  }
}
