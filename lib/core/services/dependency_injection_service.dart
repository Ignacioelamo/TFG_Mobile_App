import '../../injection_container.dart' as di;
import '../../models/file_manager.dart';

/// Servicio encargado de la gestión de la inyección de dependencias
class DependencyInjectionService {
  /// Inicializa el contenedor de inyección de dependencias
  static Future<bool> initialize() async {
    try {
      await di.init();
      await FileManager.instance.writeToLog(
          "[DependencyInjection] Contenedor de inyección de dependencias inicializado\n");
      return true;
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[DependencyInjection] Error al inicializar la inyección de dependencias: $e\n");
      print("Error al inicializar la inyección de dependencias: $e");
      return false;
    }
  }
}
