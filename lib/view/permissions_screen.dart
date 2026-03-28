import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/services/permission_service.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _isLoading = true;
  bool _locationGranted = false;
  bool _backgroundLocationGranted = false;
  bool _storageGranted = false;
  bool _notificationsGranted = false;
  bool _usageStatsGranted = false;

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
    var usageStatsGranted = await PermissionService.hasUsageStatsPermission();

    setState(() {
      _locationGranted = locationStatus.isGranted;
      _backgroundLocationGranted = backgroundStatus.isGranted;
      _storageGranted = storageStatus.isGranted;
      _notificationsGranted = notificationStatus.isGranted;
      _usageStatsGranted = usageStatsGranted;
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

  // Solicitar permiso de estadísticas de uso
  Future<void> _requestUsageStatsPermission() async {
    await PermissionService.requestUsageStatsPermission();
    // Esperar un momento y luego re-verificar (el usuario debe activarlo manualmente en ajustes)
    await Future.delayed(const Duration(seconds: 1));
    final granted = await PermissionService.hasUsageStatsPermission();
    setState(() {
      _usageStatsGranted = granted;
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
                      'Estadísticas de uso',
                      _usageStatsGranted,
                      'Permite obtener el tiempo de uso de las aplicaciones para fines de investigación',
                      _requestUsageStatsPermission,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (isGranted)
                  const Icon(Icons.check_circle, color: Colors.green)
                else
                  ElevatedButton(
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
