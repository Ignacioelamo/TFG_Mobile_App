import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_config.dart';
import '../../models/file_manager.dart';

/// Servicio encargado de la gestión de la conexión con Supabase
class SupabaseService {
  /// Inicializa la conexión con Supabase
  static Future<bool> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      await FileManager.instance
          .writeToLog("[Supabase] Inicializado correctamente\n");
      return true;
    } catch (e) {
      await FileManager.instance
          .writeToLog("[Supabase] Error al inicializar: $e\n");
      print("Error al inicializar Supabase: $e");
      return false;
    }
  }

  /// Obtiene el cliente de Supabase
  static SupabaseClient get client => Supabase.instance.client;
}
