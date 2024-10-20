import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_permissions_monitor/app_permissions_monitor.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class FileManager {
  FileManager._privateConstructor();

  static final FileManager instance = FileManager._privateConstructor();



  Future<String> getFilePath(String fileName) async {
    Directory? appDocDir = await getExternalStorageDirectory();
    String? appDocPath = appDocDir?.path;
    return '$appDocPath/$fileName';
  }

  Future<void> writeToFile(String fileName, String content) async {
    String filePath = await getFilePath(fileName);
    File file = File(filePath);
    await file.writeAsString(content, mode: FileMode.append);
  }

  Future<void> writeToLog(String content) async {
    if (await fileExists(AppConfig.logFileName) == false) {
      await createFile(AppConfig.logFileName);
    }
    await writeToFile(AppConfig.logFileName, content);
  }

  Future<String> readFromFile(String fileName) async {
    String filePath = await getFilePath(fileName);
    File file = File(filePath);
    return await file.readAsString();
  }

  Future<void> openFile(String fileName) async {
    String filePath = await getFilePath(fileName);
    await OpenFile.open(filePath);
  }

  Future<void> createFile(String fileName) async {
    if (await fileExists(fileName)) {
      return;
    }

    String filePath = await getFilePath(fileName);
    File file = File(filePath);
    if (kDebugMode) {
      print('Creating file: $filePath');
    }
    await file.create();
  }

  Future<void> deleteFile(String fileName) async {
    String filePath = await getFilePath(fileName);
    File file = File(filePath);
    await file.delete();
  }

  Future<void> deleteFiles() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    await appDocDir.delete(recursive: true);
  }

  Future<void> clearFile(String fileName) async {
    String filePath = await getFilePath(fileName);
    File file = File(filePath);
    await file.writeAsString('');
  }

  // Clear all files in the app directory
  Future<void> clearFiles() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = appDocDir.listSync();
    for (FileSystemEntity file in files) {
      if (file is File) {
        await file.writeAsString('');
      }
    }
  }

  Future<bool> fileExists(String fileName) async {
    String filePath = await getFilePath(fileName);
    File file = File(filePath);
    return file.exists();
  }

  /// Generates a permissions group file based on the provided result.
  ///
  /// This function checks if the permissions group file exists. If it does not, it creates the file,
  /// saves the permissions data to shared preferences, and writes the permissions data to a CSV file.
  /// The CSV file includes a header row with the device ID and package names, followed by rows for each
  /// permission group and their statuses for each app.
  ///
  /// \param result A list of dynamic objects representing the permissions data for installed apps.
  /// \return A Future that completes when the permissions group file has been generated.
  Future<void> generatePermissionsGroup(List<dynamic> result) async {
    // Check if the permissions group file exists.
    if (!await fileExists(AppConfig.permissionsGroupFileName)) {
      // Get shared preferences instance and save the permissions data as a JSON string.
      final sharedPrefs = await SharedPreferences.getInstance();
      final json = jsonEncode(result);
      sharedPrefs.setString(
          AppConfig.sharedPreferencesPermissionsGroupApps, json);

      // Create the permissions group CSV file.
      await createFile('groupPermissions.csv');
      final id = sharedPrefs.getString(AppConfig.sharedPreferencesIdDevice);
      await writeToFile('groupPermissions.csv', 'Device ID,$id\n\n');

      // Write the header row with the package names.
      final header =
          'Permission${result.map((app) => ',${app['packageName']}').join()}';
      await writeToFile('groupPermissions.csv', '$header\n');

      // Write rows for each permission group and their statuses for each app.
      for (var permission in AppConfig.instance.permissionGroups) {
        final row = permission +
            result
                .map(
                    (app) => ',${(app['permissionGroups'] as Map)[permission]}')
                .join();
        await writeToFile('groupPermissions.csv', '$row\n');
      }
    } else {
      // Log a message if the file already exists.
      if (kDebugMode) {
        print("Permissions group file already exists");
      }
    }
  }

  /// Retrieves the old group permissions from shared preferences.
  ///
  /// This function fetches the stored permissions data from shared preferences, decodes the JSON string,
  /// and converts it into a list of maps. If no permissions data is found, it logs a message in debug mode
  /// and returns an empty list.
  ///
  /// \return A Future that completes with a list of maps representing the old group permissions.
  Future<List<Map<String, dynamic>>> getOldGroupPermissions() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final json =
        sharedPrefs.getString(AppConfig.sharedPreferencesPermissionsGroupApps);
    if (json == null) {
      if (kDebugMode) {
        print('Permissions group data not found in shared preferences');
      }
      return [];
    }
    return List<Map<String, dynamic>>.from(
        jsonDecode(json).map((x) => Map<String, dynamic>.from(x)));
  }

  /// Updates the old group permissions with new permissions.
  ///
  /// This function creates a file to store permission updates, formats the current date and time,
  /// and processes the new permissions to record any changes. If the format of a permission update
  /// is incorrect, it skips that update. Finally, it updates the permissions file if there are any changes.
  ///
  /// \param newPermissions A list of strings representing the new permissions in the format
  ///        'packageName,permissionName,oldStatus,newStatus'.
  /// \return A Future that completes when the permissions have been updated.
  Future<void> updateOldGroupPermissions(List<String> newPermissions) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Define a constant ID and get the current date and time.
    final id = prefs.getString(AppConfig.sharedPreferencesIdDevice);
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd,HH:mm:ss');
    final String formattedDate = formatter.format(now);

    // List to store the formatted updates.
    List<String> updates = [];

    // Process each permission update.
    for (String permissionUpdate in newPermissions) {
      List<String> parts = permissionUpdate.split(',');
      if (parts.length != 4) {
        continue; // Skip if the format is incorrect.
      }
      String packageName = parts[0];
      String permissionName = parts[1];
      String oldStatus = parts[2]; // Previous permission status.
      String newStatus = parts[3]; // New permission status.

      // Record the change.
      updates.add(
          '$id,$formattedDate,$packageName,$permissionName,$oldStatus,$newStatus');
    }

    // Update the permissions file if there are any changes.
    if (updates.isNotEmpty) {
      await _updatePermissionUpdatesFile(updates);
    }
  }

  /// Writes the permission updates to the specified file.
  ///
  /// This function iterates over a list of permission updates and writes each update
  /// to the permissions updates file. Each update is written on a new line.
  ///
  /// \param updates A list of strings, where each string represents a permission update.
  Future<void> _updatePermissionUpdatesFile(List<String> updates) async {
    for (var update in updates) {
      await writeToFile(AppConfig.permissionsUpdatesFileName, '$update\n');
    }
  }

  /// Writes static data including device ID and screen lock status.
  ///
  /// This function retrieves the device ID and stores it in shared preferences,
  /// then retrieves the screen lock status and writes it to a file. It returns
  /// a boolean indicating the success of these operations.
  ///
  /// \return A Future that resolves to a boolean indicating the success of the task.
  Future<bool> writeStaticData() async {
    try {
      // Get the screen lock status and write it to a file.
      await _getScreenLockStatus();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Retrieves the screen lock status and writes it to a file.
  ///
  /// This function uses the `LocalAuthentication` package to check for available biometrics
  /// and the `AppPermissionsMonitor` to get the screen lock type. It then writes the results
  /// to a file specified in `AppConfig.deviceSecurityFileName`.
  ///
  /// \return A Future that resolves to a boolean indicating the success of the task.
  Future<bool> _getScreenLockStatus() async {
    try {
      // Initialize local authentication.
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final deviceInfo = prefs.getBool(AppConfig.sharedPreferencesDeviceSecurity);
      //Si existe el archivo no hacemos nada y devolvemos true
      if (deviceInfo == true) {
        return true;
      }

      final localAuth = LocalAuthentication();

      bool canCheckBiometrics = await localAuth.canCheckBiometrics;
      bool isDeviceSecure = await localAuth.isDeviceSupported();



      final biometricAuth = canCheckBiometrics && isDeviceSecure ? 'Yes' : 'No';

      // Get screen lock type.
      final result = await AppPermissionsMonitor().getScreenLockType();
      final screenLockType = result == true ? 'Yes' : 'No';
      final content = '$biometricAuth, $screenLockType';

      // Write the results to a file.
      await FileManager.instance
          .writeToFile(AppConfig.deviceSecurityFileName, content);

      prefs.setBool(AppConfig.sharedPreferencesDeviceSecurity, true);

      // Define a constant ID and get the current date and time.

      return true;
    } catch (e) {
      return false;
    }
  }

}
