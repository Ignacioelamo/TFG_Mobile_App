import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/security_info_dto.dart';

/// Interfaz que define las operaciones de datos para información de seguridad
abstract class SecurityDataSource {
  /// Guarda información de seguridad para un dispositivo
  Future<bool> saveSecurityInfo(SecurityInfoDto info);

  /// Obtiene la última información de seguridad para un dispositivo
  Future<SecurityInfoDto?> getLastSecurityInfo(String deviceId);

  /// Obtiene el historial de información de seguridad para un dispositivo
  Future<List<SecurityInfoDto>> getSecurityInfoHistory(String deviceId,
      {int limit = 10});
}

/// Implementación de SecurityDataSource que utiliza Supabase
class SupabaseSecurityDataSource implements SecurityDataSource {
  final SupabaseClient _client;

  /// Nombre de la tabla de información de seguridad en Supabase
  static const String _tableName = 'security_info';

  /// Constructor que recibe una instancia de SupabaseClient
  SupabaseSecurityDataSource(this._client);

  @override
  Future<bool> saveSecurityInfo(SecurityInfoDto info) async {
    try {
      await _client.from(_tableName).insert(info.toJson());

      return true;
    } catch (e) {
      print('Error guardando información de seguridad: $e');
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
          .order('recorded_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return SecurityInfoDto.fromJson(response);
    } catch (e) {
      print('Error obteniendo última información de seguridad: $e');
      return null;
    }
  }

  @override
  Future<List<SecurityInfoDto>> getSecurityInfoHistory(String deviceId,
      {int limit = 10}) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('device_id', deviceId)
          .order('recorded_at', ascending: false)
          .limit(limit);

      return response.map((json) => SecurityInfoDto.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo historial de información de seguridad: $e');
      return [];
    }
  }
}
