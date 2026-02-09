import '../entities/app_use_time.dart';
import '../repositories/app_use_time_repository.dart';

/// Caso de uso para guardar los tiempos de uso de aplicaciones
class SaveAppUseTimesUseCase {
  final AppUseTimeRepository _repository;

  /// Constructor que recibe un repositorio de tiempo de uso
  SaveAppUseTimesUseCase(this._repository);

  /// Ejecuta el caso de uso para guardar los tiempos de uso
  ///
  /// Retorna true si el guardado fue exitoso, false en caso contrario
  Future<bool> execute(List<AppUseTime> items) async {
    return await _repository.saveAppUseTimes(items);
  }
}
