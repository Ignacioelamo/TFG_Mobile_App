import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

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
    await openFile(fileName);
  }



  Future<void> createFile(String fileName) async {
    if (await fileExists(fileName)) {
      return;
    }

    String filePath = await getFilePath(fileName);
    File file = File(filePath);
    await file.create();
  }

  Future<void> deleteFile(String fileName) async {
    String filePath = await getFilePath(fileName);
    File file = File(filePath);
    await file.delete();
  }

  Future<void> clearFile(String fileName) async {
    String filePath = await getFilePath(fileName);
    File file = File(filePath);
    await file.writeAsString('');
  }

  Future<void> clearFiles() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    await appDocDir.delete(recursive: true);
  }

  Future<bool> fileExists(String fileName) async {
    String filePath = await getFilePath(fileName);
    File file = File(filePath);
    return file.exists();
  }
}