import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../core/services/auth_service.dart';
import '../domain/repositories/device_repository.dart';
import '../injection_container.dart' as di;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String? _username;
  bool? _deviceUpdated;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadDeviceUpdatedStatus();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await AuthService.getUserInfo();
    if (userInfo != null && mounted) {
      setState(() {
        _username = userInfo['username'];
      });
    }
  }

  Future<void> _loadDeviceUpdatedStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString(AppConfig.sharedPreferencesIdDevice);
      if (deviceId == null || deviceId.isEmpty) return;

      final deviceRepository = di.sl<DeviceRepository>();
      final device = await deviceRepository.getDeviceByDeviceId(deviceId);
      if (mounted) {
        setState(() {
          _deviceUpdated = device?.updated;
        });
      }
    } catch (_) {
      // Ignorar errores al cargar estado de actualización
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TFG MOBILE APP'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info_outlined),
            onPressed: () async {
              _showConfirmationDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_username != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Bienvenido, $_username',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (_deviceUpdated != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    _deviceUpdated!
                        ? Icons.check_circle
                        : Icons.warning_amber_rounded,
                    color: _deviceUpdated! ? Colors.green : Colors.orange,
                    size: 28,
                  ),
                  title: Text(
                    _deviceUpdated!
                        ? 'Dispositivo actualizado'
                        : 'Dispositivo desactualizado',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _deviceUpdated! ? Colors.green[800] : Colors.orange[800],
                    ),
                  ),
                  subtitle: Text(
                    _deviceUpdated!
                        ? 'El parche de seguridad del firmware está al día'
                        : 'Se recomienda actualizar el firmware del dispositivo',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          if (_deviceUpdated != null) const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: _openFileDirectory,
              child: const Text('Ver archivos guardados'),
            ),
          ),
        ],
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
                      TextSpan(
                          text:
                              'Esta aplicación ha sido realizada bajo el proyecto '),
                      TextSpan(
                          text:
                              'Continuous decentralized Learning of IoT Device\'s Behavioural Profiles',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              ' y se han seguido todo el reglamento de la comisión de ética de la Universidad de Murcia a la hora de recoger los datos.'),
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
    final fileList =
        directory?.listSync().map((item) => item as File).toList() ?? [];

    File? latestFile;
    DateTime? lastModified;
    for (File file in fileList) {
      DateTime? currentFileDate = await file.lastModified();
      if (lastModified == null || currentFileDate.isAfter(lastModified)) {
        lastModified = currentFileDate;
        latestFile = file;
      }
    }

    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Archivos guardados en la ruta:'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(directory?.path ?? "Ruta no disponible",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                ...fileList.map((file) => ListTile(
                      title: Text(file.path.split('/').last),
                      onTap: () => Navigator.of(context).pop(),
                    )),
                if (latestFile != null && lastModified != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                        "Último modificado: ${latestFile.path.split('/').last} hace ${DateTime.now().difference(lastModified).inMinutes} minutos"),
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
