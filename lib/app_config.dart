import 'package:flutter/services.dart';

class AppConfig {
  AppConfig._privateConstructor();

  static final AppConfig instance = AppConfig._privateConstructor();

  static const appName = 'TFG Mobile App';
  static const appVersion = '1.0.0';
  static const appDescription = 'This app is a demo app for the TFG project';

  static const gpsDataFileName = 'gps_data.txt';
  static const logFileName = 'log.txt';
  static const idDeviceFileName = 'idDevice.txt';
  static const permissionsGroupFileName = 'groupPermissions.csv';
  static const permissionsUpdatesFileName = 'permissionsUpdates.csv';

  static const nameChannel = 'flutter_channel';
  static const channel = MethodChannel(nameChannel);

  static const getAppPermissionStatusesMethod = 'getAppPermissionStatuses';
  static const getDeviceIdMethod = 'retrieveDeviceID';
  static const detectPermissionsChangesMethod = 'detectPermissionGroupChanges';
  static const getAllAppPermissionsMethod = 'getAppPermissions';
  static const getPermissionsGroupStatusMethod = 'getPermissionsGroupStatus';

  final List<String> permissionGroups = [
    "ACTIVITY_RECOGNITION",
    "CALENDAR",
    "CALL_LOG",
    "CAMERA",
    "CONTACTS",
    "LOCATION",
    "MICROPHONE",
    "NEARBY_DEVICES",
    "NOTIFICATIONS",
    "PHONE",
    "READ_MEDIA_AURAL",
    "READ_MEDIA_VISUAL",
    "SENSORS",
    "SMS",
    "STORAGE"
  ];
}
