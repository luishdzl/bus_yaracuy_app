import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mantenimiento_service.dart';
import '../../models/mantenimiento.dart';

class TrabajoPantalla extends StatefulWidget {
  const TrabajoPantalla({super.key});

  @override
  State<TrabajoPantalla> createState() => _TrabajoPantallaState();
}

class _TrabajoPantallaState extends State<TrabajoPantalla> {
  List<Mantenimiento> _allMantenimientos = [];
  List<Mantenimiento> _filteredMantenimientos = [];
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _cargarMantenimientos();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarMantenimientos() async {
    try {
      final lista = await MantenimientoService.cargarMantenimientos();
      setState(() {
        _allMantenimientos = lista;
        _filteredMantenimientos = lista;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar mantenimientos: $e';
        _loading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMantenimientos = _allMantenimientos.where((m) {
        return m.id.toString().toLowerCase().contains(query) ||
               m.unidad.toLowerCase().contains(query) ||
               m.operador.toLowerCase().contains(query) ||
               m.mecanico.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _verDetalles(Mantenimiento mantenimiento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles Mantenimiento #${mantenimiento.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Unidad', mantenimiento.unidad),
              _buildDetailRow('Operador', mantenimiento.operador),
              _buildDetailRow('Mecánico', mantenimiento.mecanico),
              _buildDetailRow('Prioridad', mantenimiento.prioridad),
              _buildDetailRow('Estado', mantenimiento.estado),
              if (mantenimiento.inicio != null && mantenimiento.inicio!.isNotEmpty)
                _buildDetailRow('Fecha Inicio', mantenimiento.inicio!),
              if (mantenimiento.fin != null && mantenimiento.fin!.isNotEmpty)
                _buildDetailRow('Fecha Fin', mantenimiento.fin!),
              if (mantenimiento.duracion != null)
                _buildDetailRow('Duración', mantenimiento.duracion!),
              if (mantenimiento.comentario != null && mantenimiento.comentario!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text('Comentario:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(mantenimiento.comentario!),
                  ],
                ),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildMantenimientoCard(Mantenimiento mantenimiento, Color borderColor) {
    // Usar fecha de inicio si está disponible, sino usar un valor por defecto
    final fechaDisplay = mantenimiento.inicio != null && mantenimiento.inicio!.isNotEmpty
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(mantenimiento.inicio!))
        : 'Sin fecha';
    
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con fecha e icono
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fechaDisplay,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const Icon(Icons.directions_bus, color: Colors.blue, size: 16),
              ],
            ),
          ),
          
          // Contenido de la tarjeta
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID y UNIDAD
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${mantenimiento.id}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'UNIDAD: ${mantenimiento.unidad}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                // Información detallada
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('OPERADOR:', mantenimiento.operador),
                    _buildInfoRow('MECÁNICO:', mantenimiento.mecanico),
                    _buildInfoRow('PRIORIDAD:', mantenimiento.prioridad),
                    _buildInfoRow('ESTADO:', mantenimiento.estado),
                    if (mantenimiento.inicio != null && mantenimiento.inicio!.isNotEmpty)
                      _buildInfoRow('INICIO:', _formatDateTime(mantenimiento.inicio!)),
                    if (mantenimiento.fin != null && mantenimiento.fin!.isNotEmpty)
                      _buildInfoRow('FIN:', _formatDateTime(mantenimiento.fin!)),
                    if (mantenimiento.duracion != null)
                      _buildInfoRow('DURACIÓN:', mantenimiento.duracion!),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (mantenimiento.comentario != null && mantenimiento.comentario!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.comment, color: Colors.indigo, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Comentario'),
                              content: Text(mantenimiento.comentario!),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ElevatedButton(
                      onPressed: () => _verDetalles(mantenimiento),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        textStyle: const TextStyle(fontSize: 10),
                      ),
                      child: const Text('Detalles'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 10, color: Colors.black),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value.length > 15 ? '${value.substring(0, 15)}...' : value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion(String titulo, List<Mantenimiento> mantenimientos, Color color) {
    if (mantenimientos.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 columnas
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.65, // Relación de aspecto más cuadrada
          ),
          itemCount: mantenimientos.length,
          itemBuilder: (context, index) {
            return _buildMantenimientoCard(mantenimientos[index], color);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mantenimientos')),
        body: Center(
          child: Text(_error),
        ),
      );
    }

    // Filtrar por estado - ajusta según los estados que uses
    final pendientes = _filteredMantenimientos.where((m) => m.estado.toLowerCase().contains('pendiente')).toList();
    final enProgreso = _filteredMantenimientos.where((m) => m.estado.toLowerCase().contains('progreso')).toList();
    final completados = _filteredMantenimientos.where((m) => m.estado.toLowerCase().contains('completado')).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis mantenimientos asignados'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar por ID, unidad, operador o mecánico...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: _filteredMantenimientos.isEmpty
          ? const Center(
              child: Text('No se encontraron mantenimientos.'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildSeccion('Pendientes', pendientes, Colors.blue),
                  _buildSeccion('En Progreso', enProgreso, Colors.orange),
                  _buildSeccion('Completados', completados, Colors.green),
                ],
              ),
            ),
    );
  }
}