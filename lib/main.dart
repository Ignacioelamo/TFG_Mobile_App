import 'package:flutter/material.dart';
import 'core/init/app_initializer.dart';
import 'core/services/permission_service.dart';
import 'core/services/workmanager_service.dart';
import 'view/my_app.dart';

/// Main entry point of the application.
void main() async {
  // Inicializar componentes esenciales de la aplicación
  await AppInitializer.initialize();

  // Solicitar permisos necesarios
  await PermissionService.requestPermissions();

  // Inicializar y registrar tareas en segundo plano
  await WorkmanagerService.initialize();
  await WorkmanagerService.registerTasks();

  // Run the Flutter application.
  runApp(
    MaterialApp(
      title: 'TFG MOBILE APP',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Builder(
        builder: (BuildContext context) {
          return const MyApp();
        },
      ),
    ),
  );
}
