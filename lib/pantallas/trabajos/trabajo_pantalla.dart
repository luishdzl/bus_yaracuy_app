import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mantenimiento_service.dart';
import '../../models/mantenimiento.dart';
import '../../services/auth_service.dart';
import '../detalles/detalles_mantenimiento_pantalla.dart'; 

class TrabajoPantalla extends StatefulWidget {
  const TrabajoPantalla({super.key});

  @override
  State<TrabajoPantalla> createState() => _TrabajoPantallaState();
}

class _TrabajoPantallaState extends State<TrabajoPantalla> {
  List<Mantenimiento> _mantenimientos = [];
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String _error = '';
  Map<String, dynamic>? _userData;
  int? _personalId;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      print('🔄 Iniciando carga de datos...');
      
      await AuthService.debugStorage();
      
      _userData = await AuthService.getUserData();
      print('👤 Usuario recuperado: ${_userData?['name']}');
      
      _personalId = await AuthService.getPersonalId();
      print('🔢 Personal ID obtenido: $_personalId');
      
      if (_personalId == null) {
        throw Exception('No se pudo identificar al personal. Por favor, inicia sesión nuevamente.');
      }

      print('📦 Solicitando mantenimientos para personalId: $_personalId');
      final lista = await MantenimientoService.cargarMantenimientos();
      print('✅ ${lista.length} mantenimientos recibidos');
      
      setState(() {
        _mantenimientos = lista;
        _loading = false;
        _error = '';
      });
      
    } catch (e) {
      print('❌ Error en _cargarDatos: $e');
      
      await AuthService.debugStorage();
      
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _onSearchChanged() {
    // Implementar búsqueda si es necesario
  }

  void _verDetalles(Mantenimiento mantenimiento) {
    if (mantenimiento.id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetallesMantenimientoPantalla(
            mantenimientoId: mantenimiento.id!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID de mantenimiento no disponible')),
      );
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'No especificada';
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  String _getEstado(Mantenimiento m) {
    return m.estado ?? 'Pendiente';
  }

  Color _getEstadoColor(String estado) {
    final estadoLower = estado.toLowerCase();
    switch (estadoLower) {
      case 'pendiente': return Colors.orange;
      case 'en_proceso': 
      case 'en progreso': return Colors.blue;
      case 'completado': 
      case 'finalizado': return Colors.green;
      case 'pausado': return Colors.yellow;
      default: return Colors.grey;
    }
  }

  Widget _buildMantenimientoCard(Mantenimiento m, Color color) {
    final estado = _getEstado(m);
    
    return GestureDetector(
      onTap: () => _verDetalles(m),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3), width: 2),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${m.id ?? "N/A"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        estado,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '🚗 Unidad: ${m.unidad ?? "No especificada"}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  '👷 Operador: ${m.operador ?? "No asignado"}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  '🔧 Mecánico: ${m.mecanico ?? "No asignado"}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  '🚦 Prioridad: ${m.prioridad ?? "No especificada"}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                if (m.inicio != null) 
                  Text(
                    '⏰ Inicio: ${_formatDateTime(m.inicio)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _verDetalles(m),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Ver Detalles Completos'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    await _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mis Trabajos',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey[300],
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Cargando tus mantenimientos...',
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mis Trabajos',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey[300],
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _refreshData,
            ),
          ],
        ),
        body: Container(
          color: Colors.grey[100],
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    _error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  if (_personalId != null)
                    Text(
                      'Personal ID: $_personalId',
                      style: const TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _refreshData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Trabajos',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[300],
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: _mantenimientos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text(
                        '🎉 No tienes mantenimientos asignados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Mecánico: ${_userData?['name'] ?? 'Usuario'}',
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      if (_personalId != null)
                        Text(
                          'ID: $_personalId',
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _refreshData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Actualizar'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _mantenimientos.length,
                  itemBuilder: (context, index) {
                    final m = _mantenimientos[index];
                    final estado = _getEstado(m);
                    final color = _getEstadoColor(estado);
                    return _buildMantenimientoCard(m, color);
                  },
                ),
        ),
      ),
    );
  }
}