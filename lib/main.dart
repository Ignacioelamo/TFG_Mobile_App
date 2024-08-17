import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_mobile_app/file_manager.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';


import 'controller.dart';
import 'my_app.dart';

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (kDebugMode) {
      print("Native called background task: $task");
    } //simpleTask will be emitted here.

    try {
      String content = "Background task executed at ${DateTime.now().toString()}\n";
      await FileManager.instance.createFile('prueba.txt');
      await FileManager.instance.writeToFile('prueba.txt', content);
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing FlutterBackgroundServiceAndroid: $e');
      }
    }

    return Future.value(true);
  });
}

//Pide permisos de notificaciones
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
      isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );

  Workmanager().registerPeriodicTask("task-identifier", "simplePeriodicTask", frequency: const Duration(seconds: 2));


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


