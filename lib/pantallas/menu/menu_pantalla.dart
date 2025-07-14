import 'package:flutter/material.dart';
import '../completados/completado_pantalla.dart';
import '../pendientes/pendiente_pantalla.dart';
import '../progresos/progreso_pantalla.dart';
import '../trabajos/trabajo_pantalla.dart';
import '../login/login_pantalla.dart';

void _logout(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const LoginPantalla()),
  );
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
            Tab(icon: Icon(Icons.work), text: 'En progreso'),
            Tab(icon: Icon(Icons.done_all), text: 'Completados'),
          ],
        ),
        actions: [
  IconButton(
    icon: const Icon(Icons.logout),
    onPressed: () => _logout(context),
  ),
],
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