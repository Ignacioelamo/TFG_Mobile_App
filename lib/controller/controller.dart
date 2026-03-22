import 'dart:convert';

import 'package:app_permissions_monitor/app_permissions_monitor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/file_manager.dart';
import '../domain/entities/app_permission_snapshot.dart';
import '../domain/entities/app_use_time.dart';
import '../domain/entities/gps_status.dart';
import '../domain/entities/permission_change.dart';
import '../domain/repositories/device_repository.dart';
import '../domain/repositories/gps_repository.dart';
import '../domain/usecases/save_app_use_times_usecase.dart';
import '../domain/usecases/update_device_updated_usecase.dart';
import '../domain/usecases/save_permission_changes_usecase.dart';
import '../domain/usecases/save_permission_snapshot_usecase.dart';
import '../injection_container.dart' as di;

class Controller {
  Controller._privateConstructor();

  static final Controller instance = Controller._privateConstructor();

  /// Handles tasks executed by Workmanager.
  ///
  /// This function determines which task to execute based on the provided task name.
  /// It supports handling requests for app permissions and detecting permission changes.
  ///
  /// @param task The name of the task to be executed.
  /// \return A Future that resolves to a boolean indicating the success of the task.
  Future<bool> handleWorkmanagerTask(String task) async {
    switch (task) {
      case "retrieve_device_id_task":
        return await _retrieveDeviceId();
      case "write_static_data_task":
        return await _writeStaticData();
      case "create_app_files_task":
        return await _createAppFiles();
      case "request_app_permissions_task":
        return await _handleRequestAppPermissionsTask();
      case "detect_app_permissions_changes_task":
        return await _handleDetectPermissionsChangesTask();
      case "detect_gps_status_changes_task":
        return await _handleDetectGpsStatusChangesTask();
      case "detect_app_use_time_task":
        return await _handleDetectAppUseTimeTask();
      case "update_device_updated_task":
        return await _handleUpdateDeviceUpdatedTask();
      default:
        return Future.value(false);
    }
  }

