import 'package:flutter/services.dart';

class AppPermissionManager {

  AppPermissionManager._privateConstructor();
  static final AppPermissionManager instance = AppPermissionManager._privateConstructor();

  //static const MethodChannel _channel = MethodChannel("com.example.app_permissions");



  void printAllAppPermissions() async {
    // Crear una instancia de AppPermissionManager
    const channel = MethodChannel('flutter_channel');
    String prueba = await channel.invokeMethod('prueba');
    print(prueba);
  }

}


