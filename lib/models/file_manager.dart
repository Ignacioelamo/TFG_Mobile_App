import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
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
    if (await _fileExists(AppConfig.logFileName) == false) {
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

  Future<void> saveFile(String fileName, String content) async {
    await writeToFile(fileName, content);
  }

  Future<void> createFile(String fileName) async {
    if (await _fileExists(fileName)) {
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

  Future<bool> _fileExists(String fileName) async {
    String filePath = await getFilePath(fileName);
    File file = File(filePath);
    return file.exists();
  }

  Future<void> generatePermissionsGroup(List<dynamic> result) async {
    if (await _fileExists(AppConfig.permissionsGroupFileName) == false) {
      final sharedPrefs = await SharedPreferences.getInstance();
      // Serializar la lista de mapas de permisos a JSON
      String json = jsonEncode(result);
      //Serializamos la lista de mapas de permisos a JSON
      sharedPrefs.setString(
          AppConfig.sharedPreferencesPermissionsGroupApps, json);

      await createFile('groupPermissions.csv');
      // Leer el ID del dispositivo
      var id = sharedPrefs.getString(AppConfig.sharedPreferencesIdDevice);
      await writeToFile('groupPermissions.csv',
          'Device ID,$id\n\n'); // Añadir un salto de línea para separar el ID

      // Escribir encabezados para las aplicaciones
      var header = 'Permission'; // Iniciar con el encabezado de permisos
      for (var app in result) {
        header +=
            ',${app['packageName']}'; // Asegurarse de que 'appName' es el campo correcto
      }
      await writeToFile('groupPermissions.csv', '$header\n');

      // Escribir cada fila de permiso
      for (var permission in AppConfig.instance.permissionGroups) {
        var row = permission;
        for (var app in result) {
          var permissionStatus = (app['permissionGroups'] as Map)[permission];
          row += ',$permissionStatus';
        }
        await writeToFile('groupPermissions.csv', '$row\n');
      }
    } else {
      if (kDebugMode) {
        print("El archivo ya existe");
      }
    }
  }

  Future<List<Map<String, dynamic>>> getOldGroupPermissions() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    String? json =
        sharedPrefs.getString(AppConfig.sharedPreferencesPermissionsGroupApps);
    if (json == null) {
      if (kDebugMode) {
        print('No se encontraron permisos en el almacenamiento local');
      }
      return [];
    } else {
      return List<Map<String, dynamic>>.from(
          jsonDecode(json).map((x) => Map<String, dynamic>.from(x)));
    }
  }

  Future<void> updateOldGroupPermissions(List<String> newPermissions) async {
    FileManager.instance.createFile(AppConfig.permissionsUpdatesFileName);

    final id = "idPrueba";
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd,HH:mm:ss');
    final String formattedDate = formatter.format(now);

    List<String> updates = [];

    for (String permissionUpdate in newPermissions) {
      List<String> parts = permissionUpdate.split(',');
      if (parts.length != 4) {
        continue; // Saltar si el formato no es correcto
      }
      String packageName = parts[0];
      String permissionName = parts[1];
      String oldStatus = parts[2]; // Estado anterior del permiso
      String newStatus = parts[3]; // Nuevo estado del permiso

      // Registrar el cambio
      updates.add(
          '$id,$formattedDate,$packageName,$permissionName,$oldStatus,$newStatus');
    }

    if (updates.isNotEmpty) {
      await _updatePermissionUpdatesFile(updates);
    }
  }

  Future<void> _updatePermissionUpdatesFile(List<String> updates) async {


    for (String update in updates) {
      await FileManager.instance.writeToFile(AppConfig.permissionsUpdatesFileName, '$update\n');
    }
  }
}
