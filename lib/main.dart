import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'controller/controller.dart';
import 'view/my_app.dart';

/// Callback function to handle background tasks executed by Workmanager.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return await Controller.instance.handleWorkmanagerTask(task);
  });
}

/// Requests notification permissions from the user.
Future<void> _requestPermissions() async {
  if (await Permission.notification.request().isDenied) {
    await Permission.notification.request();
  }
}

/// Main entry point of the application.
void main() async {
  // Ensures that Flutter binding is initialized before calling any plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // Request necessary permissions.
  _requestPermissions();

  // Initialize Workmanager with the callbackDispatcher function.
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );

  Workmanager().registerOneOffTask("RetrieveDeviceId", "retrieve_device_id_task");

  Workmanager().registerOneOffTask(
      "RequestAppPermissions", "request_app_permissions_task");

  Workmanager().registerOneOffTask("CreateAppFiles", "create_app_files_task",
      initialDelay: const Duration(seconds: 5));

  Workmanager().registerOneOffTask("WriteStaticData", "write_static_data_task",
      initialDelay: const Duration(seconds: 10));





  // Register a periodic task with Workmanager.
  Workmanager().registerPeriodicTask(
      "DetectAppPermissionsChanges", "detect_app_permissions_changes_task",
      initialDelay: const Duration(seconds: 60),
      frequency: const Duration(minutes: 15));

  Workmanager().registerPeriodicTask(
      "DetectGpsStatusChanges", "detect_gps_status_changes_task",
      initialDelay: const Duration(seconds: 15),
      frequency: const Duration(minutes: 15));

  // Run the Flutter application.
  runApp(
    MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return const MyApp();
        },
      ),
    ),
  );
}
