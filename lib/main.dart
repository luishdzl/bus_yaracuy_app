import 'package:flutter/material.dart';
import 'pantallas/completados/completado_pantalla.dart';
import 'pantallas/menu/trabajo_pantalla.dart';
import 'pantallas/progresos/progreso_pantalla.dart';
import 'pantallas/pendientes/pendiente_pantalla.dart';

void main() => runApp(MyApp());

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
      home: MenuPantalla(),
    );
  }
}

class MenuPantalla extends StatefulWidget {
  const MenuPantalla({super.key});

  @override
  State<MenuPantalla> createState() => _MenuPantallaState();
}

class _MenuPantallaState extends State<MenuPantalla>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Yaracuy'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.grey,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.menu), text: 'Menú'),
            Tab(icon: Icon(Icons.pending), text: 'Pendientes'),
            Tab(icon: Icon(Icons.work), text: 'Trabajos'),
            Tab(icon: Icon(Icons.done_all), text: 'Completados'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TrabajoPantalla(),
          PendientePantalla(),
          ProgresoPantalla(),
          CompletadoPantalla(),
        ],
      ),
    );
  }
}