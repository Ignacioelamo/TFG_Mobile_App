import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import 'file_manager.dart';
import 'permission_manager.dart';
import 'subscription_manager.dart';
import 'app_config.dart';

class Controller {
  Controller._privateConstructor();
  static final Controller instance = Controller._privateConstructor();

  Future<void> openFile(String fileName) async {
    await FileManager.instance.openFile(fileName);
  }

  Future<void> clearFile(String fileName) async {
    await FileManager.instance.clearFile(fileName);
  }

  Future<bool> requestPermission() async =>
      await PermissionManager.instance.requestPermissions();

  Future<void> getAllAppsPermissionsGroup() async {
    try {
      var result = await AppConfig.channel
          .invokeMethod(AppConfig.getAppPermissionStatusesMethod);

      // Verificar si el resultado es una lista de mapas
      if (result is List) {
        FileManager.instance.generatePermissionsGroup(result);
      } else {
        print("El resultado no es del tipo esperado");
      }
    } catch (e) {
      print("Error al obtener permisos: $e");
    }
  }

  Future<void> detectAppsPermissionsChanges() async {
    var permisosAntiguos =
        await FileManager.instance.getOldGroupPermissions(); // Await the Future
    try {
      var result = await AppConfig.channel.invokeMethod(
          AppConfig.detectPermissionsChangesMethod,
          {'oldPermissions': permisosAntiguos});

      if (result is List) {
        if (result.isNotEmpty) {
          List<String> newPermissions =
              List<String>.from(result.map((x) => x.toString()));
          FileManager.instance.updateOldGroupPermissions(newPermissions);
        } else {
          print("No hay cambios en los permisos");
        }
      } else {
        print("El resultado no es del tipo esperado");
      }
    } catch (e) {
      print("Error al obtener permisos: $e");
    }
  }

  Future<String> generateOrRetrieveDeviceId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(AppConfig.sharedPreferencesIdDevice);

    if (deviceId == null) {
      deviceId =
          await AppConfig.channel.invokeMethod(AppConfig.getDeviceIdMethod);
      await prefs.setString(AppConfig.sharedPreferencesIdDevice, deviceId!);
    }

    return deviceId;
  }
/*
  Future<void> subscribeToGpsChanges() async {
    SubscriptionManager.instance.subscribeToGpsChanges();
  }
*/
  Future<void> createFiles() async {
    FileManager.instance.createFile(AppConfig.gpsDataFileName);
    String id = await generateOrRetrieveDeviceId();
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

  Future<void> getScreenLockType() async {
    try {
      // Inicializa la autenticación local
      final LocalAuthentication localAuth = LocalAuthentication();

      // Verifica los tipos de biometría configurados
      List<BiometricType> availableBiometrics =
          await localAuth.getAvailableBiometrics();
      String biometricAuth = availableBiometrics.isNotEmpty ? 'Yes' : 'No';

      // Invoca el método del canal para determinar el tipo de bloqueo de pantalla
      var result = await AppConfig.channel
          .invokeMethod(AppConfig.getIfScreenLockedMethod);
      String lockScreen = (result == true) ? 'Yes' : 'No';

      // Prepara el contenido en formato CSV
      String content = '$biometricAuth, $lockScreen';

      // Guarda el contenido en el archivo de seguridad del dispositivo
      await FileManager.instance
          .saveFile(AppConfig.deviceSecurityFileName, content);
    } catch (e) {
      print("Error al obtener el tipo de bloqueo de pantalla: $e");
    }
  }
}
