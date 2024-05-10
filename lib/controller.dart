import 'file_manager.dart';
import 'permission_manager.dart';
import 'subscription_manager.dart';
import 'app_config.dart';

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





  Future<void> getAllAppsPermissionsGroup() async {
    try {
      var result = await AppConfig.channel.invokeMethod(AppConfig.getAppPermissionStatusesMethod);

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
    var permisosAntiguos = await FileManager.instance.getOldGroupPermissions(); // Await the Future
    try {
      var result = await AppConfig.channel.invokeMethod(AppConfig.detectPermissionsChangesMethod, {'oldPermissions': permisosAntiguos});

      if (result is List) {
        if (result.isNotEmpty) {
          List<String> newPermissions = List<String>.from(result.map((x) => x.toString()));
          FileManager.instance.updateOldGroupPermissions(newPermissions);
        }
      } else {
        print("El resultado no es del tipo esperado");
      }
    } catch (e) {
      print("Error al obtener permisos: $e");
    }
  }







  Future<void> generateIDDevice() async {
    String idDevice = await AppConfig.channel.invokeMethod(AppConfig.getDeviceIdMethod);
    print('ID del dispositivo: $idDevice');
    FileManager.instance.createFile('idDevice.txt');
    FileManager.instance.writeToFile('idDevice.txt', idDevice);
  }

  Future<void> subscribeToGpsChanges() async {
    SubscriptionManager.instance.subscribeToGpsChanges();
  }

  Future<void> createFiles() async {
    FileManager.instance.createFile(AppConfig.gpsDataFileName);
    FileManager.instance.createFile(AppConfig.logFileName);
  }







}