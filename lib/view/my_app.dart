import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa DateFormat
import 'package:path_provider/path_provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TFG MOBILE APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TFG MOBILE APP'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.info_outlined),
              onPressed: () async {
                _showConfirmationDialog(context);
              },
            ),
          ],
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _openFileDirectory,
            child: const Text('Ver archivos guardados'),
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Información'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(text: 'Esta aplicación ha sido realizada bajo el proyecto '),
                      TextSpan(text: 'Continuous decentralized Learning of IoT Device\'s Behavioural Profiles', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' y se han seguido todo el reglamento de la comisión de ética de la Universidad de Murcia a la hora de recoger los datos.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _openFileDirectory() async {
    final directory = await getExternalStorageDirectory();
    final fileList = directory?.listSync().map((item) => item as File).toList() ?? [];
    // Encuentra el archivo más recientemente modificado
    File? latestFile;
    DateTime? lastModified;
    for (File file in fileList) {
      DateTime? currentFileDate = await file.lastModified();
      if (lastModified == null || currentFileDate.isAfter(lastModified)) {
        lastModified = currentFileDate;
        latestFile = file;
      }
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Archivos guardados en la ruta:'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(directory?.path ?? "Ruta no disponible", style: TextStyle(fontWeight: FontWeight.bold)),
                ...fileList.map((file) => ListTile(
                  title: Text(file.path.split('/').last),
                  onTap: () => Navigator.of(context).pop(),
                )).toList(),
                if (latestFile != null && lastModified != null) Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text("Último modificado: ${latestFile.path.split('/').last} hace ${DateTime.now().difference(lastModified).inMinutes} minutos"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}




