import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/datasources/app_use_time_datasource.dart';
import 'data/datasources/device_datasource.dart';
import 'data/datasources/gps_datasource.dart';
import 'data/datasources/security_datasource.dart';
import 'data/repositories/app_use_time_repository_impl.dart';
import 'data/repositories/device_repository_impl.dart';
import 'data/repositories/gps_repository_impl.dart';
import 'data/repositories/security_repository_impl.dart';
import 'domain/repositories/app_use_time_repository.dart';
import 'domain/repositories/device_repository.dart';
import 'domain/repositories/gps_repository.dart';
import 'domain/repositories/security_repository.dart';
import 'domain/usecases/get_last_gps_status_usecase.dart';
import 'domain/usecases/get_last_security_info_usecase.dart';
import 'domain/usecases/register_device_usecase.dart';
import 'domain/usecases/save_app_use_times_usecase.dart';
import 'domain/usecases/save_gps_status_usecase.dart';
import 'domain/usecases/save_security_info_usecase.dart';
import 'domain/usecases/update_last_active_usecase.dart';
import 'models/file_manager.dart';

/// Instancia global del servicio de inyección de dependencias
final sl = GetIt.instance;

/// Inicializa todas las dependencias del contenedor de inyección
Future<void> init() async {
  try {
    await FileManager.instance
        .writeToLog("[DI] Iniciando registro de dependencias\n");

    // Servicios externos
    final supabase = Supabase.instance.client;

    // DataSources
    sl.registerLazySingleton<DeviceDataSource>(
      () => SupabaseDeviceDataSource(supabase),
    );

    sl.registerLazySingleton<GpsDataSource>(
      () => SupabaseGpsDataSource(supabase),
    );

    sl.registerLazySingleton<SecurityDataSource>(
      () => SupabaseSecurityDataSource(supabase),
    );

    sl.registerLazySingleton<AppUseTimeDataSource>(
      () => SupabaseAppUseTimeDataSource(supabase),
    );

    // Repositorios
    sl.registerLazySingleton<DeviceRepository>(
      () => DeviceRepositoryImpl(sl<DeviceDataSource>()),
    );

    sl.registerLazySingleton<GpsRepository>(
      () => GpsRepositoryImpl(sl<GpsDataSource>()),
    );

    sl.registerLazySingleton<SecurityRepository>(
      () => SecurityRepositoryImpl(sl<SecurityDataSource>()),
    );

    sl.registerLazySingleton<AppUseTimeRepository>(
      () => AppUseTimeRepositoryImpl(sl<AppUseTimeDataSource>()),
    );

    // Casos de uso
    sl.registerLazySingleton(
      () => RegisterDeviceUseCase(sl<DeviceRepository>()),
    );

    sl.registerLazySingleton(
      () => UpdateLastActiveUseCase(sl<DeviceRepository>()),
    );

    sl.registerLazySingleton(
      () => SaveGpsStatusUseCase(sl<GpsRepository>()),
    );

    sl.registerLazySingleton(
      () => GetLastGpsStatusUseCase(sl<GpsRepository>()),
    );

    sl.registerLazySingleton(
      () => SaveSecurityInfoUseCase(sl<SecurityRepository>()),
    );

    sl.registerLazySingleton(
      () => GetLastSecurityInfoUseCase(sl<SecurityRepository>()),
    );

    sl.registerLazySingleton(
      () => SaveAppUseTimesUseCase(sl<AppUseTimeRepository>()),
    );

    await FileManager.instance
        .writeToLog("[DI] Todas las dependencias registradas correctamente\n");
  } catch (e) {
    await FileManager.instance
        .writeToLog("[DI] Error registrando dependencias: $e\n");
    print("Error en init de dependency injection: $e");
    rethrow;
  }
}
