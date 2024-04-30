import 'package:flutter/material.dart';

import 'appConfig.dart';
import 'controller.dart';
import 'dart:async';


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _requestPermissions(); // Solicita los permisos utilizando PermissionManager
    Controller.instance.generateIDDevice();
    //Controller.instance.getAllAppsPermissions();
    Controller.instance.getAllAppsPermissionsGroup();
    //Controller.instance.getAllAppsPermissionsOfTheApps();
    //Controller.instance.getPermissions();
    //Controller.instance.requestAppsPermissions();
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) async {
      await Controller.instance.;
    });
  }

  Future<void> _requestPermissions() async {
    bool granted = await Controller.instance.requestPermission();
    if (!granted) {
      _showPermissionDialog(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Creation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('File Creation App'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                _showConfirmationDialog(context);
              },
            ),
          ],
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await Controller.instance.openFile(AppConfig.gpsDataFileName);
            },
            child: const Text('Open File'),
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this file?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Controller.instance.clearFile(AppConfig.gpsDataFileName);
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permisos requeridos'),
        content: const Text('Por favor, concede los permisos para continuar.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestPermissions();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}





