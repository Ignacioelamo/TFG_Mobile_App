import 'dart:convert';

import 'package:app_permissions_monitor/app_permissions_monitor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/file_manager.dart';


class Controller {
  Controller._privateConstructor();

  static final Controller instance = Controller._privateConstructor();


  //Esto lo haré más adelante
  Future<void> createFiles() async {
    FileManager.instance.createFile(AppConfig.gpsDataFileName);
    String id = "prueba";
    String header = 'id,$id\n\nDate,Hour,Status\n';
    await FileManager.instance.saveFile(AppConfig.gpsDataFileName, header);

    header = 'id:$id\n\n';
    FileManager.instance.createFile(AppConfig.logFileName);
    await FileManager.instance.saveFile(AppConfig.logFileName, header);

    header =
    'id, Date, Time, packageName, groupName, PreviousStatus, CurrentStatus\n';
    FileManager.instance.createFile(AppConfig.permissionsUpdatesFileName);
    await FileManager.instance
        .saveFile(AppConfig.permissionsUpdatesFileName, header);

    header = 'id, Biometric Authentication, LockScreen\n$id,';
    FileManager.instance.createFile(AppConfig.deviceSecurityFileName);
    await FileManager.instance
        .saveFile(AppConfig.deviceSecurityFileName, header);
  }


  Future<bool> handleWorkmanagerTask(String task) async {
    switch (task) {
      case "request_app_permissions_task":
        return await _handleRequestAppPermissionsTask();
      case "detect_app_permissions_changes_task":
        return await handleDetectPermissionsChangesTask();
      default:
        return Future.value(false);
    }
  }

  Future<bool> _handleRequestAppPermissionsTask() async {
    try {
      List<dynamic> appsPermissions =
      await AppPermissionsMonitor().getInstalledAppsPermissionStatuses();
      await FileManager.instance.generatePermissionsGroup(appsPermissions);
      return Future.value(true);
    } catch (e) {
      print('Error requesting app permissions: $e');
      return Future.value(false);
    }
  }

  Future<bool> handleDetectPermissionsChangesTask() async {
    // Obtener la instancia de SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Recuperamos los permisos antiguos guardados como JSON
    String? jsonAntiguoPermiso = prefs.getString(
        AppConfig.sharedPreferencesPermissionsGroupApps);

    // Decodificamos el JSON si existe, o usamos una lista vacía si no hay datos guardados
    List<dynamic> previousPermissions = [];
    if (jsonAntiguoPermiso != null) {
      previousPermissions = jsonDecode(jsonAntiguoPermiso);
    }

    // Obtenemos los permisos nuevos del method channel (se asume que ya tienes implementada esta lógica)
    List<dynamic> actualPermissionsCaller = await AppPermissionsMonitor()
        .getInstalledAppsPermissionStatuses();

    String? jsonActualPermiso = jsonEncode(actualPermissionsCaller);

    List<dynamic> actualPermissions = [];
    actualPermissions = jsonDecode(jsonActualPermiso);

    final List<String> changes = [];

    // Convertimos las listas a mapas para facilitar la comparación por packageName
    final Map<String, Map<String, dynamic>> previousPermissionsMap = {
      for (var item in previousPermissions) item['packageName']: item
    };

    final Map<String, Map<String, dynamic>> actualPermissionsMap = {
      for (var item in actualPermissions) item['packageName']: item
    };

    // Comparamos los permisos actuales con los previos
    actualPermissionsMap.forEach((packageName, actualPermissionStatus) {
      if (previousPermissionsMap.containsKey(packageName)) {
        // Si el paquete existe en ambas listas, comparamos los grupos de permisos
        final Map<String,
            String> previousGroups = previousPermissionsMap[packageName]!['permissionGroups']
            .cast<String, String>();
        final Map<String,
            String> actualGroups = actualPermissionStatus['permissionGroups']
            .cast<String, String>();

        actualGroups.forEach((groupName, actualStatus) {
          final String? previousStatus = previousGroups[groupName];
          if (previousStatus != actualStatus) {
            changes.add(
                "$packageName,$groupName,$previousStatus,$actualStatus");
          }
        });
      } else {
        // Si el paquete no existía antes, todos los permisos son nuevos
        final Map<String,
            String> actualGroups = actualPermissionStatus['permissionGroups']
            .cast<String, String>();

        actualGroups.forEach((groupName, actualStatus) {
          changes.add("$packageName,$groupName,null,$actualStatus");
        });
      }
    });

    // Verificamos si hay paquetes que existían antes pero ya no existen
    previousPermissionsMap.forEach((packageName, previousPermissionStatus) {
      if (!actualPermissionsMap.containsKey(packageName)) {
        final Map<String,
            String> previousGroups = previousPermissionStatus['permissionGroups']
            .cast<String, String>();

        previousGroups.forEach((groupName, previousStatus) {
          changes.add("$packageName,$groupName,$previousStatus,null");
        });
      }
    });

    // Aquí podrías guardar los permisos actuales como JSON en SharedPreferences para futuras comparaciones
    await prefs.setString(AppConfig.sharedPreferencesPermissionsGroupApps,
        jsonEncode(actualPermissions));

    // Imprimir o devolver los cambios detectados
    changes.forEach(print);

    FileManager.instance.updateOldGroupPermissions(changes);
    return Future.value(true);
  }
}