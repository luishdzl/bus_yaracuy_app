import 'package:flutter/material.dart';
import '../trabajos/trabajo_pantalla.dart';
import '../ajustes/ajuste_pantalla.dart';
import '../login/login_pantalla.dart';

class MenuPantalla extends StatefulWidget {
  const MenuPantalla({super.key});

  @override
  State<MenuPantalla> createState() => _MenuPantallaState();
}

class _MenuPantallaState extends State<MenuPantalla> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _menuOpen = false; // Estado para controlar el menú lateral

  // Lista de pantallas (solo 2 opciones)
  final List<Widget> _screens = [
    const TrabajoPantalla(),
    const AjustePantalla(),
  ];

  // Lista de ítems del menú (solo 2 opciones)
  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.work_outline),
      activeIcon: Icon(Icons.work, color: Colors.white),
      label: 'Trabajos',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings, color: Colors.white),
      label: 'Ajustes',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPantalla()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con el estilo gris oscuro
      appBar: AppBar(
        backgroundColor: const Color(0xFF374151), // bg-gray-800 equivalente
        elevation: 0,
        title: const Text(
          'BUS YARACUY',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            _menuOpen ? Icons.close : Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _menuOpen = !_menuOpen;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),

      // Menú lateral similar al navbar de React
      drawer: _buildSidebarMenu(),

      // Cuerpo con PageView para navegación suave
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),

      // Bottom Navigation Bar en gris oscuro
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
          border: Border(
            top: BorderSide(
              color: Color(0xFF4B5563), // border-gray-700 equivalente
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: _bottomNavItems,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF374151), // bg-gray-800 equivalente
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color(0xFFD1D5DB), // text-gray-300 equivalente
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          showUnselectedLabels: true,
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildSidebarMenu() {
    return Drawer(
      backgroundColor: const Color(0xFF374151), // bg-gray-800 equivalente
      width: 256, // w-64 equivalente (64 * 4 = 256)
      child: Column(
        children: [
          // Logo en el navbar
          Container(
            height: 64,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF4B5563), // border-gray-700 equivalente
                  width: 1.0,
                ),
              ),
            ),
            child: const Center(
              child: Text(
                'BUSYARACUY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      // Opción Inicio
                      _buildMenuItem(
                        icon: Icons.home,
                        title: 'Inicio',
                        isActive: false,
                        onTap: () {},
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Aquí irían los menús dinámicos como en React
                      // Por ahora, mostramos un placeholder
                      const Text(
                        'Menús dinámicos irían aquí',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF), // text-gray-400 equivalente
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  // Botón para colapsar el menú
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFF4B5563), // border-gray-700 equivalente
                          width: 1.0,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _menuOpen = false;
                          });
                          Navigator.pop(context); // Cerrar el drawer
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B5563), // bg-gray-700 equivalente
                          foregroundColor: const Color(0xFFD1D5DB), // text-gray-300 equivalente
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close, size: 16),
                            SizedBox(width: 8),
                            Text('Colapsar menú'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD1D5DB)), // text-gray-300 equivalente
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFFD1D5DB), // text-gray-300 equivalente
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      tileColor: isActive ? const Color(0xFF4B5563) : null, // bg-gray-700 equivalente
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF374151), // bg-gray-800 equivalente
          title: const Text(
            'Cerrar Sesión',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(color: Color(0xFFD1D5DB)), // text-gray-300 equivalente
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFFD1D5DB)), // text-gray-300 equivalente
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}