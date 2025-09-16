import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mantenimiento.dart';
import '../models/articulo_solicitud.dart';
import 'auth_service.dart';

class MantenimientoService {
  // ✅ URLs CORREGIDAS - Apuntando a tu Vercel
  static const String baseUrl = 'https://bus-yaracuy.vercel.app/api/auth/mantenimiento';
  static const String solicitudesBaseUrl = 'https://bus-yaracuy.vercel.app/api/solicitud';
  static const String articulosBaseUrl = 'https://bus-yaracuy.vercel.app/api/articulos';

  // Headers comunes para todas las solicitudes
  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Método para cargar mantenimientos del mecánico actual
  static Future<List<Mantenimiento>> cargarMantenimientos() async {
    try {
      print('🔄 Iniciando carga de mantenimientos...');
      
      // Obtener el personalId del usuario autenticado
      final personalId = await AuthService.getPersonalId();
      print('🔢 Personal ID para la solicitud: $personalId');
      
      if (personalId == null) {
        throw Exception('No se pudo obtener el ID del personal. Por favor, inicia sesión nuevamente.');
      }

      // Construir la URL con el personalId como parámetro
      final url = '$baseUrl?mecanicoId=$personalId';
      print('🌐 URL de la solicitud: $url');

      // Hacer la solicitud GET
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Mantenimientos recibidos: ${data.length}');
        
        if (data.isNotEmpty) {
          print('📋 Primer mantenimiento: ${data[0]}');
        }
        
        return data.map((json) => Mantenimiento.fromJson(json)).toList();
      } else {
        print('❌ Error del servidor: ${response.statusCode}');
        print('📋 Response body: ${response.body}');
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error en cargarMantenimientos: $e');
      rethrow;
    }
  }

  // Método para obtener un mantenimiento específico por ID
  static Future<Mantenimiento> obtenerMantenimiento(int id) async {
    try {
      final url = '$baseUrl/$id';
      print('🌐 URL de detalles: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Mantenimiento obtenido exitosamente');
        return Mantenimiento.fromJson(data);
      } else {
        print('❌ Error al obtener mantenimiento: ${response.statusCode}');
        print('📋 Response body: ${response.body}');
        throw Exception('Error al obtener mantenimiento: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error en obtenerMantenimiento: $e');
      rethrow;
    }
  }

