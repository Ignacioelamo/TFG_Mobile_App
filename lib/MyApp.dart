import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tfg_mobile_app/fileManager.dart';
import 'appConfig.dart';


class MyApp extends StatelessWidget {
  final BuildContext context;

  const MyApp({super.key, required this.context});

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
              await FileManager.instance.openFile(AppConfig.gpsDataFileName);

              /*bool fileExists = await FileManager.instance.fileExists('gps_data.txt');
              if (fileExists) {
                print("El archivo ya existe");
                await FileManager.instance.openFile(AppConfig.gpsDataFileName);
              } else {
                print("El archivo no existe");
                await FileManager.instance.createFile(AppConfig.gpsDataFileName);
                await FileManager.instance.openFile(AppConfig.gpsDataFileName);
              }*/
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
                await FileManager.instance.deleteFile(AppConfig.gpsDataFileName);
              },
            ),
          ],
        );
      },
    );
  }
}
