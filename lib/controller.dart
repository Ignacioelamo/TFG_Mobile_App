

import 'package:flutter/services.dart';

import 'fileManager.dart';
import 'permissionManager.dart';

class Controller {
  Controller._privateConstructor();
  static final Controller instance = Controller._privateConstructor();

  static const channel = MethodChannel('flutter_channel');

  Future <void> openFile(String fileName) async {
    await FileManager.instance.openFile(fileName);
  }

  Future <void> clearFile(String fileName) async {
    await FileManager.instance.clearFile(fileName);
  }

  Future <bool> requestPermission() async => await PermissionManager.instance.requestPermissions();

  Future<List<String>> getPermissions() async {
    try {
      // Invocar el método 'imprime' en el canal
      List<dynamic> result = await channel.invokeMethod('imprime');

      // Convertir los elementos de la lista a cadenas y imprimir
      for (var item in result) {
        Map<String, dynamic> appInfo = Map<String, dynamic>.from(item);
        String nombreApp = appInfo['nombreApp'];
        Map<String, dynamic> permisos = Map<String, dynamic>.from(appInfo['permisos']);

        print('Nombre de la aplicación: $nombreApp');
        permisos.forEach((key, value) {
          String estado = value['concedido'] ? 'Concedido' : 'Denegado';
          String solicitado = value['solicitado'] ? 'Solicitado' : 'No solicitado';
          print('Grupo de permisos: $key - Estado: $estado - $solicitado');
        });
      }

      // Devolver la lista de permisos (opcional)
      return result.map((e) => e.toString()).toList();
    } catch (e) {
      // Manejar cualquier excepción que pueda ocurrir durante la invocación del método
      print('Error al obtener permisos: $e');
      return [];
    }
  }

  /*ççFuture<void> requestAppsPermissions() async {
    Map<String, Map<String, bool>> appPermissions = await AppsPermissionChecker.checkAppPermissions();
    print("Printeando desde el controlador");
    print(appPermissions);
  }*/

  Future<void> getAllAppsPermissionsGroup() async {
    try {
      var result = await channel.invokeMethod('getAllPermissionsGroup');

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
    var permisosAntiguos = FileManager.instance.getOldGroupPermissions();
    try {
      var result = await channel.invokeMethod('detectPermissionsChanges', {'oldPermissions': permisosAntiguos});

      if (result is List) {
        print("El resultado recibido es una lista de aplicaciones y permisos solicitados.");
      } else {
        print("El resultado no es del tipo esperado");
      }
    } catch (e) {
      print("Error al obtener permisos: $e");
    }
  }


  Future<void> getAllAppsPermissions() async {
    try {
      var result = await channel.invokeMethod('getAllPermissions');

      // Verificar si el resultado es una lista de mapas
      if (result is List) {
        print("PERMISOS DE CADA APP");

        // Recorrer la lista para imprimir información sobre cada aplicación
        for (var app in result) {
          if (app is Map) { // Verificar que es un mapa
            var appName = app["appName"] ?? "Desconocido";
            var packageName = app["packageName"] ?? "Desconocido";
            print("Aplicación: $appName ($packageName)\n");

            var permissionGroups = app["permissionGroups"] ?? {};

            // Recorrer cada grupo de permisos
            if (permissionGroups is Map) {
              for (var group in permissionGroups.keys) {
                print("Grupo de permisos: $group\n");
                var groupPermissions = permissionGroups[group] ?? {};

                // Recorrer cada permiso dentro del grupo
                if (groupPermissions is Map) {
                  for (var permission in groupPermissions.keys) {
                    var status = groupPermissions[permission] ?? "Desconocido";
                    print("Permiso: $permission - Estado: $status");
                  }
                }
              }
            }
          }
        }
      } else {
        print("El resultado no es del tipo esperado");
      }
    } catch (e) {
      print("Error al obtener permisos: $e");
    }
  }

  Future<void> getAllAppsPermissionsOfTheApps() async {
    try {
      var result = await channel.invokeMethod('getAllPermissionsOfTheApps');

      // Verificar si el resultado es una lista de mapas
      if (result is List) {
        print("Resultado recibido: Lista de aplicaciones y permisos solicitados.");

        // Recorrer la lista para imprimir información sobre cada aplicación
        for (var app in result) {
          if (app is Map) {
            var appName = app["appName"] ?? "Desconocido";
            var packageName = app["packageName"] ?? "Desconocido";
            print("Aplicación: $appName ($packageName)");

            var requestedPermissions = app["requestedPermissions"] ?? [];

            if (requestedPermissions is List) {
              print("Permisos solicitados con estado:");

              for (var permission in requestedPermissions) {
                if (permission is Map) {
                  var permissionName = permission["permissionName"] ?? "Desconocido";
                  var status = permission["status"] ?? "Desconocido";
                  print("- $permissionName: $status");
                }
              }

            } else {
              print("No se encontraron permisos solicitados.");
            }

            print(""); // Salto de línea para separar aplicaciones
          }
        }
      } else {
        print("El resultado no es del tipo esperado.");
      }
    } catch (e) {
      print("Error al obtener permisos: $e");
    }
  }




  Future<void> generateIDDevice() async {
    String idDevice = await channel.invokeMethod('getID_Device');
    print('ID del dispositivo: $idDevice');
    FileManager.instance.createFile('idDevice.txt');
    FileManager.instance.writeToFile('idDevice.txt', idDevice);
  }







}