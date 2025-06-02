/*import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/login_screen.dart';  // importe aqui

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const CarShopApp());
}

class CarShopApp extends StatelessWidget {
  const CarShopApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarShop',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),   // <<< aqui
    );
  }
}*/

// acesso sem login!!

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const CarShopApp());
}

class CarShopApp extends StatelessWidget {
  const CarShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarShop',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(userId: '1'),  // <<< passando um userId fixo
    );
  }
}
