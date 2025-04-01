import '../entities/gps_status.dart';
import '../repositories/gps_repository.dart';

/// Caso de uso para guardar el estado del GPS de un dispositivo
class SaveGpsStatusUseCase {
  final GpsRepository _repository;

  /// Constructor que recibe un repositorio de estados de GPS
  SaveGpsStatusUseCase(this._repository);

  /// Ejecuta el caso de uso para guardar el estado del GPS
  ///
  /// Retorna true si el guardado fue exitoso, false en caso contrario
  Future<bool> execute(GpsStatus status) async {
    return await _repository.saveGpsStatus(status);
  }
}
