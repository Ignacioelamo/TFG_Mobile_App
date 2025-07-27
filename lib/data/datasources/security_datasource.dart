import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/security_info_dto.dart';
import '../../models/file_manager.dart';

/// Interfaz que define las operaciones de datos para información de seguridad
abstract class SecurityDataSource {
  /// Guarda información de seguridad para un dispositivo
  Future<bool> saveSecurityInfo(SecurityInfoDto info);

  /// Obtiene la última información de seguridad para un dispositivo
  Future<SecurityInfoDto?> getLastSecurityInfo(String deviceId);
}

/// Implementación de SecurityDataSource que utiliza Supabase
class SupabaseSecurityDataSource implements SecurityDataSource {
  final SupabaseClient _client;

  /// Nombre de la tabla de información de seguridad en Supabase
  static const String _tableName = 'device_security';

  /// Constructor que recibe una instancia de SupabaseClient
  SupabaseSecurityDataSource(this._client);

  @override
  Future<bool> saveSecurityInfo(SecurityInfoDto info) async {
    try {
      await _client.from(_tableName).insert(info.toJson());

      return true;
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[SupabaseSecurityDataSource] Error guardando información de seguridad: $e\n");
      return false;
    }
  }

  @override
  Future<SecurityInfoDto?> getLastSecurityInfo(String deviceId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('device_id', deviceId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return SecurityInfoDto.fromJson(response);
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[SupabaseSecurityDataSource] Error obteniendo última información de seguridad: $e\n");
      return null;
    }
  }
}
