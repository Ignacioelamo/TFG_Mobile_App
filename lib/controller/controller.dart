import 'dart:convert';

import 'package:app_permissions_monitor/app_permissions_monitor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/file_manager.dart';

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
  ///
  /// This function calls the `writeStaticData` method of the `FileManager` instance
  /// to perform the task of writing static data. It returns a boolean indicating
  /// the success of the operation.
  ///
  /// \return A Future that resolves to a boolean indicating the success of the task.
  Future<bool> _writeStaticData() async {
    return await FileManager.instance.writeStaticData();
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
            .fileExists(AppConfig.deviceSecurityFileName)) {
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
    } catch (e) {
      // Log the error and return false indicating the task failed.
      await fileManager.writeToLog("$e");
      return Future.value(false);
    }

    return Future.value(true);
  }

  /// Handles the task of requesting app permissions.
  ///
  /// This function retrieves the permission statuses of installed apps and generates
  /// a permissions group using the FileManager. If an error occurs during the process,
  /// it logs the error and returns false.
  ///
  /// \return A Future that resolves to a boolean indicating the success of the task.
  Future<bool> _handleRequestAppPermissionsTask() async {
    try {
      // Retrieve the permission statuses of installed apps.
      List<dynamic> appsPermissions =
          await AppPermissionsMonitor().getInstalledAppsPermissionStatuses();

      // Generate a permissions group using the retrieved statuses.
      await FileManager.instance.generatePermissionsGroup(appsPermissions);

      // Return true indicating the task was successful.
      return Future.value(true);
    } catch (e) {
      // Log the error and return false indicating the task failed.
      await FileManager.instance.writeToLog("$e");
      return Future.value(false);
    }
  }

  /// Detects changes in app permissions and updates the stored permissions data.
  ///
  /// This function compares the current permissions of installed apps with the previously stored permissions.
  /// It identifies any changes in the permissions and logs these changes. The updated permissions data is then
  /// saved back to shared preferences.
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

    // List to store detected changes.
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

    // Log the detected changes.
    changes.forEach(print);

    if (changes.isEmpty) {
      return true;
    }
    // Update the old group permissions file with the detected changes.
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
      final prefs = await SharedPreferences.getInstance();
      final lastGpsStatus =
          prefs.getString(AppConfig.sharedPreferencesGpsStatus) ?? 'unknown';

      final isGpsEnabled = await AppPermissionsMonitor().getLocationStatus();
      final currentGpsStatus = isGpsEnabled! ? 'enabled' : 'disabled';

      if (lastGpsStatus != currentGpsStatus) {
        await prefs.setString(
            AppConfig.sharedPreferencesGpsStatus, currentGpsStatus);

        final now = DateTime.now();
        final formattedDate = '${now.year}-${now.month}-${now.day}';
        final formattedTime = '${now.hour}:${now.minute}:${now.second}';
        final content = '$formattedDate,$formattedTime,$currentGpsStatus\n';
        await FileManager.instance
            .writeToFile(AppConfig.gpsDataFileName, content);
      }
      return true;
    } catch (e) {
      await FileManager.instance.writeToLog("$e");
      return false;
    }
  }
}