import 'package:flutter/material.dart';
import '../../services/mantenimiento_service.dart';
import '../../widgets/tabla_mantenimientos.dart';
import '../../models/mantenimiento.dart';

class TrabajoPantalla extends StatefulWidget {
  const TrabajoPantalla({super.key});

  @override
  State<TrabajoPantalla> createState() => _TrabajoPantallaState();
}

class _TrabajoPantallaState extends State<TrabajoPantalla> {
  late Future<List<Mantenimiento>> _cargaFuture;
  List<Mantenimiento> _allMantenimientos = [];
  List<Mantenimiento> _filteredMantenimientos = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 1. Cargamos todos los mantenimientos
    _cargaFuture = MantenimientoService.cargarMantenimientos();
    _cargaFuture.then((lista) {
      setState(() {
        _allMantenimientos = lista;
        _filteredMantenimientos = lista;
      });
    });
    // 2. Escuchamos cambios en el buscador
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMantenimientos = _allMantenimientos.where((m) {
        // Ajusta aquí los campos a incluir en la búsqueda:
        return m.unidad.toLowerCase().contains(query) ||
               m.operador.toLowerCase().contains(query) ||
               m.mecanico.toLowerCase().contains(query) ||
               m.prioridad.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _editarMantenimiento(Mantenimiento m) => print('Editar ${m.id}');
  void _eliminarMantenimiento(Mantenimiento m) => print('Eliminar ${m.id}');
  void _verComentario(Mantenimiento m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Comentario'),
        content: Text(m.comentario ?? 'No hay comentarios'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimientos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar por unidad, operador, mecánico…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Mantenimiento>>(
        future: _cargaFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          // 3. Mostramos la tabla con la lista filtrada
          if (_filteredMantenimientos.isEmpty) {
            return const Center(child: Text('No se encontraron registros'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: TablaMantenimientos(
              mantenimientos: _filteredMantenimientos,
              onEditar: _editarMantenimiento,
              onEliminar: _eliminarMantenimiento,
              onVerComentario: _verComentario,
            ),
          );
        },
      ),
    );
  }
}
