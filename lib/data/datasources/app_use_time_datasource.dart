import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_use_time_dto.dart';
import '../../models/file_manager.dart';

/// Interfaz que define las operaciones de datos para tiempo de uso de aplicaciones
abstract class AppUseTimeDataSource {
  /// Realiza un UPSERT de los registros de tiempo de uso
  ///
  /// Si ya existe un registro para el mismo device_id + package_name + date,
  /// se actualiza el campo minutes. En caso contrario, se inserta.
  Future<bool> upsertAppUseTimes(List<AppUseTimeDto> items);

  /// Obtiene los registros de tiempo de uso para un dispositivo y fecha
  Future<List<AppUseTimeDto>> getAppUseTimes(String deviceId, DateTime date);
}

/// Implementación de AppUseTimeDataSource que utiliza Supabase
class SupabaseAppUseTimeDataSource implements AppUseTimeDataSource {
  final SupabaseClient _client;

  /// Nombre de la tabla de tiempo de uso en Supabase
  static const String _tableName = 'app_use_time';

  /// Constructor que recibe una instancia de SupabaseClient
  SupabaseAppUseTimeDataSource(this._client);

  @override
  Future<bool> upsertAppUseTimes(List<AppUseTimeDto> items) async {
    try {
      if (items.isEmpty) return true;

      final jsonList = items.map((item) => item.toJson()).toList();

      // UPSERT con conflicto en (device_id, package_name, date)
      await _client
          .from(_tableName)
          .upsert(jsonList, onConflict: 'device_id,package_name,date');

      await FileManager.instance.writeToLog(
          "[SupabaseAppUseTimeDataSource] UPSERT exitoso: ${items.length} registros\n");
      return true;
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[SupabaseAppUseTimeDataSource] ERROR en upsert de app_use_time: $e\n");
      return false;
    }
  }

  @override
  Future<List<AppUseTimeDto>> getAppUseTimes(
      String deviceId, DateTime date) async {
    try {
      final dateStr =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await _client
          .from(_tableName)
          .select()
          .eq('device_id', deviceId)
          .eq('date', dateStr);

      return (response as List)
          .map((json) => AppUseTimeDto.fromJson(json))
          .toList();
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[SupabaseAppUseTimeDataSource] Error obteniendo app_use_time: $e\n");
      return [];
    }
  }
}
