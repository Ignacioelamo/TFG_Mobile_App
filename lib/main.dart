import 'dart:async';
import 'dart:math';



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
          isForegroundMode: false)
  );

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    await handleFirstTimeInitialization();
    SubscriptionManager.instance.subscribeToGpsChanges();
    //AppPermissionManager.instance.printAllAppPermissions();
  }
}

Future<void> handleFirstTimeInitialization() async {
  if (await isFirstTime()) {
    FileManager.instance.createFile(AppConfig.gpsDataFileName);
    FileManager.instance.createFile(AppConfig.logFileName);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? serialNumber = prefs.getString('serialNumber');
    serialNumber ??= await generateAndSaveUniqueKey(prefs);
    FileManager.instance.saveFile(AppConfig.gpsDataFileName, 'id: $serialNumber\n');
  }
}

Future<bool> isFirstTime() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('firstTime') ?? true;
  if (isFirstTime) {
    final random = Random();
    final randomId = random.nextInt(1000000); // Por ejemplo, un número aleatorio de 6 dígitos
    prefs.setBool('firstTime', false);
    prefs.setInt('randomId', randomId);
  }
  return isFirstTime;
}

Future<String> generateAndSaveUniqueKey(SharedPreferences prefs) async {
  String serialNumber = await AppConfig.instance.generateUniqueKey();
  prefs.setString('serialNumber', serialNumber);
  return serialNumber;
}

