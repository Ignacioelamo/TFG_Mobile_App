/// Representa el tiempo de uso de una aplicación por día
class AppUseTime {
  /// Identificador único en la base de datos
  final String? id;

  /// UUID del dispositivo en Supabase
  final String deviceId;

  /// Nombre del paquete de la aplicación
  final String packageName;

  /// Fecha del día al que corresponde el cálculo (solo día, sin hora)
  final DateTime date;

  /// Tiempo de uso en minutos
  final double minutes;

  /// Fecha de creación del registro
  final DateTime? createdAt;

  /// Constructor
  AppUseTime({
    this.id,
    required this.deviceId,
    required this.packageName,
    required this.date,
    required this.minutes,
    this.createdAt,
  });

  /// Crea una copia del objeto con algunos campos modificados
  AppUseTime copyWith({
    String? id,
    String? deviceId,
    String? packageName,
    DateTime? date,
    double? minutes,
    DateTime? createdAt,
  }) {
    return AppUseTime(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      packageName: packageName ?? this.packageName,
      date: date ?? this.date,
      minutes: minutes ?? this.minutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AppUseTime(id: $id, deviceId: $deviceId, packageName: $packageName, date: $date, minutes: $minutes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUseTime &&
        other.id == id &&
        other.deviceId == deviceId &&
        other.packageName == packageName &&
        other.date == date &&
        other.minutes == minutes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceId.hashCode ^
        packageName.hashCode ^
        date.hashCode ^
        minutes.hashCode ^
        createdAt.hashCode;
  }
}
