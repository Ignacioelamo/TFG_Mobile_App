import '../entities/gps_status.dart';
import '../repositories/gps_repository.dart';

/// Caso de uso para obtener el último estado del GPS de un dispositivo
class GetLastGpsStatusUseCase {
  final GpsRepository _repository;

  /// Constructor que recibe un repositorio de estados de GPS
  GetLastGpsStatusUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener el último estado del GPS
  ///
  /// Retorna el último estado registrado o null si no hay información
  Future<GpsStatus?> execute(String deviceId) async {
    return await _repository.getLastGpsStatus(deviceId);
  }
}
