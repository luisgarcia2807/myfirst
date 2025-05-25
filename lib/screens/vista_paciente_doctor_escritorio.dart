import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mifirst/constans.dart';
import 'package:mifirst/models/solicitudes.dart';
import 'package:mifirst/screens/bienvenido.dart';
import 'package:mifirst/screens/pantalla_doctor_escritorio.dart';
import 'package:mifirst/screens/vista_perfil_paciente_escritorio.dart';


class PacientesPorDoctorScreen extends StatefulWidget {
  const PacientesPorDoctorScreen({super.key});

  @override
  State<PacientesPorDoctorScreen> createState() =>
      _PacientesPorDoctorScreenState();
}

class _PacientesPorDoctorScreenState extends State<PacientesPorDoctorScreen> {
  int _selectedIndex = 2;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Inicio'},
    {'icon': Icons.calendar_today, 'label': 'Citas programadas'},
    {'icon': Icons.people, 'label': 'Pacientes'},
    {'icon': Icons.receipt_long, 'label': 'Órdenes médicas'},
    {'icon': Icons.settings, 'label': 'Ajustes'},
    {'icon': Icons.logout, 'label': 'Cerrar sesión'},
  ];

  List<SolicitudDoctorPaciente> solicitudes = [];

  Future<void> _fetchSolicitudes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/api/solicitudes/doctor/1/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        solicitudes = data.map((json) => SolicitudDoctorPaciente.fromJson(json)).toList();
      });
    } else {
      throw Exception('Error al cargar las solicitudes');
    }
  }



  /*final List<Map<String, String>> _pacientes = [
    {'nombre': 'Juan Pérez', 'cedula': '12345678'},
    {'nombre': 'María García', 'cedula': '87654321'},
    {'nombre': 'Luis Torres', 'cedula': '11223344'},
  ];*/



  String _busqueda = '';
  final TextEditingController _cedulaController = TextEditingController();
  Map<String, dynamic>? _datosPaciente; // para guardar todos los datos
  bool _pacienteSeleccionado = false;
  TextEditingController _comentarioController = TextEditingController();

  void _mostrarFormularioRegistro() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              scrollable: true,
              title: Text("Buscar Paciente"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Campo de cédula con lupa integrada
                  TextFormField(
                    controller: _cedulaController,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: InputDecoration(
                      labelText: "Cédula",
                      counterText: "",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          final cedula = _cedulaController.text.trim();
                          if (cedula.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Por favor ingresa una cédula')),
                            );
                            return;
                          }

                          try {
                            final url = Uri.parse('$baseUrl/usuarios/api/paciente/por-cedula/?cedula=$cedula');
                            final response = await http.get(url);
                            final data = jsonDecode(utf8.decode(response.bodyBytes));

                            if (response.statusCode == 200 && data['nombre'] != null) {
                              setStateDialog(() {
                                _datosPaciente = data;
                                _pacienteSeleccionado = false;
                              });
                            } else {
                              setStateDialog(() {
                                _datosPaciente = null;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(data['error'] ?? 'Paciente no encontrado')),
                              );
                            }
                          } catch (e) {
                            print('Error: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al buscar el paciente')),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  if (_datosPaciente != null)
                    Card(
                      elevation: 3,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${_datosPaciente!['nombre']} ${_datosPaciente!['apellido']}",
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                      ),
                                      SizedBox(height: 4),
                                      Text(" V-${_datosPaciente!['cedula']}"),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _pacienteSeleccionado,
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      _pacienteSeleccionado = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (_pacienteSeleccionado)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Paciente seleccionado',
                                  style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 12),

                  // Campo de comentario
                  TextFormField(
                    controller: _comentarioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Comentario',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: _pacienteSeleccionado
                      ? () async {
                    final comentario = _comentarioController.text.trim();
                    final pacienteId = _datosPaciente!['id_paciente'];
                    final doctorId = 1; // Define esto como corresponda

                    final url = Uri.parse('$baseUrl/usuarios/api/doctor-paciente/');
                    final Map<String, dynamic> data = {
                      'doctor': doctorId,
                      'paciente': pacienteId,
                      'comentario': comentario,
                    };

                    try {
                      final response = await http.post(
                        url,
                        headers: {"Content-Type": "application/json"},
                        body: json.encode(data),
                      );

                      if (response.statusCode == 201) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Solicitud enviada correctamente")),
                        );
                        // Aquí puedes recargar la lista si deseas
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error al guardar: ${response.statusCode}")),
                        );
                        print('Respuesta del servidor: ${response.body}');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error al conectar con el servidor")),
                      );
                      print('Error: $e');
                    }
                  }
                      : null,
                  child: Text("Guardar"),
                ),

              ],
            );
          },
        );
      },
    );
  }

