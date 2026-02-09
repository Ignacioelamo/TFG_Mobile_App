import '../../domain/entities/app_use_time.dart';

/// Clase de transferencia de datos (DTO) para AppUseTime
///
/// Maneja la serialización y deserialización entre la entidad del dominio
/// y el formato JSON utilizado en la base de datos.
class AppUseTimeDto {
  final String? id;
  final String deviceId;
  final String packageName;
  final DateTime date;
  final double minutes;
  final DateTime? createdAt;

  AppUseTimeDto({
    this.id,
    required this.deviceId,
    required this.packageName,
    required this.date,
    required this.minutes,
    this.createdAt,
  });

  /// Crea un AppUseTimeDto a partir de un JSON
  factory AppUseTimeDto.fromJson(Map<String, dynamic> json) {
    return AppUseTimeDto(
      id: json['id'],
      deviceId: json['device_id'],
      packageName: json['package_name'],
      date: DateTime.parse(json['date']),
      minutes: (json['minutes'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Convierte el DTO a un JSON para enviar a la base de datos
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'device_id': deviceId,
      'package_name': packageName,
      'date': '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'minutes': minutes,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  /// Convierte el DTO a una entidad de dominio
  AppUseTime toEntity() {
    return AppUseTime(
      id: id,
      deviceId: deviceId,
      packageName: packageName,
      date: date,
      minutes: minutes,
      createdAt: createdAt,
    );
  }

  /// Crea un DTO a partir de una entidad de dominio
  factory AppUseTimeDto.fromEntity(AppUseTime entity) {
    return AppUseTimeDto(
      id: entity.id,
      deviceId: entity.deviceId,
      packageName: entity.packageName,
      date: entity.date,
      minutes: entity.minutes,
      createdAt: entity.createdAt,
    );
  }
}
