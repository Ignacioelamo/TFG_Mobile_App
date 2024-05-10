import 'app_config.dart';


class DebugDart{

  DebugDart._privateConstructor();
  static final DebugDart instance = DebugDart._privateConstructor();





  // Retrieves all permissions from all applications
  Future<void> getAppPermissions() async {
    try {
      var result = await AppConfig.channel.invokeMethod(AppConfig.getAllAppPermissionsMethod);

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

  // Retrieves the permission group status from all applications
  Future<void> getPermissionsGroupStatus() async {
    try {
      var result = await AppConfig.channel.invokeMethod(
          AppConfig.getPermissionsGroupStatusMethod);

      // Verificar si el resultado es una lista de mapas
      if (result is List) {
        print(
            "Resultado recibido: Lista de aplicaciones y permisos solicitados.");

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
                  var permissionName = permission["permissionName"] ??
                      "Desconocido";
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
}
