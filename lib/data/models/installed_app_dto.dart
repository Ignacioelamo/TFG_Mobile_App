/// Clase de transferencia de datos (DTO) para aplicaciones instaladas
///
/// Maneja la serialización y deserialización entre la app
/// y el formato JSON utilizado en la tabla `installed_apps` de Supabase.
class InstalledAppDto {
  final String? id;
  final String deviceId;
  final String packageName;
  final DateTime? createdAt;
  final DateTime? lastUpdated;

  InstalledAppDto({
    this.id,
    required this.deviceId,
    required this.packageName,
    this.createdAt,
    this.lastUpdated,
  });

  /// Crea un InstalledAppDto a partir de un JSON
  factory InstalledAppDto.fromJson(Map<String, dynamic> json) {
    return InstalledAppDto(
      id: json['id'],
      deviceId: json['device_id'],
      packageName: json['package_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
    );
  }

  /// Convierte el DTO a un JSON para enviar a la base de datos
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'device_id': deviceId,
      'package_name': packageName,
      'last_updated': DateTime.now().toIso8601String(),
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }
}