  // Método para obtener solicitudes de un mantenimiento - CORREGIDO
  static Future<List<ArticuloSolicitud>> obtenerSolicitudesMantenimiento(int mantenimientoId) async {
    try {
      print('📦 Solicitando solicitudes para mantenimientoId: $mantenimientoId');
      
      // URL CORREGIDA - usa la API de solicitudes con query parameter
      final url = '$solicitudesBaseUrl?mantenimientoId=$mantenimientoId';
      print('🌐 URL de solicitudes: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Extraer el array de data de la respuesta
        List<dynamic> data;
        if (responseData is Map && responseData.containsKey('data')) {
          data = responseData['data'];
        } else if (responseData is List) {
          data = responseData;
        } else {
          data = [];
        }
        
        print('✅ Solicitudes recibidas: ${data.length}');
        
        if (data.isNotEmpty) {
          print('📋 Primera solicitud: ${data[0]}');
        }
        
        return data.map((json) => ArticuloSolicitud.fromJson(json)).toList();
      } else {
        print('❌ Error al obtener solicitudes: ${response.statusCode}');
        print('📋 Response body: ${response.body}');
        throw Exception('Error al obtener solicitudes: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error en obtenerSolicitudesMantenimiento: $e');
      rethrow;
    }
  }

  // Método para actualizar el estado de un mantenimiento
  static Future<void> actualizarEstadoMantenimiento(int id, String nuevoEstado, {String? comentario}) async {
    try {
      final url = '$baseUrl/$id';
      print('🌐 URL para actualizar estado: $url');

      final Map<String, dynamic> body = {'estado': nuevoEstado};
      if (comentario != null) {
        body['comentario'] = comentario;
      }

      print('📋 Datos a enviar: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('❌ Error al actualizar estado: ${response.statusCode}');
        print('📋 Response body: ${response.body}');
        throw Exception('Error al actualizar estado: ${response.statusCode}');
      }
      
      print('✅ Estado actualizado exitosamente');
    } catch (e) {
      print('💥 Error en actualizarEstadoMantenimiento: $e');
      rethrow;
    }
  }

  // Método para crear nueva solicitud de despacho - CORREGIDO
  static Future<Map<String, dynamic>> crearSolicitudDespacho({
    required int mantenimientoId,
    required List<Map<String, dynamic>> articulos,
    String? comentario,
  }) async {
    try {
      print('📦 Creando nueva solicitud de despacho');
      
      // URL CORREGIDA - usa la API de solicitudes
      final url = solicitudesBaseUrl;
      print('🌐 URL para crear solicitud: $url');

      // Estructura de datos según tu API
      final Map<String, dynamic> body = {
        'mantenimientoId': mantenimientoId,
        'articulos': articulos.map((art) => ({
          'articuloId': art['articuloId'],
          'stock': art['stock'],
        })).toList(),
        if (comentario != null) 'comentario': comentario,
      };

      print('📋 Datos de la solicitud: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('✅ Solicitud creada exitosamente');
        print('📋 Respuesta: $responseData');
        return responseData;
      } else {
        print('❌ Error al crear solicitud: ${response.statusCode}');
        print('📋 Response body: ${response.body}');
        throw Exception('Error al crear solicitud: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('💥 Error en crearSolicitudDespacho: $e');
      rethrow;
    }
  }

  // Método para obtener artículos disponibles
  static Future<List<Map<String, dynamic>>> obtenerArticulosDisponibles() async {
    try {
      print('📦 Solicitando artículos disponibles');
      
      final url = articulosBaseUrl;
      print('🌐 URL de artículos: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Manejar diferentes formatos de respuesta
        List<dynamic> data;
        if (responseData is Map && responseData.containsKey('data')) {
          data = responseData['data'];
        } else if (responseData is List) {
          data = responseData;
        } else {
          data = [];
        }
        
        print('✅ Artículos recibidos: ${data.length}');
        
        return data.map((item) {
          // Convertir todos los IDs a números
          final id = item['id'] is int ? item['id'] : int.tryParse(item['id']?.toString() ?? '') ?? 0;
          final stock = item['stock'] is int ? item['stock'] : int.tryParse(item['stock']?.toString() ?? '') ?? 0;
          
          return {
            'id': id,
            'nombre': item['nombre']?.toString() ?? 'Sin nombre',
            'codigo': item['codigo']?.toString() ?? 'SIN-COD',
            'stock': stock,
            'unidad': item['unidad']?.toString() ?? 'N/A',
            'proveedor': item['proveedor']?.toString() ?? 'N/A',
          };
        }).toList();
      } else {
        print('❌ Error al obtener artículos: ${response.statusCode}');
        print('📋 Response body: ${response.body}');
        throw Exception('Error al obtener artículos: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error en obtenerArticulosDisponibles: $e');
      rethrow;
    }
  }

  // Método para actualizar una solicitud existente
  static Future<Map<String, dynamic>> actualizarSolicitudDespacho({
    required int solicitudId,
    required String estado,
    String? comentario,
  }) async {
    try {
      print('📦 Actualizando solicitud de despacho: $solicitudId');
      
      final url = '$solicitudesBaseUrl?id=$solicitudId';
      print('🌐 URL para actualizar solicitud: $url');

      final Map<String, dynamic> body = {
        'estado': estado,
        if (comentario != null) 'comentario': comentario,
      };

      print('📋 Datos de actualización: $body');

      final response = await http.patch(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(body),
      );

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Solicitud actualizada exitosamente');
        print('📋 Respuesta: $responseData');
        return responseData;
      } else {
        print('❌ Error al actualizar solicitud: ${response.statusCode}');
        print('📋 Response body: ${response.body}');
        throw Exception('Error al actualizar solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error en actualizarSolicitudDespacho: $e');
      rethrow;
    }
  }
}