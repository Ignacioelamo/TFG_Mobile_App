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
  final LockScreenType? lockScreenType;
  final DateTime createdAt;
  final DateTime updatedAt;

  SecurityInfoDto({
    this.id,
    required this.deviceId,
    required this.biometricAuthEnabled,
    required this.lockScreenEnabled,
    this.lockScreenType,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea un SecurityInfoDto a partir de un JSON
  factory SecurityInfoDto.fromJson(Map<String, dynamic> json) {
    return SecurityInfoDto(
      id: json['id'],
      deviceId: json['device_id'],
      biometricAuthEnabled: json['biometric_auth_enabled'] as bool,
      lockScreenEnabled: json['lock_screen_enabled'] as bool,
      lockScreenType: lockScreenTypeFromString(json['lock_screen_type']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  /// Convierte el DTO a un JSON para enviar a la base de datos
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'device_id': deviceId,
      'biometric_auth_enabled': biometricAuthEnabled,
      'lock_screen_enabled': lockScreenEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (id != null) {
      data['id'] = id;
    }

    if (lockScreenType != null) {
      data['lock_screen_type'] = lockScreenTypeToString(lockScreenType);
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
      lockScreenType: lockScreenType,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea un DTO a partir de una entidad de dominio
  factory SecurityInfoDto.fromEntity(SecurityInfo securityInfo) {
    return SecurityInfoDto(
      id: securityInfo.id,
      deviceId: securityInfo.deviceId,
      biometricAuthEnabled: securityInfo.biometricAuthEnabled,
      lockScreenEnabled: securityInfo.lockScreenEnabled,
      lockScreenType: securityInfo.lockScreenType,
      createdAt: securityInfo.createdAt,
      updatedAt: securityInfo.updatedAt,
    );
  }
}
