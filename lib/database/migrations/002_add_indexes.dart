import '../migration_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddIndexesMigration extends Migration {
  AddIndexesMigration() : super(2, 'Add performance indexes');

  @override
  Future<void> up(SupabaseClient client) async {
    await client.rpc('execute_migration', params: {
      'query': '''
        -- Devices indexes
        CREATE INDEX IF NOT EXISTS idx_devices_device_id ON devices(device_id);
        CREATE INDEX IF NOT EXISTS idx_devices_last_active ON devices(last_active);

        -- GPS Status indexes
        CREATE INDEX IF NOT EXISTS idx_gps_status_device_id ON gps_status(device_id);
        CREATE INDEX IF NOT EXISTS idx_gps_status_recorded_at ON gps_status(recorded_at);
        CREATE INDEX IF NOT EXISTS idx_gps_status_status ON gps_status(status);

        -- Installed Apps indexes
        CREATE INDEX IF NOT EXISTS idx_installed_apps_device_id ON installed_apps(device_id);
        CREATE INDEX IF NOT EXISTS idx_installed_apps_package_name ON installed_apps(package_name);
        CREATE INDEX IF NOT EXISTS idx_installed_apps_last_updated ON installed_apps(last_updated);

        -- Permission Status indexes
        CREATE INDEX IF NOT EXISTS idx_permission_status_app_id ON permission_status(app_id);
        CREATE INDEX IF NOT EXISTS idx_permission_status_permission_group_id 
          ON permission_status(permission_group_id);
        CREATE INDEX IF NOT EXISTS idx_permission_status_status ON permission_status(status);

        -- Permission Changes indexes
        CREATE INDEX IF NOT EXISTS idx_permission_changes_device_id ON permission_changes(device_id);
        CREATE INDEX IF NOT EXISTS idx_permission_changes_package_name 
          ON permission_changes(package_name);
        CREATE INDEX IF NOT EXISTS idx_permission_changes_changed_at 
          ON permission_changes(changed_at);
        CREATE INDEX IF NOT EXISTS idx_permission_changes_permission_group 
          ON permission_changes(permission_group);

        -- Device Security indexes
        CREATE INDEX IF NOT EXISTS idx_device_security_device_id ON device_security(device_id);
        CREATE INDEX IF NOT EXISTS idx_device_security_recorded_at 
          ON device_security(recorded_at);

        -- System Logs indexes
        CREATE INDEX IF NOT EXISTS idx_system_logs_device_id ON system_logs(device_id);
        CREATE INDEX IF NOT EXISTS idx_system_logs_created_at ON system_logs(created_at);
        CREATE INDEX IF NOT EXISTS idx_system_logs_log_type ON system_logs(log_type);
        CREATE INDEX IF NOT EXISTS idx_system_logs_level ON system_logs(level);
      '''
    });
  }

  @override
  Future<void> down(SupabaseClient client) async {
    await client.rpc('execute_migration', params: {
      'query': '''
        -- Drop Devices indexes
        DROP INDEX IF EXISTS idx_devices_device_id;
        DROP INDEX IF EXISTS idx_devices_last_active;

        -- Drop GPS Status indexes
        DROP INDEX IF EXISTS idx_gps_status_device_id;
        DROP INDEX IF EXISTS idx_gps_status_recorded_at;
        DROP INDEX IF EXISTS idx_gps_status_status;

        -- Drop Installed Apps indexes
        DROP INDEX IF EXISTS idx_installed_apps_device_id;
        DROP INDEX IF EXISTS idx_installed_apps_package_name;
        DROP INDEX IF EXISTS idx_installed_apps_last_updated;

        -- Drop Permission Status indexes
        DROP INDEX IF EXISTS idx_permission_status_app_id;
        DROP INDEX IF EXISTS idx_permission_status_permission_group_id;
        DROP INDEX IF EXISTS idx_permission_status_status;

        -- Drop Permission Changes indexes
        DROP INDEX IF EXISTS idx_permission_changes_device_id;
        DROP INDEX IF EXISTS idx_permission_changes_package_name;
        DROP INDEX IF EXISTS idx_permission_changes_changed_at;
        DROP INDEX IF EXISTS idx_permission_changes_permission_group;

        -- Drop Device Security indexes
        DROP INDEX IF EXISTS idx_device_security_device_id;
        DROP INDEX IF EXISTS idx_device_security_recorded_at;
        
        -- Drop System Logs indexes
        DROP INDEX IF EXISTS idx_system_logs_device_id;
        DROP INDEX IF EXISTS idx_system_logs_created_at;
        DROP INDEX IF EXISTS idx_system_logs_log_type;
        DROP INDEX IF EXISTS idx_system_logs_level;
      '''
    });
  }
}
