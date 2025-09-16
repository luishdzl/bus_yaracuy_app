// services/auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:async';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // ✅ Guardar token de autenticación
  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: 'auth_token', value: token);
      print('✅ Token guardado correctamente');
    } catch (e) {
      print('❌ Error al guardar token: $e');
      rethrow;
    }
  }

  // ✅ Guardar datos del usuario
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final userDataString = jsonEncode(userData);
      await _secureStorage.write(key: 'user_data', value: userDataString);
      print('✅ User data guardado correctamente');
    } catch (e) {
      print('❌ Error al guardar user data: $e');
      rethrow;
    }
  }

  // ✅ Verificar si el usuario está logueado
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final userData = await getUserData();
      
      // Verificar que tenemos token Y datos de usuario
      return token != null && userData != null;
    } catch (e) {
      print('❌ Error en isLoggedIn: $e');
      return false;
    }
  }

  // ✅ Obtener token de autenticación
  static Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      print('🔄 Token recuperado: ${token != null ? "PRESENTE" : "AUSENTE"}');
      return token;
    } catch (e) {
      print('❌ Error obteniendo token: $e');
      return null;
    }
  }

  // ✅ Obtener datos del usuario
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDataString = await _secureStorage.read(key: 'user_data');
      print('🔄 User data recuperado: ${userDataString != null ? "PRESENTE" : "AUSENTE"}');
      
      if (userDataString != null) {
        final data = json.decode(userDataString);
        print('📋 User data contenido: $data');
        return data;
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo user data: $e');
      return null;
    }
  }

  // ✅ Obtener personalId como int (CORREGIDO)
  static Future<int?> getPersonalId() async {
    try {
      final userData = await getUserData();
      if (userData != null) {
        print('🔍 Buscando personalId en: ${userData.keys}');
        
        // Buscar en diferentes campos posibles y convertir a int
        final dynamic personalIdValue = userData['personalId'] ?? 
                                      userData['personalID'] ?? 
                                      userData['id_personal'] ??
                                      userData['mecanicoId'] ??
                                      userData['id']; // Último recurso
        
        if (personalIdValue != null) {
          // Convertir a int (maneja tanto String como int)
          final personalId = int.tryParse(personalIdValue.toString());
          print('✅ Personal ID encontrado: $personalId (valor original: $personalIdValue, tipo: ${personalIdValue.runtimeType})');
          return personalId;
        }
      }
      print('⚠️ Personal ID no encontrado en user data');
      return null;
    } catch (e) {
      print('❌ Error obteniendo personalId: $e');
      return null;
    }
  }

  // ✅ Debug: Ver todo el almacenamiento
  static Future<void> debugStorage() async {
    try {
      print('=== DEBUG ALMACENAMIENTO SECURO ===');
      final token = await _secureStorage.read(key: 'auth_token');
      final userDataString = await _secureStorage.read(key: 'user_data');
      
      print('🔑 Token: ${token != null ? "✅ (" + (token.length > 20 ? token.substring(0, 20) + "..." : token) + ")" : "❌"}');
      print('👤 User Data: ${userDataString != null ? "✅" : "❌"}');
      
      if (userDataString != null) {
        final data = json.decode(userDataString);
        print('📊 Datos del usuario:');
        data.forEach((key, value) {
          print('   $key: $value (tipo: ${value.runtimeType})');
        });
        
        // Mostrar específicamente el personalId
        final personalId = await getPersonalId();
        print('🔢 Personal ID obtenido: $personalId (tipo: ${personalId?.runtimeType})');
      }
      print('===================================');
    } catch (e) {
      print('❌ Error en debugStorage: $e');
    }
  }

  // ✅ Cerrar sesión
  static Future<void> logout() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_data');
      print('✅ Sesión cerrada correctamente');
    } catch (e) {
      print('❌ Error en logout: $e');
    }
  }

  // ✅ Opcional: Para compatibilidad con código que necesite String
  static Future<String?> getPersonalIdAsString() async {
    final personalId = await getPersonalId();
    return personalId?.toString();
  }
}