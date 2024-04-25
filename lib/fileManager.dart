import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';

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
    createFile('idDevice.txt');
    String id = await MethodChannel('flutter_channel').invokeMethod('getDeviceId');
    saveFile('idDevice.txt', id);
    print("El id del dispostivo es: $id");
  }
}