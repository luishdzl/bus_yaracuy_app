import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mantenimiento.dart';

class TablaMantenimientos extends StatelessWidget {
  final List<Mantenimiento> mantenimientos;
  final Function(Mantenimiento) onEditar;
  final Function(Mantenimiento) onEliminar;
  final Function(Mantenimiento) onVerComentario;

  const TablaMantenimientos({
    super.key,
    required this.mantenimientos,
    required this.onEditar,
    required this.onEliminar,
    required this.onVerComentario,
  });

  Color _getColorPrioridad(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'urgente':
        return Colors.red;
      case 'alta':
        return Colors.orange;
      case 'media':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 60,
        dataRowHeight: 70,
        columns: const [
          DataColumn(label: Text('Prioridad', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Unidad', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Operador', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Mecánico', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Inicio', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Fin', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Duración', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: mantenimientos.map((m) {
          return DataRow(
            cells: [
              // Prioridad
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getColorPrioridad(m.prioridad).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getColorPrioridad(m.prioridad),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    m.prioridad,
                    style: TextStyle(
                      color: _getColorPrioridad(m.prioridad),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Unidad
              DataCell(
                Tooltip(
                  message: 'ID: ${m.id}',
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Center(
                      child: Text(
                        m.unidad.replaceAll(RegExp(r'[^0-9]'), '').isEmpty
                            ? 'U${m.id}'
                            : m.unidad.replaceAll(RegExp(r'[^0-9]'), '').substring(0, 2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Operador
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(m.operador, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Operador', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),

              // Mecánico
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(m.mecanico, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Mecánico', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),

              // Inicio
              DataCell(
                m.inicio != null && m.inicio!.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(DateFormat('dd/MM/yy').format(DateTime.parse(m.inicio!))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm').format(DateTime.parse(m.inicio!)),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      )
                    : const Text('-', style: TextStyle(color: Colors.grey)),
              ),

              // Fin
              DataCell(
                m.fin != null && m.fin!.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(DateFormat('dd/MM/yy').format(DateTime.parse(m.fin!))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm').format(DateTime.parse(m.fin!)),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      )
                    : const Text('-', style: TextStyle(color: Colors.grey)),
              ),

              // Duración
              DataCell(Text(m.duracion ?? '-')),

              // Acciones
              DataCell(
                Row(
                  children: [
                    if (m.comentario != null && m.comentario!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.comment, size: 22),
                        color: Colors.indigo,
                        onPressed: () => onVerComentario(m),
                      ),
                  ],
                ),
              ),
            ],
          );
        }).toList(), // ← Aquí nos aseguramos de pasar List<DataRow>
      ),
    );
  }
}