  /// Retrieves the device ID and stores it in shared preferences.
  ///
  /// This function uses the `AppPermissionsMonitor` to get the device ID and then
  /// stores it in the shared preferences under the key defined in `AppConfig`.
  ///
  /// \return A Future that resolves to a boolean indicating the success of the task.
  Future<bool> _retrieveDeviceId() async {
    final id = await AppPermissionsMonitor().getDeviceId();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.sharedPreferencesIdDevice, id!);
    return true;
  }

  /// Writes static data including device ID and screen lock status.
  /// Also updates the device's 'updated' field (firmware security patch).
  ///
  /// This function calls the `writeStaticData` method of the `FileManager` instance
  /// to perform the task of writing static data, then checks and updates the
  /// firmware updated status. It returns a boolean indicating the success of the operation.
  ///
  /// \return A Future that resolves to a boolean indicating the success of the task.
  Future<bool> _writeStaticData() async {
    final result = await FileManager.instance.writeStaticData();
    await _updateDeviceUpdatedField();
    return result;
  }

  /// Comprueba y actualiza el campo updated (parche de seguridad del firmware).
  /// Se ejecuta en login, en write_static_data y cada día vía update_device_updated_task.
  Future<void> _updateDeviceUpdatedField() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString(AppConfig.sharedPreferencesIdDevice);
      if (deviceId != null && deviceId.isNotEmpty) {
        final updateUpdatedUseCase = di.sl<UpdateDeviceUpdatedUseCase>();
        await updateUpdatedUseCase.execute(deviceId);
      }
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[Controller] Error actualizando campo updated: $e\n");
    }
  }

  /// Tarea periódica: comprueba y actualiza el campo updated una vez al día.
  Future<bool> _handleUpdateDeviceUpdatedTask() async {
    try {
      await FileManager.instance.writeToLog(
          "[UPDATED] Iniciando comprobación del campo updated\n");
      await _updateDeviceUpdatedField();
      await FileManager.instance.writeToLog(
          "[UPDATED] Comprobación del campo updated completada\n");
      return true;
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[UPDATED] Error en tarea update_device_updated: $e\n");
      return false;
    }
  }

  /// Creates necessary files with predefined headers.
  ///
  /// This function initializes the creation of several files required by the application.
  /// Each file is created with a specific header to ensure proper formatting and data structure.
  Future<bool> _createAppFiles() async {
    //Si el archivo ya existe, no hacemos nada  y retornamos true
    if (await FileManager.instance.fileExists(AppConfig.gpsDataFileName) &&
        await FileManager.instance.fileExists(AppConfig.logFileName) &&
        await FileManager.instance
            .fileExists(AppConfig.permissionsUpdatesFileName) &&
        await FileManager.instance
            .fileExists(AppConfig.deviceSecurityFileName) &&
        await FileManager.instance
            .fileExists(AppConfig.appUseTimeFileName)) {
      return Future.value(true);
    }

    // Instance of FileManager to handle file operations.
    final fileManager = FileManager.instance;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final id =
        prefs.getString(AppConfig.sharedPreferencesIdDevice) ?? 'unknown';

    // Headers for different files.
    final gpsHeader = 'id,$id\n\nDate,Hour,Status\n';
    final logHeader = 'id:$id\n\n';
    const permissionsHeader =
        'id, Date, Time, packageName, groupName, PreviousStatus, CurrentStatus\n';
    final securityHeader = 'id,$id\n\nBiometric Authentication, LockScreen\n';
    final appUseTimeHeader = 'id,$id\n\nDate,Time,packageName,MinutesToday\n';

    try {
      // Create and save the GPS data file with its header.
      await fileManager.createFile(AppConfig.gpsDataFileName);
      await fileManager.writeToFile(AppConfig.gpsDataFileName, gpsHeader);

      // Create and save the log file with its header.
      await fileManager.createFile(AppConfig.logFileName);
      await fileManager.writeToFile(AppConfig.logFileName, logHeader);

      // Create and save the permissions updates file with its header.
      await fileManager.createFile(AppConfig.permissionsUpdatesFileName);
      await fileManager.writeToFile(
          AppConfig.permissionsUpdatesFileName, permissionsHeader);

      // Create and save the device security file with its header.
      await fileManager.createFile(AppConfig.deviceSecurityFileName);
      await fileManager.writeToFile(
          AppConfig.deviceSecurityFileName, securityHeader);

      // Create and save the app use time file with its header.
      await fileManager.createFile(AppConfig.appUseTimeFileName);
      await fileManager.writeToFile(
          AppConfig.appUseTimeFileName, appUseTimeHeader);
    } catch (e) {
      // Log the error and return false indicating the task failed.
      await fileManager.writeToLog("$e");
      return Future.value(false);
    }

    return Future.value(true);
  }

  /// Handles the task of requesting app permissions.
  ///
  /// This function retrieves the permission statuses of installed apps, generates
  /// a permissions group CSV using the FileManager, and saves the snapshot to Supabase.
  ///
  /// \return A Future that resolves to a boolean indicating the success of the task.
  Future<bool> _handleRequestAppPermissionsTask() async {
    try {
      // Retrieve the permission statuses of installed apps.
      List<dynamic> appsPermissions =
          await AppPermissionsMonitor().getInstalledAppsPermissionStatuses();

      // Generate a permissions group CSV using the retrieved statuses (local).
      await FileManager.instance.generatePermissionsGroup(appsPermissions);

      // Guardar snapshot en Supabase
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString(AppConfig.sharedPreferencesIdDevice);

      if (deviceId != null && deviceId.isNotEmpty) {
        final deviceRepository = di.sl<DeviceRepository>();
        final deviceDbId =
            await deviceRepository.getDbIdByDeviceId(deviceId);

        if (deviceDbId != null) {
          // Convertir datos del plugin a entidades AppPermissionSnapshot
          final snapshots = _convertToSnapshots(appsPermissions);

          // Guardar en Supabase
          final saveSnapshotUseCase =
              di.sl<SavePermissionSnapshotUseCase>();
          final saved =
              await saveSnapshotUseCase.execute(deviceDbId, snapshots);

          if (saved) {
            await FileManager.instance.writeToLog(
                "[PERMISSIONS] Snapshot inicial guardado en Supabase: ${snapshots.length} apps\n");
          } else {
            await FileManager.instance.writeToLog(
                "[PERMISSIONS] Error al guardar snapshot inicial en Supabase\n");
          }
        } else {
          await FileManager.instance.writeToLog(
              "[PERMISSIONS] No se pudo obtener deviceDbId para guardar en Supabase\n");
        }
      }

      return Future.value(true);
    } catch (e) {
      await FileManager.instance
          .writeToLog("[PERMISSIONS] Error en tarea de permisos inicial: $e\n");
      return Future.value(false);
    }
  }

  /// Detects changes in app permissions and updates the stored permissions data.
  ///
  /// This function compares the current permissions of installed apps with the previously stored permissions.
  /// It identifies any changes in the permissions and logs these changes. The updated permissions data is then
  /// saved back to shared preferences. Also saves changes to Supabase (permission_history) and updates
  /// the current state (permission_status).
  ///
  /// \return A Future that resolves to a boolean indicating the success of the task.
  Future<bool> _handleDetectPermissionsChangesTask() async {
    // Retrieve the shared preferences instance.
    final prefs = await SharedPreferences.getInstance();

    // Get the previously stored permissions data.
    final oldJson =
        prefs.getString(AppConfig.sharedPreferencesPermissionsGroupApps);
    final previousPermissions = oldJson != null ? jsonDecode(oldJson) : [];

    // Get the current permissions data.
    final actualPermissionsCaller =
        await AppPermissionsMonitor().getInstalledAppsPermissionStatuses();
    final actualPermissions = jsonDecode(jsonEncode(actualPermissionsCaller));

    // Create maps for quick lookup of previous and current permissions by package name.
    final previousPermissionsMap = {
      for (var item in previousPermissions) item['packageName']: item
    };
    final actualPermissionsMap = {
      for (var item in actualPermissions) item['packageName']: item
    };

    // List to store detected changes (CSV format for local file).
    final changes = <String>[];

    // Compare current permissions with previous permissions.
    actualPermissionsMap.forEach((packageName, actualPermissionStatus) {
      if (previousPermissionsMap.containsKey(packageName)) {
        final previousGroups =
            previousPermissionsMap[packageName]!['permissionGroups']
                .cast<String, String>();
        final actualGroups =
            actualPermissionStatus['permissionGroups'].cast<String, String>();

        actualGroups.forEach((groupName, actualStatus) {
          final previousStatus = previousGroups[groupName];
          if (previousStatus != actualStatus) {
            changes
                .add("$packageName,$groupName,$previousStatus,$actualStatus");
          }
        });
      } else {
        actualPermissionStatus['permissionGroups']
            .forEach((groupName, actualStatus) {
          changes.add("$packageName,$groupName,null,$actualStatus");
        });
      }
    });

    // Detect removed permissions.
    previousPermissionsMap.forEach((packageName, previousPermissionStatus) {
      if (!actualPermissionsMap.containsKey(packageName)) {
        previousPermissionStatus['permissionGroups']
            .forEach((groupName, previousStatus) {
          changes.add("$packageName,$groupName,$previousStatus,null");
        });
      }
    });

    // Save the updated permissions data back to shared preferences.
    await prefs.setString(AppConfig.sharedPreferencesPermissionsGroupApps,
        jsonEncode(actualPermissions));

    // Guardar en Supabase: snapshot actual + cambios en historial
    try {
      final deviceId = prefs.getString(AppConfig.sharedPreferencesIdDevice);

      if (deviceId != null && deviceId.isNotEmpty) {
        final deviceRepository = di.sl<DeviceRepository>();
        final deviceDbId =
            await deviceRepository.getDbIdByDeviceId(deviceId);

        if (deviceDbId != null) {
          // Actualizar permission_status con el snapshot actual
          final snapshots =
              _convertToSnapshots(actualPermissions as List<dynamic>);
          final saveSnapshotUseCase =
              di.sl<SavePermissionSnapshotUseCase>();
          await saveSnapshotUseCase.execute(deviceDbId, snapshots);

          // Guardar cambios en permission_history
          if (changes.isNotEmpty) {
            final permissionChanges = _convertToPermissionChanges(
                deviceDbId, changes);
            final saveChangesUseCase =
                di.sl<SavePermissionChangesUseCase>();
            final saved = await saveChangesUseCase.execute(
                deviceDbId, permissionChanges);

            if (saved) {
              await FileManager.instance.writeToLog(
                  "[PERMISSIONS] ${permissionChanges.length} cambios guardados en Supabase\n");
            } else {
              await FileManager.instance.writeToLog(
                  "[PERMISSIONS] Error al guardar cambios en Supabase\n");
            }
          }
        }
      }
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[PERMISSIONS] Error guardando en Supabase (continuando con CSV): $e\n");
    }

    if (changes.isEmpty) {
      return true;
    }
    // Update the old group permissions file with the detected changes (local CSV).
    await FileManager.instance.updateOldGroupPermissions(changes);

    // Return true indicating the task was successful.
    return true;
  }

  /// Detects changes in GPS status and updates the stored status.
  ///
  /// This function checks the current GPS status and compares it with the previously stored status.
  /// If a change is detected, it updates the stored status and logs the change.
  ///
  /// \return A Future that resolves to a boolean indicating the success of the task.
  Future<bool> _handleDetectGpsStatusChangesTask() async {
    try {
      await FileManager.instance.writeToLog(
          "[GPS_DEBUG] Iniciando tarea de detección de cambios en GPS\n");

      final prefs = await SharedPreferences.getInstance();
      final lastGpsStatus =
          prefs.getString(AppConfig.sharedPreferencesGpsStatus) ?? 'unknown';

      final isGpsEnabled = await AppPermissionsMonitor().getLocationStatus();
      final currentGpsStatus = isGpsEnabled! ? 'ON' : 'OFF';

      // Independientemente de si hay cambio o no, intentamos obtener el ID de dispositivo
      final deviceId = prefs.getString(AppConfig.sharedPreferencesIdDevice);

      if (lastGpsStatus != currentGpsStatus) {
        await FileManager.instance.writeToLog(
            "[GPS_DEBUG] Se detectó un cambio en el estado del GPS del dispositivo: $deviceId\n");

        await prefs.setString(
            AppConfig.sharedPreferencesGpsStatus, currentGpsStatus);

        // Crear una entidad GpsStatus para guardar en la base de datos
        final deviceRepository = di.sl<DeviceRepository>();

        final deviceDbId = await deviceRepository.getDbIdByDeviceId(deviceId!);

        if (deviceDbId == null) {
          await FileManager.instance.writeToLog(
              "[GPS] Error: No se pudo obtener el ID de base de datos para el dispositivo\n");
          return false;
        }

        final gpsStatus = GpsStatus(
          deviceId: deviceDbId, // Usamos el UUID interno
          status: currentGpsStatus,
          startTime: DateTime.now(),
        );

        // Obtener la instancia del repositorio usando la inyección de dependencias
        final gpsRepository = di.sl<GpsRepository>();

        // Guardar el nuevo estado
        await gpsRepository.saveGpsStatus(gpsStatus);

        // También guardar en el archivo local para compatibilidad
        final now = DateTime.now();
        final formattedDate = '${now.year}-${now.month}-${now.day}';
        final formattedTime = '${now.hour}:${now.minute}:${now.second}';
        final content = '$formattedDate,$formattedTime,$currentGpsStatus\n';
        await FileManager.instance
            .writeToFile(AppConfig.gpsDataFileName, content);

        await FileManager.instance
            .writeToLog("[GPS] Estado actualizado a: $currentGpsStatus\n");
      } else {
        await FileManager.instance
            .writeToLog("[GPS_DEBUG] No hubo cambio en el estado del GPS\n");
      }

      await FileManager.instance
          .writeToLog("[GPS_DEBUG] Tarea de detección de GPS completada\n");
      return true;
    } catch (e) {
      await FileManager.instance
          .writeToLog("[GPS_DEBUG] Error en la tarea de detección: $e\n");
      await FileManager.instance.writeToLog("[GPS] Error: $e\n");
      return false;
    }
  }

  /// Detecta y registra el tiempo de uso de aplicaciones para el día actual.
  ///
  /// Esta función obtiene las estadísticas de uso del día actual mediante el plugin
  /// AppPermissionsMonitor, construye entidades AppUseTime y las guarda en Supabase
  /// y en el archivo CSV local.
  ///
  /// \return Un Future que resuelve a un booleano indicando el éxito de la tarea.
  Future<bool> _handleDetectAppUseTimeTask() async {
    try {
      await FileManager.instance.writeToLog(
          "[APP_USE_TIME] Iniciando recogida de tiempo de uso de aplicaciones\n");

      final prefs = await SharedPreferences.getInstance();

      // Comprobar usuario logueado y deviceId disponible
      final deviceId = prefs.getString(AppConfig.sharedPreferencesIdDevice);
      if (deviceId == null || deviceId.isEmpty) {
        await FileManager.instance.writeToLog(
            "[APP_USE_TIME] Error: No hay deviceId disponible en SharedPreferences\n");
        return false;
      }

      // Comprobar permiso de UsageStats
      final hasPermission =
          await AppPermissionsMonitor().hasUsageStatsPermission();
      if (hasPermission != true) {
        await FileManager.instance.writeToLog(
            "[APP_USE_TIME] Permiso de estadísticas de uso no concedido. Abortando.\n");
        return false;
      }

      // Obtener lista de apps + minutos mediante el plugin
      final usageData = await AppPermissionsMonitor().getAppUsageToday();

      if (usageData.isEmpty) {
        await FileManager.instance.writeToLog(
            "[APP_USE_TIME] No se obtuvieron datos de uso de aplicaciones\n");
        return true;
      }

      await FileManager.instance.writeToLog(
          "[APP_USE_TIME] Obtenidos datos de uso para ${usageData.length} aplicaciones\n");

      // Obtener UUID del dispositivo en Supabase
      final deviceRepository = di.sl<DeviceRepository>();
      final deviceDbId = await deviceRepository.getDbIdByDeviceId(deviceId);

      if (deviceDbId == null) {
        await FileManager.instance.writeToLog(
            "[APP_USE_TIME] Error: No se pudo obtener el ID de base de datos para el dispositivo\n");
        return false;
      }

      // Construir lista de entidades AppUseTime
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final List<AppUseTime> appUseTimeList = [];

      for (var entry in usageData) {
        final packageName = entry['packageName'] as String?;
        final minutes = (entry['minutes'] as num?)?.toDouble();

        if (packageName != null && minutes != null && minutes > 0) {
          appUseTimeList.add(AppUseTime(
            deviceId: deviceDbId,
            packageName: packageName,
            date: today,
            minutes: minutes,
          ));
        }
      }

      if (appUseTimeList.isEmpty) {
        await FileManager.instance.writeToLog(
            "[APP_USE_TIME] No hay registros válidos para guardar\n");
        return true;
      }

      // Guardar en Supabase con SaveAppUseTimesUseCase
      final saveUseCase = di.sl<SaveAppUseTimesUseCase>();
      final saved = await saveUseCase.execute(appUseTimeList);

      if (saved) {
        await FileManager.instance.writeToLog(
            "[APP_USE_TIME] Guardados ${appUseTimeList.length} registros en Supabase\n");
      } else {
        await FileManager.instance.writeToLog(
            "[APP_USE_TIME] Error al guardar registros en Supabase\n");
      }

      // Guardar en CSV local
      await FileManager.instance
          .writeAppUseTimeSnapshot(appUseTimeList);
      await FileManager.instance.writeToLog(
          "[APP_USE_TIME] Registros escritos en CSV local\n");

      // Actualizar fecha de última recogida en SharedPreferences
      await prefs.setString(
          AppConfig.sharedPreferencesLastAppUseTimeCollection,
          now.toIso8601String());

      await FileManager.instance.writeToLog(
          "[APP_USE_TIME] Tarea de recogida de tiempo de uso completada\n");
      return true;
    } catch (e) {
      await FileManager.instance.writeToLog(
          "[APP_USE_TIME] Error en la tarea de recogida: $e\n");
      return false;
    }
  }

  /// Convierte los datos crudos del plugin a una lista de AppPermissionSnapshot.
  ///
  /// [appsPermissions] es la lista dinámica devuelta por el plugin con formato:
  /// [{'packageName': '...', 'permissionGroups': {'LOCATION': 'Always', ...}}, ...]
  List<AppPermissionSnapshot> _convertToSnapshots(
      List<dynamic> appsPermissions) {
    return appsPermissions.map((app) {
      final packageName = app['packageName'] as String;
      final groups = Map<String, String>.from(
          (app['permissionGroups'] as Map).cast<String, String>());
      return AppPermissionSnapshot(
        packageName: packageName,
        permissionStatuses: groups,
      );
    }).toList();
  }

  /// Convierte las cadenas de cambios detectados a entidades PermissionChange.
  ///
  /// Cada cadena tiene formato: "packageName,groupName,previousStatus,newStatus"
  /// [deviceDbId] es el UUID del dispositivo en Supabase
  /// [changes] es la lista de cadenas con los cambios detectados
  List<PermissionChange> _convertToPermissionChanges(
      String deviceDbId, List<String> changes) {
    final permissionChanges = <PermissionChange>[];

    for (var change in changes) {
      final parts = change.split(',');
      if (parts.length != 4) continue;

      permissionChanges.add(PermissionChange(
        deviceId: deviceDbId,
        packageName: parts[0],
        permissionGroup: parts[1],
        previousStatus: parts[2] == 'null' ? null : parts[2],
        newStatus: parts[3],
        changedAt: DateTime.now(),
      ));
    }

    return permissionChanges;
  }
}
