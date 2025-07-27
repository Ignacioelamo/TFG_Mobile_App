import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../core/services/permission_service.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({Key? key}) : super(key: key);

  @override
  _PermissionsScreenState createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _isLoading = true;
  bool _locationGranted = false;
  bool _backgroundLocationGranted = false;
  bool _storageGranted = false;
  bool _notificationsGranted = false;
  bool _phoneGranted = false;
  bool _cameraGranted = false;
  bool _contactsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    setState(() {
      _isLoading = true;
    });

    // Verificar todos los permisos necesarios
    var locationStatus = await Permission.location.status;
    var backgroundStatus = await Permission.locationAlways.status;
    var storageStatus = await Permission.storage.status;
    var notificationStatus = await Permission.notification.status;
    var phoneStatus = await Permission.phone.status;
    var cameraStatus = await Permission.camera.status;
    var contactsStatus = await Permission.contacts.status;

    setState(() {
      _locationGranted = locationStatus.isGranted;
      _backgroundLocationGranted = backgroundStatus.isGranted;
      _storageGranted = storageStatus.isGranted;
      _notificationsGranted = notificationStatus.isGranted;
      _phoneGranted = phoneStatus.isGranted;
      _cameraGranted = cameraStatus.isGranted;
      _contactsGranted = contactsStatus.isGranted;
      _isLoading = false;
    });
  }

  // Solicitar permiso de ubicación
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _locationGranted = status.isGranted;
    });

    if (status.isGranted) {
      final backgroundStatus = await Permission.locationAlways.request();
      setState(() {
        _backgroundLocationGranted = backgroundStatus.isGranted;
      });
    }
  }

  // Solicitar permisos de almacenamiento
  Future<void> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    setState(() {
      _storageGranted = status.isGranted;
    });
  }

  // Solicitar permisos de notificaciones
  Future<void> _requestNotificationsPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationsGranted = status.isGranted;
    });
  }

  // Solicitar permisos de teléfono
  Future<void> _requestPhonePermission() async {
    final status = await Permission.phone.request();
    setState(() {
      _phoneGranted = status.isGranted;
    });
  }

  // Solicitar permisos de cámara
  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _cameraGranted = status.isGranted;
    });
  }

  // Solicitar permisos de contactos
  Future<void> _requestContactsPermission() async {
    final status = await Permission.contacts.request();
    setState(() {
      _contactsGranted = status.isGranted;
    });
  }

  void _continueToLogin() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Permisos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Para el correcto funcionamiento de esta aplicación, se requieren los siguientes permisos:',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildPermissionItem(
                      'Ubicación',
                      _locationGranted,
                      'Esta app monitoriza el estado del GPS para fines de investigación',
                      _requestLocationPermission,
                    ),
                    const SizedBox(height: 10),
                    _buildPermissionItem(
                      'Ubicación en segundo plano',
                      _backgroundLocationGranted,
                      'Permite monitorizar el GPS incluso cuando la app no está en uso',
                      () async {
                        if (_locationGranted) {
                          final status =
                              await Permission.locationAlways.request();
                          setState(() {
                            _backgroundLocationGranted = status.isGranted;
                          });
                        } else {
                          _requestLocationPermission();
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildPermissionItem(
                      'Almacenamiento',
                      _storageGranted,
                      'Permite guardar datos recopilados en el dispositivo',
                      _requestStoragePermission,
                    ),
                    const SizedBox(height: 10),
                    _buildPermissionItem(
                      'Notificaciones',
                      _notificationsGranted,
                      'Permite mostrar notificaciones importantes',
                      _requestNotificationsPermission,
                    ),
                    const SizedBox(height: 10),
                    _buildPermissionItem(
                      'Teléfono',
                      _phoneGranted,
                      'Permite acceder a información básica del teléfono',
                      _requestPhonePermission,
                    ),
                    const SizedBox(height: 10),
                    _buildPermissionItem(
                      'Cámara',
                      _cameraGranted,
                      'Permite usar la cámara para funciones adicionales',
                      _requestCameraPermission,
                    ),
                    const SizedBox(height: 10),
                    _buildPermissionItem(
                      'Contactos',
                      _contactsGranted,
                      'Permite acceder a la información de contactos',
                      _requestContactsPermission,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _continueToLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nota: Esta aplicación necesita estos permisos para recopilar datos para el proyecto de investigación. Puedes continuar sin todos los permisos, pero algunas funciones podrían no estar disponibles.',
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPermissionItem(
    String title,
    bool isGranted,
    String description,
    VoidCallback onRequestPermission,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isGranted
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : ElevatedButton(
                        onPressed: onRequestPermission,
                        child: const Text('Permitir'),
                      ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}
