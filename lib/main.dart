import 'dart:async';


import 'package:flutter/material.dart';
import 'package:tfg_mobile_app/MyApp.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fileManager.dart';
import 'appConfig.dart';
import 'subscriptionManager.dart';

//Global variables
bool? _isFirstTime;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();


  await initializeService();
  runApp(
    MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return MyApp(context: context);
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
          isForegroundMode: false)
  );

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    if (await firstTime()){
      FileManager.instance.createFile(AppConfig.gpsDataFileName);
    }
    SubscriptionManager.instance.subscribeToGpsChanges();
  }
}

Future<bool> firstTime() async{
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  _isFirstTime = prefs.getBool('firstTime') ?? true;
  if (_isFirstTime!){
    prefs.setBool('firstTime', _isFirstTime!);
    return true;
  }else{
    prefs.setBool('firstTime', false);
    return false;
  }
}
