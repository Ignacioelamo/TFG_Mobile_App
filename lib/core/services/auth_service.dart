import '../../models/file_manager.dart';
import 'supabase_service.dart';

/// Servicio encargado de la autenticación de usuarios
class AuthService {
  /// Almacena el ID del usuario actual autenticado
  static String? _currentUserId;

  /// Obtiene el ID del usuario actual autenticado
  static String? get currentUserId => _currentUserId;

  /// Valida las credenciales del usuario contra la tabla "user" en Supabase
  static Future<bool> login(String username, String password) async {
    try {
      await FileManager.instance
          .writeToLog("[AuthService] Intentando login para: $username\n");

      // Consulta el usuario por username directamente de la base de datos
      final response = await SupabaseService.client
          .from('user')
          .select('id, username, password')
          .eq('username', username)
          .maybeSingle();

      // Verificar si el usuario existe
      if (response == null) {
        await FileManager.instance
            .writeToLog("[AuthService] Usuario no encontrado: $username\n");
        return false;
      }

      // Obtener la contraseña almacenada y verificarla
      String storedPassword = response['password'];

      // Verificar si la contraseña coincide (comparación directa)
      if (password == storedPassword) {
        _currentUserId = response['id'];
        await FileManager.instance.writeToLog(
            "[AuthService] Login exitoso para $username (ID: $_currentUserId)\n");
        return true;
      } else {
        await FileManager.instance.writeToLog(
            "[AuthService] Contraseña incorrecta para: $username\n");
        return false;
      }
    } catch (e) {
      await FileManager.instance
          .writeToLog("[AuthService] Error en login: $e\n");
      return false;
    }
  }

  /// Cierra la sesión del usuario actual
  static Future<void> logout() async {
    try {
      // Limpiamos el usuario actual
      _currentUserId = null;
      await FileManager.instance.writeToLog("[AuthService] Logout exitoso\n");
    } catch (e) {
      await FileManager.instance
          .writeToLog("[AuthService] Error en logout: $e\n");
    }
  }

  /// Verifica si hay una sesión activa
  static bool isLoggedIn() {
    return _currentUserId != null;
  }

  /// Busca información del usuario autenticado
  static Future<Map<String, dynamic>?> getUserInfo() async {
    if (_currentUserId == null) {
      return null;
    }

    try {
      final response = await SupabaseService.client
          .from('user')
          .select('id, username, device_id')
          .eq('id', _currentUserId!)
          .single();

      return response;
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[AuthService] Error obteniendo información de usuario: $e\n");
      return null;
    }
  }

  /// Actualiza el dispositivo asociado al usuario actual
  static Future<bool> updateUserDevice(String deviceDbId) async {
    if (_currentUserId == null) {
      return false;
    }

    try {
      // Actualizar el campo device_id del usuario con el ID del dispositivo
      await SupabaseService.client
          .from('user')
          .update({'device_id': deviceDbId})
          .eq('id', _currentUserId!)
          .execute();

      await FileManager.instance.writeToLog(
          "[AuthService] Dispositivo $deviceDbId asociado al usuario $_currentUserId\n");
      return true;
    } catch (e) {
      await FileManager.instance
          .writeToLog("[AuthService] Error asociando dispositivo: $e\n");
      return false;
    }
  }
}
