import '../../domain/entities/gps_status.dart';

/// Clase de transferencia de datos (DTO) para GpsStatus
///
/// Maneja la serialización y deserialización entre la entidad del dominio
/// y el formato JSON utilizado en la base de datos.
class GpsStatusDto {
  final String? id;
  final String deviceId;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;

  GpsStatusDto({
    this.id,
    required this.deviceId,
    required this.status,
    required this.startTime,
    this.endTime,
  });

  /// Crea un GpsStatusDto a partir de un JSON
  factory GpsStatusDto.fromJson(Map<String, dynamic> json) {
    return GpsStatusDto(
      id: json['id'],
      deviceId: json['device_id'],
      status: json['status'],
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : DateTime.now(),
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
    );
  }

  /// Convierte el DTO a un JSON para enviar a la base de datos
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'device_id': deviceId,
      'status': status,
      'start_time': startTime.toIso8601String(),
    };

    if (id != null) {
      data['id'] = id;
    }

    if (endTime != null) {
      data['end_time'] = endTime!.toIso8601String();
    }

    return data;
  }

  /// Convierte el DTO a una entidad de dominio
  GpsStatus toEntity() {
    return GpsStatus(
      id: id,
      deviceId: deviceId,
      status: status,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Crea un DTO a partir de una entidad de dominio
  factory GpsStatusDto.fromEntity(GpsStatus status) {
    return GpsStatusDto(
      id: status.id,
      deviceId: status.deviceId,
      status: status.status,
      startTime: status.startTime,
      endTime: status.endTime,
    );
  }
}
