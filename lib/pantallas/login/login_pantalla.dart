import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../menu/menu_pantalla.dart';

class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key});

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  bool _showPassword = false;
  bool _rememberMe = false;
  bool _loading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // ✅ URL CORREGIDA - Cambiado localhost por tu dominio de Vercel
  static const String apiUrl = 'https://bus-yaracuy.vercel.app/api/login';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Cargar credenciales guardadas
  Future<void> _loadSavedCredentials() async {
    try {
      final SharedPreferences prefs = await _prefs;
      final bool rememberMe = prefs.getBool('rememberMe') ?? false;
      
      if (rememberMe) {
        final String? savedEmail = await _secureStorage.read(key: 'email');
        final String? savedPassword = await _secureStorage.read(key: 'password');
        
        if (mounted) {
          setState(() {
            _rememberMe = rememberMe;
            if (savedEmail != null) _emailController.text = savedEmail;
            if (savedPassword != null) _passwordController.text = savedPassword;
          });
        }
      }
    } catch (e) {
      print('Error loading saved credentials: $e');
    }
  }

  // Guardar credenciales
  Future<void> _saveCredentials() async {
    final SharedPreferences prefs = await _prefs;
    
    if (_rememberMe) {
      await _secureStorage.write(key: 'email', value: _emailController.text);
      await _secureStorage.write(key: 'password', value: _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await _secureStorage.delete(key: 'email');
      await _secureStorage.delete(key: 'password');
      await prefs.setBool('rememberMe', false);
    }
  }

  // Función de debug para ver datos almacenados
  Future<void> _debugStoredData() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final userDataString = await _secureStorage.read(key: 'user_data');
      
      print('=== DATOS ALMACENADOS DESPUÉS DEL LOGIN ===');
      print('Token: ${token != null ? "✅" : "❌"}');
      print('User Data: $userDataString');
      
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        print('ID del usuario: ${userData['id'] ?? "❌ NO ENCONTRADO"}');
        print('Nombre: ${userData['name'] ?? "N/A"}');
        print('Email: ${userData['email'] ?? "N/A"}');
        print('Estructura completa: $userData');
      }
      print('==========================================');
    } catch (e) {
      print('Error en debug: $e');
    }
  }

  // Guardar datos de sesión CORREGIDO
  Future<void> _saveSessionData(Map<String, dynamic> responseData) async {
    try {
      // Guardar credenciales si rememberMe está activado
      await _saveCredentials();
      
      // Guardar token de autenticación
      if (responseData['token'] != null) {
        await _secureStorage.write(key: 'auth_token', value: responseData['token']);
        print('✅ Token guardado correctamente');
      }
      
      // Guardar datos del usuario - BUSCAR EL ID EN DIFERENTES UBICACIONES
      Map<String, dynamic> userDataToSave = {};

      // Primero intentar con responseData['user']
      if (responseData['user'] != null && responseData['user'] is Map) {
        userDataToSave.addAll(Map<String, dynamic>.from(responseData['user']));
      }
      
      // Si no hay user, buscar en la raíz de responseData
      if (userDataToSave.isEmpty) {
        userDataToSave.addAll(responseData);
      }

      // Buscar el ID en diferentes campos posibles
      final dynamic userId = userDataToSave['id'] ?? 
                           userDataToSave['userId'] ?? 
                           userDataToSave['user_id'] ??
                           userDataToSave['Id'] ??
                           userDataToSave['ID'] ??
                           userDataToSave['iD'];

      // Si no encontramos ID, usar el email como fallback (temporal)
      if (userId == null) {
        print('⚠️ No se encontró campo ID en la respuesta del servidor');
        print('Estructura completa de la respuesta: $responseData');
        
        // Usar el email como ID temporal para testing
        userDataToSave['id'] = _emailController.text;
        print('⚠️ Usando email como ID temporal: ${_emailController.text}');
      } else {
        userDataToSave['id'] = userId.toString();
        print('✅ ID del usuario encontrado: $userId');
      }

      // Asegurar campos básicos
      if (!userDataToSave.containsKey('email')) {
        userDataToSave['email'] = _emailController.text;
      }

      if (!userDataToSave.containsKey('name')) {
        userDataToSave['name'] = _emailController.text.split('@').first;
      }

      // Guardar datos del usuario
      await _secureStorage.write(
        key: 'user_data', 
        value: jsonEncode(userDataToSave)
      );

      print('✅ Datos de usuario guardados correctamente');

      // Guardar timestamp de la sesión
      final SharedPreferences prefs = await _prefs;
      await prefs.setInt('session_timestamp', DateTime.now().millisecondsSinceEpoch);

      // Debug: verificar qué se guardó
      await _debugStoredData();

    } catch (e) {
      print('❌ Error al guardar datos de sesión: $e');
      rethrow;
    }
  }

  void _validate() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;

      if (_emailController.text.isEmpty) {
        _emailError = 'El email es requerido';
      } else if (!_emailController.text.contains('@')) {
        _emailError = 'Email inválido';
      }

      if (_passwordController.text.isEmpty) {
        _passwordError = 'La contraseña es requerida';
      } else if (_passwordController.text.length < 6) {
        _passwordError = 'Mínimo 6 caracteres';
      }
    });
  }

  Future<void> _submit() async {
    _validate();
    if (_emailError != null || _passwordError != null) return;

    setState(() {
      _loading = true;
      _generalError = null;
    });

    try {
      final Map<String, dynamic> requestBody = {
        'email': _emailController.text,
        'password': _passwordController.text,
        'rememberMe': _rememberMe,
      };

      print('📤 Enviando solicitud de login a: $apiUrl');
      print('📝 Datos enviados: $requestBody');

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Respuesta recibida - Status: ${response.statusCode}');
      print('📦 Body de la respuesta: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Login exitoso - guardar datos de sesión
        await _saveSessionData(responseData);

        if (mounted) {
          setState(() => _loading = false);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MenuPantalla()),
          );
        }
      } else {
        // Error en el login
        setState(() {
          _loading = false;
          _generalError = responseData['message'] ?? 
                         responseData['error'] ?? 
                         'Error en el inicio de sesión (${response.statusCode})';
        });
      }
    } on TimeoutException catch (_) {
      setState(() {
        _loading = false;
        _generalError = 'Tiempo de espera agotado. Intente nuevamente.';
      });
    } on http.ClientException catch (e) {
      setState(() {
        _loading = false;
        _generalError = 'Error de conexión: ${e.message}';
      });
    } catch (e) {
      print('❌ Error completo: $e');
      setState(() {
        _loading = false;
        _generalError = 'Error inesperado: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen
          Positioned.fill(
            child: Image.asset('lib/assets/bg.jpg', fit: BoxFit.cover),
          ),

          // Superposición oscura
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          // Contenido principal
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Encabezado
                        const Column(
                          children: [
                            Text(
                              'Sistema de Transporte',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ingrese sus credenciales para acceder',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Mostrar error general si existe
                        if (_generalError != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Text(
                              _generalError!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (_generalError != null) const SizedBox(height: 16),

                        // Formulario
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campo Email
                            const Text(
                              'Correo electrónico',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'tucorreo@ejemplo.com',
                                filled: true,
                                fillColor: const Color(0xFFF3F4F6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                errorText: _emailError,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) => _validate(),
                            ),
                            if (_emailError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  _emailError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Campo Contraseña
                            const Text(
                              'Contraseña',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                filled: true,
                                fillColor: const Color(0xFFF3F4F6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                ),
                                errorText: _passwordError,
                              ),
                              onChanged: (value) => _validate(),
                            ),
                            if (_passwordError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  _passwordError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Recordar sesión
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const Text(
                                  'Recordar sesión',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Botón de inicio de sesión
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor: Colors.red
                                      .withOpacity(0.7),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Iniciar sesión',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Pie de página
                        Text(
                          '© ${DateTime.now().year} BUSYARACUY. Todos los derechos reservados.',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}