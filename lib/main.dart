import 'package:flutter/material.dart';
import 'pantallas/login/login_pantalla.dart';
import 'pantallas/menu/menu_pantalla.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BUS YARACUY - Mantenimientos',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: _getInitialRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Iniciando aplicación...'),
                  ],
                ),
              ),
            );
          }
          return snapshot.data ?? const LoginPantalla();
        },
      ),
      routes: {
        '/login': (context) => const LoginPantalla(),
        '/home': (context) => const MenuPantalla(),
      },
      debugShowCheckedModeBanner: false,
    );
  }

  Future<Widget?> _getInitialRoute() async {
    try {
      print('🔍 Verificando autenticación inicial...');
      
      // ✅ Ahora el método existe
      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (isLoggedIn) {
        print('✅ Usuario autenticado, redirigiendo a home');
        return const MenuPantalla();
      }
      
      print('❌ Usuario no autenticado, redirigiendo a login');
      return const LoginPantalla();
      
    } catch (e) {
      print('❌ Error en verificación: $e');
      return const LoginPantalla();
    }
  }
}