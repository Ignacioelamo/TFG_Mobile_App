import 'fileManager.dart';

class Contraller {
  Contraller._privateConstructor();
  static final Contraller instance = Contraller._privateConstructor();

  Future <void> openFile(String fileName) async {
    await FileManager.instance.openFile(fileName);
  }

  Future <void> clearFile(String fileName) async {
    await FileManager.instance.clearFile(fileName);
  }

  

}