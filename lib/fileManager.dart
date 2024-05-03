import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appConfig.dart';
import 'tools.dart';

class FileManager{

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
    print('Creating file: $filePath');
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

  Future<void> generateIDDevice() async {

    if (await _fileExists(AppConfig.idDeviceFileName) == false){
      createFile(AppConfig.idDeviceFileName);
      String id = await const MethodChannel('flutter_channel').invokeMethod('getDeviceId');
      saveFile('idDevice.txt', id);
      print("El id del dispostivo es: $id");
    }else{
      print("El archivo ya existe");
    }


  }
  Future<void> generatePermissionsGroup(List<dynamic> result) async {

    if (await _fileExists(AppConfig.permissionsGroupFileName) == false) {
      final sharedPrefs = await SharedPreferences.getInstance();

      //Serializamos la lista de mapas de permisos a JSON
      sharedPrefs.setString('permissions', jsonEncode(result));

      await createFile('groupPermissions.csv');
      // Leer el ID del dispositivo
      var id = await readFromFile(AppConfig.idDeviceFileName) as String;
      await writeToFile('groupPermissions.csv', 'Device ID,$id\n\n');  // Añadir un salto de línea para separar el ID

      // Escribir encabezados para las aplicaciones
      var header = 'Permission';  // Iniciar con el encabezado de permisos
      for (var app in result) {
        header += ',${app['packageName']}';  // Asegurarse de que 'appName' es el campo correcto
      }
      await writeToFile('groupPermissions.csv', header + '\n');

      // Escribir cada fila de permiso
      for (var permission in Tools.instance.permissionGroups) {
        var row = permission;
        for (var app in result) {
          var permissionStatus = (app['permissionGroups'] as Map)[permission] ?? 'Not requested';
          row += ',$permissionStatus';
        }
        await writeToFile('groupPermissions.csv', row + '\n');
    }
    }else{
      print("El archivo ya existe");
    }
  }

  Future<List<Map<String, dynamic>>> getOldGroupPermissions() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    String? json = sharedPrefs.getString('permissions');
    if (json == null) {
      print('No se encontraron permisos en el almacenamiento local');
      return [];
    }else{
      return List<Map<String, dynamic>>.from(jsonDecode(json).map((x) => Map<String, dynamic>.from(x)));
    }
  }





/*
  Future<void> generatePermissionsGroup(var result) async {
    createFile('permissionsGroup.txt');
    String id = await MethodChannel('flutter_channel').invokeMethod('getDeviceId');
    saveFile('idDevice.txt', id);
    print("El id del dispostivo es: $id");
  }*/
}