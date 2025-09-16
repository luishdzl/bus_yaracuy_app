class Mantenimiento {
  final int? id;
  final String? unidad;
  final String? operador;
  final String? mecanico;
  final String? ayudante;
  final String? prioridad;
  final String? estado;
  final String? tipo;
  final String? diagnostico;
  final String? recomendacion;
  final String? observacionOperador;
  final String? observacionSupervisor;
  final String? rutaUnidad;
  final String? inicio;
  final String? fin;
  final String? duracion;
  final String? comentario;
  final String? fechaEntrada;
  final String? fechaPausa;
  final String? fechaFinalizacion;
  final int? kilometraje;

  Mantenimiento({
    this.id,
    this.unidad,
    this.operador,
    this.mecanico,
    this.ayudante,
    this.prioridad,
    this.estado,
    this.tipo,
    this.diagnostico,
    this.recomendacion,
    this.observacionOperador,
    this.observacionSupervisor,
    this.rutaUnidad,
    this.inicio,
    this.fin,
    this.duracion,
    this.comentario,
    this.fechaEntrada,
    this.fechaPausa,
    this.fechaFinalizacion,
    this.kilometraje,
  });

  factory Mantenimiento.fromJson(Map<String, dynamic> json) {
    // Función helper para convertir string a int de forma segura
    int? tryParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    // Función helper para obtener nombre de persona
    String getPersonName(dynamic persona) {
      if (persona == null) return 'No asignado';
      if (persona is String) return persona;
      if (persona is Map<String, dynamic>) {
        if (persona['nombre'] != null) return persona['nombre'].toString();
        if (persona['nombres'] != null || persona['apellidos'] != null) {
          return '${persona['nombres'] ?? ''} ${persona['apellidos'] ?? ''}'.trim();
        }
      }
      return 'No disponible';
    }

    // Obtener el nombre de la unidad
    String getUnidadName(dynamic unidad) {
      if (unidad == null) return 'No especificada';
      if (unidad is String) return unidad;
      if (unidad is Map<String, dynamic>) {
        return unidad['idUnidad']?.toString() ?? 'No especificada';
      }
      return 'No especificada';
    }

    return Mantenimiento(
      id: tryParseInt(json['id']),
      unidad: getUnidadName(json['unidad']),
      operador: getPersonName(json['operador']),
      mecanico: getPersonName(json['mecanico']),
      ayudante: getPersonName(json['ayudante']),
      prioridad: json['prioridad']?.toString(),
      estado: json['estado']?.toString(),
      tipo: json['tipo']?.toString(),
      diagnostico: json['diagnostico']?.toString(),
      recomendacion: json['recomendacion']?.toString(),
      observacionOperador: json['observacionOperador']?.toString(),
      observacionSupervisor: json['observacionSupervisor']?.toString(),
      rutaUnidad: json['rutaUnidad']?.toString() ?? json['ruta']?['nombre']?.toString(),
      inicio: json['fechaInicio']?.toString() ?? json['inicio']?.toString(),
      fin: json['fechaFinalizacion']?.toString() ?? json['fin']?.toString(),
      duracion: json['duracionTotal']?.toString() ?? json['duracion']?.toString(),
      comentario: json['comentario']?.toString(),
      fechaEntrada: json['fechaEntrada']?.toString(),
      fechaPausa: json['fechaPausa']?.toString(),
      fechaFinalizacion: json['fechaFinalizacion']?.toString(),
      kilometraje: tryParseInt(json['kilometraje']),
    );
  }

  // Método para convertir a mapa (opcional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unidad': unidad,
      'operador': operador,
      'mecanico': mecanico,
      'ayudante': ayudante,
      'prioridad': prioridad,
      'estado': estado,
      'tipo': tipo,
      'diagnostico': diagnostico,
      'recomendacion': recomendacion,
      'observacionOperador': observacionOperador,
      'observacionSupervisor': observacionSupervisor,
      'rutaUnidad': rutaUnidad,
      'inicio': inicio,
      'fin': fin,
      'duracion': duracion,
      'comentario': comentario,
      'fechaEntrada': fechaEntrada,
      'fechaPausa': fechaPausa,
      'fechaFinalizacion': fechaFinalizacion,
      'kilometraje': kilometraje,
    };
  }
}