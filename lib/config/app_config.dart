class AppConfig {
  AppConfig._privateConstructor();

  static final AppConfig instance = AppConfig._privateConstructor();

  static const appName = 'TFG Mobile App';
  static const appVersion = '1.0.0';
  static const appDescription = 'This app is a demo app for the TFG project';

  static const gpsDataFileName = 'gps_data.csv';
  static const logFileName = 'log.txt';
  static const permissionsGroupFileName = 'groupPermissions.csv';
  static const permissionsUpdatesFileName = 'permissionsUpdates.csv';
  static const deviceSecurityFileName = 'device_security_info.csv';

  static const sharedPreferencesIdDevice = 'deviceId';
  static const sharedPreferencesPermissionsGroupApps = 'permissions';
  static const sharedPreferencesGpsStatus = 'gpsStatus';
  static const sharedPreferencesDeviceSecurity = 'deviceSecurity';

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
