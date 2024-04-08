
import 'fileManager.dart';
import 'permissionManager.dart';

class Controller {
  Controller._privateConstructor();
  static final Controller instance = Controller._privateConstructor();

  Future <void> openFile(String fileName) async {
    await FileManager.instance.openFile(fileName);
  }

  Future <void> clearFile(String fileName) async {
    await FileManager.instance.clearFile(fileName);
  }

  Future <bool> requestPermission() async => await PermissionManager.instance.requestPermissions();
}