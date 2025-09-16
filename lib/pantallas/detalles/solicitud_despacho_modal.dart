import 'package:flutter/material.dart';
import '../../models/mantenimiento.dart';

class SolicitudDespachoModal extends StatefulWidget {
  final Mantenimiento mantenimiento;
  final Function() onSolicitudCreada;

  const SolicitudDespachoModal({
    super.key,
    required this.mantenimiento,
    required this.onSolicitudCreada,
  });

  @override
  State<SolicitudDespachoModal> createState() => _SolicitudDespachoModalState();
}

class _SolicitudDespachoModalState extends State<SolicitudDespachoModal> {
  final _formKey = GlobalKey<FormState>();
  final _articuloController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _comentarioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Solicitud de Despacho'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _articuloController,
                decoration: const InputDecoration(
                  labelText: 'Artículo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el artículo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la cantidad';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _comentarioController,
                decoration: const InputDecoration(
                  labelText: 'Comentario (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Aquí iría la llamada a la API para crear la solicitud
              // await _crearSolicitudDespacho();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Solicitud creada exitosamente')),
              );
              
              widget.onSolicitudCreada();
              Navigator.pop(context);
            }
          },
          child: const Text('Crear Solicitud'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _articuloController.dispose();
    _cantidadController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }
}