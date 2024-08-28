import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'controller/controller.dart';
import 'view/my_app.dart';



@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return await Controller.instance.handleWorkmanagerTask(task);
  });
}

//Request permissions
Future<void> _requestPermissions() async {
  if (await Permission.notification.request().isDenied) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _requestPermissions();

  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );

  Workmanager().registerOneOffTask(
      "RequestAppPermissions", "request_app_permissions_task");
  /*Workmanager().registerPeriodicTask(
      "DetectAppPermissionsChanges", "detect_app_permissions_changes_task",
      initialDelay: const Duration(seconds: 5),
      frequency: const Duration(minutes: 15));*/

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
