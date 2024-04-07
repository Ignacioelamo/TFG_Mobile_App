import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionManager {
  AppPermissionManager._privateConstructor();
  static final AppPermissionManager instance = AppPermissionManager._privateConstructor();

  Future<Map<String, List<Permission>>> getAllAppPermissions() async {
    List<PackageInfo> installedApps = (await PackageInfo.fromPlatform()) as List<PackageInfo>;

    Map<String, List<Permission>> appPermissions = {};

    for (var app in installedApps) {
      List<Permission> permissions = await getPermissionsForApp(app.packageName);
      appPermissions[app.appName] = permissions;
    }

    return appPermissions;
  }

  Future<List<Permission>> getPermissionsForApp(String packageName) async {

  }
}