//eliminar paciente, lo quite para que no diera error al no tener la lista predeterminada

  /*void _confirmarEliminacion(Map<String, String> paciente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar al paciente con cédula ${paciente['cedula']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                solicitudes.removeWhere(
                    (p) => p['cedula'] == paciente['cedula']);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Paciente con cédula ${paciente['cedula']} eliminado correctamente.'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }*/
  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }
  Future<void> _inicializarDatos() async {
    await _fetchSolicitudes(); // Llamar después de que idPaciente esté disponible
  }
  @override
  Widget build(BuildContext context) {
    /*  final pacientesFiltrados = _pacientes.where((paciente) {
      final nombre = paciente['nombre']!.toLowerCase();
      final cedula = paciente['cedula']!;
      return nombre.contains(_busqueda.toLowerCase()) ||
          cedula.contains(_busqueda);
    }).toList();*/

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: const Color(0xFF0D47A1),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'SaludMind',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                for (int i = 0; i < _menuItems.length; i++)
                  buildSidebarItem(
                    icon: _menuItems[i]['icon'],
                    label: _menuItems[i]['label'],
                    index: i,
                  ),
              ],
            ),
          ),

          // Main content
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pacientes Registrados',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: _mostrarFormularioRegistro,
                        icon:
                        const Icon(Icons.person_add, color: Colors.white),
                        label: const Text(
                          'Registrar paciente',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar paciente por nombre o cédula',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _busqueda = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: solicitudes.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                        itemCount: solicitudes.length,
                        itemBuilder: (context, index) {
                          final item = solicitudes[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Ícono alineado
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.person, size: 28, color: Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Información del paciente
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item.pacienteNombre.toString().toUpperCase()} ${item.pacienteApellido.toString().toUpperCase()}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Cédula: ${item.pacienteCedula}',
                                            style: const TextStyle(color: Colors.black54)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Estado: ${item.estado}',
                                              style: TextStyle(
                                                color: item.estado == 'pendiente'
                                                    ? Colors.orange[700]
                                                    : item.estado == 'aceptado'
                                                    ? Colors.green[700]
                                                    : item.estado == 'rechazado'
                                                    ? Colors.red[700]
                                                    : Colors.black54,
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: item.estado == 'aceptado'
                                                  ? () {
                                                // Acción cuando el estado es aceptado
                                                print('Ver detalles de ${item.pacienteNombre}');
                                              }
                                                  : null, // Deshabilitado si no está aceptado
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: item.estado == 'aceptado'
                                                    ? Colors.blue
                                                    : Colors.grey[300],
                                                foregroundColor: item.estado == 'aceptado'
                                                    ? Colors.white
                                                    : Colors.black45,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                minimumSize: const Size(40, 30),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: const Icon(
                                                Icons.visibility,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),



                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Panel derecho
          Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INFORMACIÓN GENERAL',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total de pacientes registrados:',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '${solicitudes.length}',
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSidebarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        // Redirección
        if (label == 'Inicio') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DoctorDesktopScreen()),
          );
        } else if (label == 'Cerrar sesión') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
      },
      child: Container(
        color:
        isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}