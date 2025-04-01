import '../../domain/entities/device.dart';

/// Clase de transferencia de datos (DTO) para Device
///
/// Maneja la serialización y deserialización entre la entidad del dominio
/// y el formato JSON utilizado en la base de datos.
class DeviceDto {
  final String? id;
  final String deviceId;
  final DateTime? createdAt;
  final DateTime? lastActive;

  DeviceDto({
    this.id,
    required this.deviceId,
    this.createdAt,
    this.lastActive,
  });

  /// Crea un DeviceDto a partir de un JSON
  factory DeviceDto.fromJson(Map<String, dynamic> json) {
    return DeviceDto(
      id: json['id'],
      deviceId: json['device_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'])
          : null,
    );
  }

  /// Convierte el DTO a un JSON para enviar a la base de datos
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'device_id': deviceId,
    };

    // Solo incluimos el ID si no es nulo (para actualizaciones)
    if (id != null) {
      data['id'] = id;
    }

    // Solo incluimos last_active si no es nulo
    if (lastActive != null) {
      data['last_active'] = lastActive!.toIso8601String();
    }

    return data;
  }

  /// Convierte el DTO a una entidad de dominio
  Device toEntity() {
    return Device(
      id: id,
      deviceId: deviceId,
      createdAt: createdAt,
      lastActive: lastActive,
    );
  }

  /// Crea un DTO a partir de una entidad de dominio
  factory DeviceDto.fromEntity(Device device) {
    return DeviceDto(
      id: device.id,
      deviceId: device.deviceId,
      createdAt: device.createdAt,
      lastActive: device.lastActive,
    );
  }
}
