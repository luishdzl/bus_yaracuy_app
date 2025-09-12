import 'package:flutter/material.dart';

class AjustePantalla extends StatelessWidget {
  const AjustePantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Pantalla de Ajustes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}