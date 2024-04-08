import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  PermissionManager._privateConstructor();
  static final PermissionManager instance = PermissionManager._privateConstructor();

  Future<bool> requestPermissions() async {
    final Map<Permission, PermissionStatus> status = await _requestStoragePermission();
    final bool allGranted = _checkAllPermissionsGranted(status);

    if (!allGranted) {
      return false;
    } else {
      return true;
    }
  }

  Future<Map<Permission, PermissionStatus>> _requestStoragePermission() async {
    return await [
      Permission.manageExternalStorage,
    ].request();
  }

  bool _checkAllPermissionsGranted(Map<Permission, PermissionStatus> status) {
    return status.values.every((status) => status.isGranted);
  }


}