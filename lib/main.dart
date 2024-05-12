import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'controller.dart';
import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeService();

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

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true, // Cambiar esto a true para usar modo foregrou
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    //await handleFirstTimeInitialization();
    Controller.instance.subscribeToGpsChanges();
  }
}

/*Future<void> handleFirstTimeInitialization() async {
  if (await isFirstTime()) {
    //Si queremos que algo se haga al iniciar el servicio por primera vez
  }
}*/
/*
Future<bool> isFirstTime() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('firstTime') ?? true;
  if (isFirstTime) {
    prefs.setBool('firstTime', false);
  }
  return isFirstTime;
}*/
