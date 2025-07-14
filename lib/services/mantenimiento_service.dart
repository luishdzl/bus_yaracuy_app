import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/mantenimiento.dart';

class MantenimientoService {
  static Future<List<Mantenimiento>> cargarMantenimientos() async {
    final String data = await rootBundle.loadString('lib/assets/data/mantenimientos.json');
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Mantenimiento.fromJson(json)).toList();
  }

  static Future<List<Mantenimiento>> filtrarPorEstado(String estado) async {
    final mantenimientos = await cargarMantenimientos();
    return mantenimientos.where((m) => m.estado == estado).toList();
  }
}