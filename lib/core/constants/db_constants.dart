/// Constantes relacionadas con la base de datos para mantener consistencia
/// a lo largo de toda la aplicación
class DBConstants {
  // Nombres de tablas
  static const String devicesTable = 'devices';
  static const String gpsStatusTable = 'gps_status';
  static const String installedAppsTable = 'installed_apps';
  static const String permissionGroupsTable = 'permission_groups';
  static const String permissionStatusTable = 'permission_status';
  static const String permissionHistoryTable = 'permission_history';
  static const String deviceSecurityTable = 'device_security';
  static const String systemLogsTable = 'system_logs';

  // Columnas comunes
  static const String idColumn = 'id';
  static const String deviceIdColumn = 'device_id';
  static const String updatedColumn = 'updated';
  static const String createdAtColumn = 'created_at';
  static const String updatedAtColumn = 'last_updated';
  static const String recordedAtColumn = 'recorded_at';

  // Columnas de GPS Status
  static const String statusColumn = 'status';

  // Columnas de Installed Apps
  static const String packageNameColumn = 'package_name';

  // Columnas de Permission Status
  static const String appIdColumn = 'app_id';
  static const String permissionGroupIdColumn = 'permission_group_id';

  // Columnas de Permission History
  static const String permissionGroupColumn = 'permission_group';
  static const String previousStatusColumn = 'previous_status';
  static const String newStatusColumn = 'new_status';
  static const String changedAtColumn = 'changed_at';

  // Columnas de Device Security
  static const String biometricAuthEnabledColumn = 'biometric_auth_enabled';
  static const String lockScreenEnabledColumn = 'lock_screen_enabled';

  // Columnas de System Logs
  static const String logTypeColumn = 'log_type';
  static const String messageColumn = 'message';
  static const String levelColumn = 'level';

  // Tabla de tiempo de uso de aplicaciones
  static const String appUseTimeTable = 'app_use_time';

  // Columnas de App Use Time
  static const String dateColumn = 'date';
  static const String minutesColumn = 'minutes';
}
