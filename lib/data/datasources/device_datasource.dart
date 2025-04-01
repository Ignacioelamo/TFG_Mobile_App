import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/device_dto.dart';
import '../../models/file_manager.dart';

/// Interfaz que define las operaciones de datos para dispositivos
abstract class DeviceDataSource {
  /// Registra un nuevo dispositivo o actualiza uno existente
  Future<String?> registerDevice(DeviceDto device);

  /// Actualiza el último momento activo de un dispositivo
  Future<bool> updateLastActive(String deviceId);

  /// Obtiene un dispositivo por su identificador único
  Future<DeviceDto?> getDeviceByDeviceId(String deviceId);

  /// Obtiene el ID de base de datos correspondiente a un deviceId
  Future<String?> getDbIdByDeviceId(String deviceId);
}

/// Implementación de DeviceDataSource que utiliza Supabase
class SupabaseDeviceDataSource implements DeviceDataSource {
  final SupabaseClient _client;

  /// Nombre de la tabla de dispositivos en Supabase
  static const String _tableName = 'devices';

  /// Constructor que recibe una instancia de SupabaseClient
  SupabaseDeviceDataSource(this._client);

  @override
  Future<String?> registerDevice(DeviceDto device) async {
    try {
      await FileManager.instance.writeToLog(
          "[DeviceDataSource] Intentando registrar dispositivo: ${device.deviceId}\n");

      // Verificar si el dispositivo ya existe
      final existingDevice = await getDeviceByDeviceId(device.deviceId);

      if (existingDevice != null) {
        // Actualizar el dispositivo existente
        await FileManager.instance.writeToLog(
            "[DeviceDataSource] Dispositivo existente, actualizando...\n");

        final updatedData = device.toJson()..remove('id');
        await FileManager.instance.writeToLog(
            "[DeviceDataSource] Datos a actualizar: $updatedData\n");

        final response = await _client
            .from(_tableName)
            .update(updatedData)
            .eq('device_id', device.deviceId)
            .select()
            .single();

        await FileManager.instance.writeToLog(
            "[DeviceDataSource] Dispositivo actualizado con ID: ${response['id']}\n");
        return response['id'];
      } else {
        // Insertar un nuevo dispositivo
        await FileManager.instance.writeToLog(
            "[DeviceDataSource] Dispositivo nuevo, insertando...\n");

        final insertData = device.toJson()..remove('id');
        await FileManager.instance
            .writeToLog("[DeviceDataSource] Datos a insertar: $insertData\n");

        final response =
            await _client.from(_tableName).insert(insertData).select().single();

        await FileManager.instance.writeToLog(
            "[DeviceDataSource] Dispositivo insertado con ID: ${response['id']}\n");
        return response['id'];
      }
    } catch (e) {
      await FileManager.instance
          .writeToLog("[DeviceDataSource] ERROR registrando dispositivo: $e\n");
      print('Error registrando dispositivo: $e');
      return null;
    }
  }

  @override
  Future<bool> updateLastActive(String deviceId) async {
    try {
      await _client
          .from(_tableName)
          .update({'last_active': DateTime.now().toIso8601String()}).eq(
              'device_id', deviceId);

      return true;
    } catch (e) {
      print('Error actualizando último activo: $e');
      return false;
    }
  }

  @override
  Future<DeviceDto?> getDeviceByDeviceId(String deviceId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('device_id', deviceId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return DeviceDto.fromJson(response);
    } catch (e) {
      print('Error obteniendo dispositivo: $e');
      return null;
    }
  }

  @override
  Future<String?> getDbIdByDeviceId(String deviceId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .eq('device_id', deviceId)
          .maybeSingle();

      return response?['id'];
    } catch (e) {
      print('Error obteniendo ID de base de datos: $e');
      return null;
    }
  }
}
