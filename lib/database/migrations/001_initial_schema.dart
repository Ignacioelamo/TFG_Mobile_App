import '../migration_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InitialSchemaMigration extends Migration {
  InitialSchemaMigration() : super(1, 'Initial schema creation');

  @override
  Future<void> up(SupabaseClient client) async {
    await client.rpc('execute_migration', params: {
      'query': '''
        -- Devices table
        CREATE TABLE IF NOT EXISTS devices (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          device_id TEXT UNIQUE NOT NULL,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );

        -- GPS Status table
        CREATE TABLE IF NOT EXISTS gps_status (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          device_id UUID REFERENCES devices(id),
          status TEXT NOT NULL CHECK (status IN ('enabled', 'disabled', 'unknown')),
          recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          CONSTRAINT fk_device_gps FOREIGN KEY (device_id) 
            REFERENCES devices(id) ON DELETE CASCADE
        );

        -- Installed Apps table
        CREATE TABLE IF NOT EXISTS installed_apps (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          device_id UUID REFERENCES devices(id),
          package_name TEXT NOT NULL,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          CONSTRAINT fk_device_apps FOREIGN KEY (device_id) 
            REFERENCES devices(id) ON DELETE CASCADE,
          CONSTRAINT unique_device_package UNIQUE(device_id, package_name)
        );

        -- Permission Groups table
        CREATE TABLE IF NOT EXISTS permission_groups (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          name TEXT UNIQUE NOT NULL
        );

        -- Insert default permission groups
        INSERT INTO permission_groups (name) VALUES
          ('ACTIVITY_RECOGNITION'),
          ('CALENDAR'),
          ('CALL_LOG'),
          ('CAMERA'),
          ('CONTACTS'),
          ('LOCATION'),
          ('MICROPHONE'),
          ('NEARBY_DEVICES'),
          ('NOTIFICATIONS'),
          ('PHONE'),
          ('READ_MEDIA_AURAL'),
          ('READ_MEDIA_VISUAL'),
          ('SENSORS'),
          ('SMS'),
          ('STORAGE')
        ON CONFLICT (name) DO NOTHING;

        -- Permission Status table
        CREATE TABLE IF NOT EXISTS permission_status (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          app_id UUID NOT NULL,
          permission_group_id UUID NOT NULL,
          status TEXT NOT NULL,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          CONSTRAINT fk_app FOREIGN KEY (app_id) 
            REFERENCES installed_apps(id) ON DELETE CASCADE,
          CONSTRAINT fk_permission_group FOREIGN KEY (permission_group_id) 
            REFERENCES permission_groups(id) ON DELETE CASCADE,
          CONSTRAINT unique_app_permission UNIQUE(app_id, permission_group_id)
        );

        -- Permission Changes History table
        CREATE TABLE IF NOT EXISTS permission_changes (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          device_id UUID NOT NULL,
          package_name TEXT NOT NULL,
          permission_group TEXT NOT NULL,
          previous_status TEXT,
          new_status TEXT NOT NULL,
          changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          CONSTRAINT fk_device_changes FOREIGN KEY (device_id) 
            REFERENCES devices(id) ON DELETE CASCADE
        );

        -- Device Security table
        CREATE TABLE IF NOT EXISTS device_security (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          device_id UUID NOT NULL,
          biometric_auth_enabled BOOLEAN,
          lock_screen_enabled BOOLEAN,
          recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          CONSTRAINT fk_device_security FOREIGN KEY (device_id) 
            REFERENCES devices(id) ON DELETE CASCADE
        );

        -- System Logs table
        CREATE TABLE IF NOT EXISTS system_logs (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          device_id UUID NOT NULL,
          log_type TEXT NOT NULL,
          message TEXT NOT NULL,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          CONSTRAINT fk_device_logs FOREIGN KEY (device_id) 
            REFERENCES devices(id) ON DELETE CASCADE
        );

        -- Create type for log levels
        DO \$\$ BEGIN
          CREATE TYPE log_level AS ENUM ('INFO', 'WARNING', 'ERROR', 'DEBUG');
        EXCEPTION
          WHEN duplicate_object THEN null;
        END \$\$;

        -- Add log level column to system_logs
        ALTER TABLE system_logs 
        ADD COLUMN IF NOT EXISTS level log_level DEFAULT 'INFO';
      '''
    });
  }

  @override
  Future<void> down(SupabaseClient client) async {
    await client.rpc('execute_migration', params: {
      'query': '''
        DROP TABLE IF EXISTS system_logs CASCADE;
        DROP TABLE IF EXISTS device_security CASCADE;
        DROP TABLE IF EXISTS permission_changes CASCADE;
        DROP TABLE IF EXISTS permission_status CASCADE;
        DROP TABLE IF EXISTS permission_groups CASCADE;
        DROP TABLE IF EXISTS installed_apps CASCADE;
        DROP TABLE IF EXISTS gps_status CASCADE;
        DROP TABLE IF EXISTS devices CASCADE;
        DROP TYPE IF EXISTS log_level;
      '''
    });
  }
}
