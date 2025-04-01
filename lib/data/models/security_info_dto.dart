import '../../domain/entities/security_info.dart';

/// Clase de transferencia de datos (DTO) para SecurityInfo
///
/// Maneja la serialización y deserialización entre la entidad del dominio
/// y el formato JSON utilizado en la base de datos.
class SecurityInfoDto {
  final String? id;
  final String deviceId;
  final bool biometricAuthEnabled;
  final bool lockScreenEnabled;
  final DateTime recordedAt;

  SecurityInfoDto({
    this.id,
    required this.deviceId,
    required this.biometricAuthEnabled,
    required this.lockScreenEnabled,
    required this.recordedAt,
  });

  /// Crea un SecurityInfoDto a partir de un JSON
  factory SecurityInfoDto.fromJson(Map<String, dynamic> json) {
    return SecurityInfoDto(
      id: json['id'],
      deviceId: json['device_id'],
      biometricAuthEnabled: json['biometric_auth_enabled'] as bool,
      lockScreenEnabled: json['lock_screen_enabled'] as bool,
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'])
          : DateTime.now(),
    );
  }

  /// Convierte el DTO a un JSON para enviar a la base de datos
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'device_id': deviceId,
      'biometric_auth_enabled': biometricAuthEnabled,
      'lock_screen_enabled': lockScreenEnabled,
      'recorded_at': recordedAt.toIso8601String(),
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  /// Convierte el DTO a una entidad de dominio
  SecurityInfo toEntity() {
    return SecurityInfo(
      id: id,
      deviceId: deviceId,
      biometricAuthEnabled: biometricAuthEnabled,
      lockScreenEnabled: lockScreenEnabled,
      recordedAt: recordedAt,
    );
  }

  /// Crea un DTO a partir de una entidad de dominio
  factory SecurityInfoDto.fromEntity(SecurityInfo securityInfo) {
    return SecurityInfoDto(
      id: securityInfo.id,
      deviceId: securityInfo.deviceId,
      biometricAuthEnabled: securityInfo.biometricAuthEnabled,
      lockScreenEnabled: securityInfo.lockScreenEnabled,
      recordedAt: securityInfo.recordedAt,
    );
  }
}
