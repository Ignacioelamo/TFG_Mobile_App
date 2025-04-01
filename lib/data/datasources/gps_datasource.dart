import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gps_status_dto.dart';

/// Interfaz que define las operaciones de datos para estados de GPS
abstract class GpsDataSource {
  /// Guarda un nuevo estado de GPS
  Future<bool> saveGpsStatus(GpsStatusDto status);

  /// Obtiene el último estado de GPS para un dispositivo
  Future<GpsStatusDto?> getLastGpsStatus(String deviceId);

  /// Obtiene el historial de estados de GPS para un dispositivo
  Future<List<GpsStatusDto>> getGpsStatusHistory(String deviceId,
      {int limit = 10});
}

/// Implementación de GpsDataSource que utiliza Supabase
class SupabaseGpsDataSource implements GpsDataSource {
  final SupabaseClient _client;

  /// Nombre de la tabla de estados de GPS en Supabase
  static const String _tableName = 'gps_status';

  /// Constructor que recibe una instancia de SupabaseClient
  SupabaseGpsDataSource(this._client);

  @override
  Future<bool> saveGpsStatus(GpsStatusDto status) async {
    try {
      await _client.from(_tableName).insert(status.toJson());

      return true;
    } catch (e) {
      print('Error guardando estado de GPS: $e');
      return false;
    }
  }

  @override
  Future<GpsStatusDto?> getLastGpsStatus(String deviceId) async {
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

      return GpsStatusDto.fromJson(response);
    } catch (e) {
      print('Error obteniendo último estado de GPS: $e');
      return null;
    }
  }

  @override
  Future<List<GpsStatusDto>> getGpsStatusHistory(String deviceId,
      {int limit = 10}) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('device_id', deviceId)
          .order('recorded_at', ascending: false)
          .limit(limit);

      return response.map((json) => GpsStatusDto.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo historial de estados de GPS: $e');
      return [];
    }
  }
}
