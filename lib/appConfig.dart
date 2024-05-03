
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';



class AppConfig{

  AppConfig._privateConstructor();

  static final AppConfig instance = AppConfig._privateConstructor();

  static const String appName = 'TFG Mobile App';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'This app is a demo app for the TFG project';

  static const String gpsDataFileName = 'gps_data.txt';
  static const String logFileName = 'log.txt';



  static const idDeviceFileName = 'idDevice.txt';
  static const permissionsGroupFileName = 'permissionsGroup.csv';

  // Global variables
  Map<String, dynamic> deviceData = {};



  void getDeviceInfo () async{
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    deviceData = switch (defaultTargetPlatform){
      TargetPlatform.android => _readAndroidBuildData(await deviceInfo.androidInfo),
      // TODO: Handle this case.
      TargetPlatform.fuchsia => throw UnimplementedError(),
      // TODO: Handle this case.
      TargetPlatform.iOS => throw UnimplementedError(),
      // TODO: Handle this case.
      TargetPlatform.linux => throw UnimplementedError(),
      // TODO: Handle this case.
      TargetPlatform.macOS => throw UnimplementedError(),
      // TODO: Handle this case.
      TargetPlatform.windows => throw UnimplementedError(),
    };
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
    };
  }

  Future<String> generateUniqueKey() async {
    // Obtener los valores no nulos y únicos del diccionario
    final values = deviceData.values.where((value) => value != null).toSet();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? randomId = prefs.getInt('randomId');

    values.add(randomId);

    // Concatenar los valores
    final concatenatedValues = values.join();

    // Calcular el hash MD5 de los valores concatenados
    final md5Hash = md5.convert(utf8.encode(concatenatedValues));

    // Devolver el hash como una cadena hexadecimal
    return md5Hash.toString();
  }






}

