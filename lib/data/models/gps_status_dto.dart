import '../../domain/entities/gps_status.dart';

/// Clase de transferencia de datos (DTO) para GpsStatus
///
/// Maneja la serialización y deserialización entre la entidad del dominio
/// y el formato JSON utilizado en la base de datos.
class GpsStatusDto {
  final String? id;
  final String deviceId;
  final String status;
  final DateTime recordedAt;

  GpsStatusDto({
    this.id,
    required this.deviceId,
    required this.status,
    required this.recordedAt,
  });

  /// Crea un GpsStatusDto a partir de un JSON
  factory GpsStatusDto.fromJson(Map<String, dynamic> json) {
    return GpsStatusDto(
      id: json['id'],
      deviceId: json['device_id'],
      status: json['status'],
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'])
          : DateTime.now(),
    );
  }

  /// Convierte el DTO a un JSON para enviar a la base de datos
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'device_id': deviceId,
      'status': status,
      'recorded_at': recordedAt.toIso8601String(),
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  /// Convierte el DTO a una entidad de dominio
  GpsStatus toEntity() {
    return GpsStatus(
      id: id,
      deviceId: deviceId,
      status: status,
      recordedAt: recordedAt,
    );
  }

  /// Crea un DTO a partir de una entidad de dominio
  factory GpsStatusDto.fromEntity(GpsStatus status) {
    return GpsStatusDto(
      id: status.id,
      deviceId: status.deviceId,
      status: status.status,
      recordedAt: status.recordedAt,
    );
  }
}
