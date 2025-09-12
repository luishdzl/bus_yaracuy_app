import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Importar para TimeoutException
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

  // URL de tu API Next.js en Vercel
  static const String apiUrl = 'http://localhost:3000/api/login';

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
      // Preparar los datos para enviar
      final Map<String, dynamic> requestBody = {
        'email': _emailController.text,
        'password': _passwordController.text,
        'rememberMe': _rememberMe,
      };

      // Realizar la petición HTTP a tu API Next.js
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      // Procesar la respuesta
      if (response.statusCode == 200) {
        // Login exitoso
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Aquí puedes guardar el token de autenticación si tu API lo devuelve
        // Por ejemplo: await secureStorage.write(key: 'token', value: responseData['token']);

        if (mounted) {
          setState(() => _loading = false);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MenuPantalla()),
          );
        }
      } else {
        // Error en el login
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        setState(() {
          _loading = false;
          _generalError =
              errorData['message'] ?? 'Error en el inicio de sesión';
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
      setState(() {
        _loading = false;
        _generalError = 'Error inesperado: $e';
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
