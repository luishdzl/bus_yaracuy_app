import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/mantenimiento.dart';
import '../../models/articulo_solicitud.dart';
import '../../services/mantenimiento_service.dart';
import 'solicitud_despacho_modal.dart';

class DetallesMantenimientoPantalla extends StatefulWidget {
  final int mantenimientoId;

  const DetallesMantenimientoPantalla({
    super.key,
    required this.mantenimientoId,
  });

  @override
  State<DetallesMantenimientoPantalla> createState() => _DetallesMantenimientoPantallaState();
}

class _DetallesMantenimientoPantallaState extends State<DetallesMantenimientoPantalla> {
  Mantenimiento? _mantenimiento;
  List<ArticuloSolicitud> _solicitudes = [];
  bool _cargando = true;
  String _error = '';
  bool _temporizadorActivo = false;
  int _tiempoTranscurrido = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    
    if (_temporizadorActivo) {
      _iniciarTemporizador();
    }
  }

  void _iniciarTemporizador() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_temporizadorActivo && mounted) {
        setState(() {
          _tiempoTranscurrido++;
        });
        _iniciarTemporizador();
      }
    });
  }

  @override
  void dispose() {
    _temporizadorActivo = false;
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      setState(() {
        _cargando = true;
        _error = '';
      });

      final mantenimiento = await MantenimientoService.obtenerMantenimiento(widget.mantenimientoId);
      final solicitudes = await MantenimientoService.obtenerSolicitudesMantenimiento(widget.mantenimientoId);

      setState(() {
        _mantenimiento = mantenimiento;
        _solicitudes = solicitudes;
        
        if (mantenimiento.estado == 'EN_PROCESO' && mantenimiento.inicio != null) {
          _temporizadorActivo = true;
          _tiempoTranscurrido = _calcularTiempoTranscurrido(mantenimiento.inicio!);
          _iniciarTemporizador();
        } else {
          _temporizadorActivo = false;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  int _calcularTiempoTranscurrido(String inicio) {
    try {
      final inicioFecha = DateTime.parse(inicio);
      final ahora = DateTime.now();
      return ahora.difference(inicioFecha).inSeconds;
    } catch (e) {
      return 0;
    }
  }

  String _formatearTiempo(int segundos) {
    final hrs = segundos ~/ 3600;
    final mins = (segundos % 3600) ~/ 60;
    final secs = segundos % 60;
    return '${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return 'No especificada';
    try {
      final dateTime = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return fecha;
    }
  }

  Color _obtenerColorEstado(String? estado) {
    final estadoLower = estado?.toLowerCase() ?? '';
    switch (estadoLower) {
      case 'pendiente': return Colors.orange;
      case 'en_proceso': case 'en progreso': return Colors.blue;
      case 'completado': case 'finalizado': return Colors.green;
      case 'pausado': return Colors.yellow;
      default: return Colors.grey;
    }
  }

  Color _obtenerColorSolicitud(String estado) {
    switch (estado) {
      case 'PENDIENTE': return Colors.orange;
      case 'APROBADA': return Colors.blue;
      case 'DESPACHADA': return Colors.green;
      case 'RECHAZADA': return Colors.red;
      case 'EN_PROCESO': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Future<void> _actualizarEstado(String nuevoEstado, {String? comentario}) async {
    try {
      await MantenimientoService.actualizarEstadoMantenimiento(
        widget.mantenimientoId, 
        nuevoEstado, 
        comentario: comentario
      );
      
      await _cargarDatos();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a $nuevoEstado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar estado: $e')),
      );
    }
  }

  void _mostrarModalComentario(String accion) {
    String comentario = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(accion == 'PAUSADO' ? 'Pausar Mantenimiento' : 'Finalizar Mantenimiento'),
        content: TextField(
          decoration: InputDecoration(
            labelText: accion == 'PAUSADO' ? 'Motivo de pausa' : 'Observaciones finales',
            border: const OutlineInputBorder(),
          ),
          maxLines: 4,
          onChanged: (value) => comentario = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _actualizarEstado(accion, comentario: comentario);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaInfo(String titulo, List<Widget> hijos) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            ...hijos,
          ],
        ),
      ),
    );
  }

  Widget _construirFilaInfo(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detalles de Mantenimiento',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey[300],
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detalles de Mantenimiento',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey[300],
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Error: $_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarDatos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_mantenimiento == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detalles de Mantenimiento',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey[300],
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(
          child: Text(
            'No se encontró el mantenimiento',
            style: TextStyle(color: Colors.black87),
          ),
        ),
      );
    }

    final m = _mantenimiento!;
    final colorEstado = _obtenerColorEstado(m.estado);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles de Mantenimiento',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[300],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Card(
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mantenimiento #${m.id}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorEstado.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colorEstado),
                        ),
                        child: Text(
                          m.estado?.replaceAll('_', ' ') ?? 'Desconocido',
                          style: TextStyle(
                            color: colorEstado,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Información Principal
              _construirTarjetaInfo('Información Principal', [
                _construirFilaInfo('🚗 Unidad', m.unidad ?? 'No especificada'),
                _construirFilaInfo('👷 Operador', m.operador ?? 'No asignado'),
                _construirFilaInfo('🔧 Mecánico', m.mecanico ?? 'No asignado'),
                _construirFilaInfo('👥 Ayudante', m.ayudante ?? 'No asignado'),
                _construirFilaInfo('🚦 Prioridad', m.prioridad ?? 'No especificada'),
                _construirFilaInfo('📋 Tipo', m.tipo ?? 'No especificado'),
                _construirFilaInfo('🛣️ Ruta', m.rutaUnidad ?? 'No especificada'),
                _construirFilaInfo('📏 Kilometraje', m.kilometraje?.toString() ?? 'No especificado'),
              ]),

              // Fechas
              _construirTarjetaInfo('Fechas', [
                _construirFilaInfo('📅 Entrada', _formatearFecha(m.fechaEntrada)),
                _construirFilaInfo('⏰ Inicio', _formatearFecha(m.inicio)),
                _construirFilaInfo('⏸️ Pausa', _formatearFecha(m.fechaPausa)),
                _construirFilaInfo('✅ Finalización', _formatearFecha(m.fin)),
                _construirFilaInfo('⏱️ Duración', m.duracion ?? 'No especificada'),
                if (_temporizadorActivo)
                  _construirFilaInfo('⏳ Tiempo transcurrido', _formatearTiempo(_tiempoTranscurrido)),
              ]),

              // Diagnóstico y Recomendaciones
              if (m.diagnostico != null || m.recomendacion != null)
                _construirTarjetaInfo('Diagnóstico y Recomendaciones', [
                  if (m.diagnostico != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Diagnóstico:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.diagnostico!,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (m.recomendacion != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recomendación:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.recomendacion!,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                ]),

              // Observaciones
              if (m.observacionOperador != null || m.observacionSupervisor != null)
                _construirTarjetaInfo('Observaciones', [
                  if (m.observacionOperador != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Operador:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.observacionOperador!,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (m.observacionSupervisor != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Supervisor:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.observacionSupervisor!,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                ]),

              // SOLICITUDES DE DESPACHO (SE MANTIENE)
              _construirTarjetaInfo('Solicitudes de Despacho', [
                if (_solicitudes.isEmpty)
                  const Text(
                    'No hay solicitudes de despacho',
                    style: TextStyle(color: Colors.black87),
                  ),
                if (_solicitudes.isNotEmpty)
                  Column(
                    children: _solicitudes.map((solicitud) => Card(
                      color: Colors.grey[50],
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _obtenerColorSolicitud(solicitud.estado).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.inventory, color: _obtenerColorSolicitud(solicitud.estado)),
                        ),
                        title: Text(
                          solicitud.articuloNombre ?? 'Artículo ${solicitud.articuloId}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Código: ${solicitud.articuloCodigo ?? "N/A"}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            Text(
                              'Cantidad: ${solicitud.stock}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            Text(
                              'Estado: ${solicitud.estado}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            if (solicitud.fechaAprobacion != null)
                              Text(
                                'Aprobado: ${_formatearFecha(solicitud.fechaAprobacion)}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                          ],
                        ),
                        trailing: Text(
                          solicitud.estado,
                          style: TextStyle(
                            color: _obtenerColorSolicitud(solicitud.estado),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SolicitudDespachoModal(
                        mantenimiento: m,
                        onSolicitudCreada: _cargarDatos,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Nueva Solicitud de Despacho'),
                ),
              ]),

              // Controles de Estado
              _construirTarjetaInfo('Acciones', [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (m.estado != 'EN_PROCESO' && m.estado != 'FINALIZADO')
                      ElevatedButton(
                        onPressed: () => _actualizarEstado('EN_PROCESO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Iniciar'),
                      ),
                    if (m.estado == 'EN_PROCESO')
                      ElevatedButton(
                        onPressed: () => _mostrarModalComentario('PAUSADO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Pausar'),
                      ),
                    if (m.estado == 'PAUSADO')
                      ElevatedButton(
                        onPressed: () => _actualizarEstado('EN_PROCESO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Reanudar'),
                      ),
                    if (m.estado != 'FINALIZADO')
                      ElevatedButton(
                        onPressed: () => _mostrarModalComentario('FINALIZADO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[500],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Finalizar'),
                      ),
                  ],
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}