import 'package:flutter/material.dart';
import 'core/init/app_initializer.dart';
import 'core/services/workmanager_service.dart';
import 'view/my_app.dart';
import 'view/login_screen.dart';
import 'view/permissions_screen.dart';

/// Main entry point of the application.
void main() async {
  // Inicializar componentes esenciales de la aplicación
  await AppInitializer.initialize();

  // Inicializar y registrar tareas en segundo plano
  await WorkmanagerService.initialize();
  await WorkmanagerService.registerTasks();

  // Run the Flutter application.
  runApp(
    MaterialApp(
      title: 'TFG MOBILE APP',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/permissions', // Empezamos con la pantalla de permisos
      routes: {
        '/permissions': (context) => const PermissionsScreen(),
        '/': (context) => const LoginScreen(),
        '/home': (context) => const MyApp(),
      },
    ),
  );
}
