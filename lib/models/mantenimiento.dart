class Mantenimiento {
  final int id;
  final String estado;
  final String prioridad;
  final String unidad;
  final String operador;
  final String mecanico;
  final String? inicio;
  final String? fin;
  final String? duracion;
  final String? comentario;

  Mantenimiento({
    required this.id,
    required this.estado,
    required this.prioridad,
    required this.unidad,
    required this.operador,
    required this.mecanico,
    this.inicio,
    this.fin,
    this.duracion,
    this.comentario,
  });

  factory Mantenimiento.fromJson(Map<String, dynamic> json) {
    return Mantenimiento(
      id: json['id'],
      estado: json['estado'],
      prioridad: json['prioridad'],
      unidad: json['unidad'],
      operador: json['operador'],
      mecanico: json['mecanico'],
      inicio: json['inicio'],
      fin: json['fin'],
      duracion: json['duracion'],
      comentario: json['comentario'],
    );
  }
}