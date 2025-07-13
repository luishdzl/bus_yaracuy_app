import 'package:flutter/material.dart';
import 'pantallas/login/login_pantalla.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Yaracuy',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const LoginPantalla(),
    );
  }
}