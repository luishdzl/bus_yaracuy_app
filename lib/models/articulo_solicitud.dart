class ArticuloSolicitud {
  final int id;
  final int mantenimientoId;
  final int articuloId;
  final String? articuloNombre;
  final String? articuloCodigo;
  final int stock;
  final String estado;
  final String? aprobadoPor;
  final String? fechaAprobacion;
  final String? entregadoPor;
  final String? fechaEntrega;

  ArticuloSolicitud({
    required this.id,
    required this.mantenimientoId,
    required this.articuloId,
    this.articuloNombre,
    this.articuloCodigo,
    required this.stock,
    required this.estado,
    this.aprobadoPor,
    this.fechaAprobacion,
    this.entregadoPor,
    this.fechaEntrega,
  });

  factory ArticuloSolicitud.fromJson(Map<String, dynamic> json) {
    // Función helper para convertir string a int de forma segura
    int tryParseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    return ArticuloSolicitud(
      id: tryParseInt(json['id']),
      mantenimientoId: tryParseInt(json['mantenimientoId']),
      articuloId: tryParseInt(json['articuloId']),
      articuloNombre: json['articulo']?['nombre']?.toString(),
      articuloCodigo: json['articulo']?['codigo']?.toString(),
      stock: tryParseInt(json['stock']),
      estado: json['estado']?.toString() ?? 'PENDIENTE',
      aprobadoPor: json['aprobadoPor']?.toString(),
      fechaAprobacion: json['fechaAprobacion']?.toString(),
      entregadoPor: json['entregadoPor']?.toString(),
      fechaEntrega: json['fechaEntrega']?.toString(),
    );
  }
}