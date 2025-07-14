import 'package:flutter/material.dart';
import '../../services/mantenimiento_service.dart';
import '../../widgets/tabla_mantenimientos.dart';
import '../../models/mantenimiento.dart';

class CompletadoPantalla extends StatefulWidget {
  const CompletadoPantalla({super.key});

  @override
  State<CompletadoPantalla> createState() => _CompletadoPantallaState();
}

class _CompletadoPantallaState extends State<CompletadoPantalla> {
    late Future<List<Mantenimiento>> _mantenimientosFuture;
  final String _estadoFiltro = "Completado";
  @override
  void initState() {
    super.initState();
    _mantenimientosFuture = MantenimientoService.filtrarPorEstado(_estadoFiltro);
  }

  void _editarMantenimiento(Mantenimiento mantenimiento) {
    // Lógica para editar
    print('Editar mantenimiento: ${mantenimiento.id}');
  }

  void _eliminarMantenimiento(Mantenimiento mantenimiento) {
    // Lógica para eliminar
    print('Eliminar mantenimiento: ${mantenimiento.id}');
  }

  void _verComentario(Mantenimiento mantenimiento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comentario'),
        content: SingleChildScrollView(
          child: Text(mantenimiento.comentario ?? 'No hay comentarios'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<Mantenimiento>>(
        future: _mantenimientosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return TablaMantenimientos(
              mantenimientos: snapshot.data!,
              onEditar: _editarMantenimiento,
              onEliminar: _eliminarMantenimiento,
              onVerComentario: _verComentario,
            );
          } else {
            return const Center(
              child: Text(
                'No hay mantenimientos en progreso',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
        },
      ),
    );
  }
}