import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gps_status_dto.dart';

/// Interfaz que define las operaciones de datos para estados de GPS
abstract class GpsDataSource {
  /// Guarda un nuevo estado de GPS
  Future<bool> saveGpsStatus(GpsStatusDto status);

  /// Obtiene el último estado de GPS para un dispositivo (estado actual)
  Future<GpsStatusDto?> getLastGpsStatus(String deviceId);

  /// Obtiene el historial de estados de GPS para un dispositivo
  Future<List<GpsStatusDto>> getGpsStatusHistory(String deviceId,
      {int limit = 10});

  /// Cierra el estado actual de GPS para un dispositivo
  Future<bool> closeCurrentGpsStatus(String deviceId);
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
      // Primero cerramos el estado actual si existe
      await closeCurrentGpsStatus(status.deviceId);

      // Luego insertamos el nuevo estado
      await _client.from(_tableName).insert(status.toJson());

      return true;
    } catch (e) {
      print('Error guardando estado de GPS: $e');
      return false;
    }
  }

  @override
  Future<bool> closeCurrentGpsStatus(String deviceId) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Actualizar todos los registros activos (con end_time = null)
      await _client
          .from(_tableName)
          .update({'end_time': now})
          .eq('device_id', deviceId)
          .filter('end_time', 'is', null);

      return true;
    } catch (e) {
      print('Error cerrando estado actual de GPS: $e');
      return false;
    }
  }

  @override
  Future<GpsStatusDto?> getLastGpsStatus(String deviceId) async {
    try {
      // Buscamos el estado con end_time = null (estado actual)
      final response = await _client
          .from(_tableName)
          .select()
          .eq('device_id', deviceId)
          .filter('end_time', 'is', null)
          .maybeSingle();

      if (response == null) {
        // Si no hay estado actual, buscamos el último estado finalizado
        final lastResponse = await _client
            .from(_tableName)
            .select()
            .eq('device_id', deviceId)
            .order('start_time', ascending: false)
            .limit(1)
            .maybeSingle();

        if (lastResponse == null) return null;
        return GpsStatusDto.fromJson(lastResponse);
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
          .order('start_time', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => GpsStatusDto.fromJson(json))
          .toList();
    } catch (e) {
      print('Error obteniendo historial de estados de GPS: $e');
      return [];
    }
  }
}
