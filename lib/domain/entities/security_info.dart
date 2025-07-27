/// Representa los posibles tipos de bloqueo de pantalla
enum LockScreenType {
  /// PIN numérico
  pin,

  /// Patrón gráfico
  pattern,

  /// Contraseña alfanumérica
  password,

  /// Biométrico (huella, face ID, etc.)
  biometric,

  /// Sin bloqueo
  none
}

/// Función para convertir string a enum
LockScreenType? lockScreenTypeFromString(String? value) {
  if (value == null) return null;

  return LockScreenType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => LockScreenType.none);
}

/// Función para convertir enum a string
String? lockScreenTypeToString(LockScreenType? type) {
  if (type == null) return null;
  return type.name;
}

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

  /// Tipo de bloqueo de pantalla
  final LockScreenType? lockScreenType;

  /// Fecha y hora de creación
  final DateTime createdAt;

  /// Fecha y hora de última actualización
  final DateTime updatedAt;

  /// Constructor
  SecurityInfo({
    this.id,
    required this.deviceId,
    required this.biometricAuthEnabled,
    required this.lockScreenEnabled,
    this.lockScreenType,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una copia del objeto con algunos campos modificados
  SecurityInfo copyWith({
    String? id,
    String? deviceId,
    bool? biometricAuthEnabled,
    bool? lockScreenEnabled,
    LockScreenType? lockScreenType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SecurityInfo(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      lockScreenEnabled: lockScreenEnabled ?? this.lockScreenEnabled,
      lockScreenType: lockScreenType ?? this.lockScreenType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    return 'SecurityInfo(id: $id, deviceId: $deviceId, biometricAuthEnabled: $biometricAuthEnabled, lockScreenEnabled: $lockScreenEnabled, lockScreenType: $lockScreenType, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecurityInfo &&
        other.id == id &&
        other.deviceId == deviceId &&
        other.biometricAuthEnabled == biometricAuthEnabled &&
        other.lockScreenEnabled == lockScreenEnabled &&
        other.lockScreenType == lockScreenType &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceId.hashCode ^
        biometricAuthEnabled.hashCode ^
        lockScreenEnabled.hashCode ^
        (lockScreenType?.hashCode ?? 0) ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
