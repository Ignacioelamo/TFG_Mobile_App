import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/datasources/device_datasource.dart';
import 'data/datasources/gps_datasource.dart';
import 'data/datasources/security_datasource.dart';
import 'data/repositories/device_repository_impl.dart';
import 'data/repositories/gps_repository_impl.dart';
import 'data/repositories/security_repository_impl.dart';
import 'domain/repositories/device_repository.dart';
import 'domain/repositories/gps_repository.dart';
import 'domain/repositories/security_repository.dart';
import 'domain/usecases/get_last_gps_status_usecase.dart';
import 'domain/usecases/get_last_security_info_usecase.dart';
import 'domain/usecases/register_device_usecase.dart';
import 'domain/usecases/save_gps_status_usecase.dart';
import 'domain/usecases/save_security_info_usecase.dart';
import 'domain/usecases/update_last_active_usecase.dart';

/// Instancia global del servicio de inyección de dependencias
final sl = GetIt.instance;

/// Inicializa todas las dependencias del contenedor de inyección
Future<void> init() async {
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
}
