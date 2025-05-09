import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alergias.dart';

class VistaAlergia extends StatefulWidget {
  final int idusuario;
  const VistaAlergia({super.key, required this.idusuario});

  @override
  State<VistaAlergia> createState() => _VistaAlergia();
}

class _VistaAlergia extends State<VistaAlergia> {
  String nombreUsuario = '';
  String apellidoUsuario = '';
  String cedulaUsuario = '';
  String emailUsuario = '';
  String telefonoUsuario = '';
  String fechaNacimientoUsuario = '';
  bool estadoUsuario = false;
  int idRolUsuario = 0;
  bool isLoading = true;
  int idPaciente = 0;
  int idSangre = 0;
  String tipoSangre = '';
  String? nivelSeleccionado;
  String? tipoSeleccionado= 'medicamento';
  int? selectedAlergiaId;
  List<dynamic> alergias = [];  // Lista para almacenar las alergias



  final TextEditingController _descripcionAlergiaController = TextEditingController();

  Future<void> obtenerDatos() async {
    final url = Uri.parse('http://192.168.0.104:8000/usuarios/api/usuario/${widget.idusuario}/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var datos = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          nombreUsuario = datos['nombre'];
          apellidoUsuario = datos['apellido'];
          cedulaUsuario = datos['cedula'];
          emailUsuario = datos['email'];
          telefonoUsuario = datos['telefono'];
          fechaNacimientoUsuario = datos['fecha_nacimiento'];
          estadoUsuario = datos['estado'];
          idRolUsuario = datos['id_rol'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }
  Future<void> obtenerDatosPacienteSangre(int idUsuario) async {
    final url = Uri.parse('http://192.168.0.104:8000/usuarios/api/pacientes/por-usuario/$idUsuario/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var datos = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          idPaciente = datos['id_paciente']; // Asignamos el id del paciente
          idSangre = datos['id_sangre']['id_sangre']; // Asignamos el id de sangre
          tipoSangre = datos['id_sangre']['tipo_sangre']; // Asignamos el tipo de sangre
          isLoading = false; // Cambiamos el estado de carga
        });
      } else {
        print('Error al obtener el tipo de sangre: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  void _mostrarDialogoAlergia() {
    Future<List<Alergia>> futureAlergias = fetchAlergias(tipoSeleccionado!);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Añadir Alergia"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de alergia
                    DropdownButtonFormField<String>(
                      value: tipoSeleccionado,
                      onChanged: (String? newValue) {
                        setState(() {
                          tipoSeleccionado = newValue;
                          futureAlergias = fetchAlergias(newValue!);
                          selectedAlergiaId = null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Tipo de alergia",
                        border: OutlineInputBorder(),
                      ),
                      items: ['medicamento', 'alimento', 'ambiental', 'otro']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 10),

                    // Lista de alergias según tipo
                    FutureBuilder<List<Alergia>>(
                      future: futureAlergias,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('No hay alergias disponibles');
                        } else {
                          List<Alergia> alergias = snapshot.data!;
                          return DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Alergia',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedAlergiaId,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedAlergiaId = newValue;
                              });
                            },
                            items: alergias.map((Alergia alergia) {
                              return DropdownMenuItem<int>(
                                value: alergia.id,
                                child: Text(alergia.nombre),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),

                    SizedBox(height: 10),

                    // Nivel de alergia
                    DropdownButtonFormField<String>(
                      value: nivelSeleccionado,
                      onChanged: (String? newValue) {
                        setState(() {
                          nivelSeleccionado = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Nivel de alergia',
                        border: OutlineInputBorder(),
                      ),
                      items: ['leve', 'moderada', 'severo'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 10),

                    // Descripción
                    TextField(
                      controller: _descripcionAlergiaController,
                      decoration: InputDecoration(
                        labelText: "Descripción",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedAlergiaId != null && nivelSeleccionado != null) {
                      final url = Uri.parse('http://192.168.0.104:8000/usuarios/api/pacientes-alergias/');
                      final Map<String, dynamic> data = {
                        'paciente': idPaciente,
                        'alergia': selectedAlergiaId,
                        'gravedad': nivelSeleccionado,
                        'observacion': _descripcionAlergiaController.text,
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
                            SnackBar(content: Text("Alergia guardada correctamente")),
                          );
                          await _fetchAlergias();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error al guardar: ${response.statusCode}")),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error al conectar con el servidor")),
                        );
                        print('Error: $e');
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Completa todos los campos")),
                      );
                    }
                  },
                  child: Text("Guardar"),
                ),

              ],
            );
          },
        );
      },
    );
  }
  Future<void> _fetchAlergias() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/usuarios/api/pacientes/1/alergias/'),
    );

    if (response.statusCode == 200) {
      // Si la petición fue exitosa, procesamos la respuesta
      setState(() {
        alergias = jsonDecode(utf8.decode(response.bodyBytes));  // Decodificar la respuesta JSON
      });
    } else {
      // Si hubo un error en la petición
      throw Exception('Error al cargar alergias');
    }
  }
  IconData _getIcon(String tipo) {
    switch (tipo) {
      case 'Medicamento':
        return Icons.local_hospital;  // Un ícono de hospital para medicamentos
      case 'Ambiental':
        return Icons.ac_unit;  // Un ícono de clima para alergias ambientales
      default:
        return Icons.help_outline;  // Un ícono de ayuda para otros tipos
    }
  }
  Color _getColor(String tipo) {
    switch (tipo) {
      case 'Medicamento':
        return Colors.blue;  // Color azul para alergias a medicamentos
      case 'Ambiental':
        return Colors.green;  // Color verde para alergias ambientales
      default:
        return Colors.grey;  // Color gris para otros tipos
    }
  }
  @override
  void initState() {
    super.initState();
    obtenerDatos();
    obtenerDatosPacienteSangre(widget.idusuario);
    _fetchAlergias();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D47A1), // Azul oscuro
          Color(0xFF1976D2), // Azul medio
          Color(0xFF42A5F5), // Azul claro
          Color(0xFF7E57C2), // Morado
          Color(0xFF26C6DA), // Turquesa,
          ]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    SizedBox(height: 25),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.person_pin,
                            color: Colors.white,
                            size: 100,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "GESTOR DE ALERGIA",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              nombreUsuario,
                              style: TextStyle(color: Colors.white.withOpacity(0.7),fontSize: 24),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: _mostrarDialogoAlergia,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.add_circle_outline_sharp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey, // Fondo blanco y opacidad
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: alergias.isEmpty
                      ? Center(child: CircularProgressIndicator()) // Mostrar un indicador mientras se cargan los datos
                      : ListView.builder(
                    itemCount: alergias.length,
                    itemBuilder: (context, index) {
                      String tipo = alergias[index]['tipo_alergia'];
                      return Card(
                        margin: EdgeInsets.only(bottom: 10),
                        color: Colors.white, // Fondo blanco para todo el cuadro
                        child: ListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Row(
                            children: [
                              // Parte izquierda con el fondo del color de la alergia
                              SizedBox(height: 2,),
                              Container(
                                padding: EdgeInsets.only(left: 8),
                                width: 60, // Tamaño ajustado para el emoji
                                height: 120,

                                 // Tamaño ajustado para el emoji
                                decoration: BoxDecoration(
                                  color: _getColor(tipo), // Color de fondo basado en el tipo de alergia
                                  borderRadius: BorderRadius.circular(10), // Redondeo para el fondo del emoji
                                ),
                                child: Icon(
                                  _getIcon(tipo),
                                  size: 50, // Tamaño ajustado del ícono
                                  color: Colors.white, // Color del emoji (blanco para resaltar)
                                ),
                              ),
                              SizedBox(width: 15), // Espacio entre el emoji y el texto
                              // Parte derecha con el fondo blanco
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alergias[index]['nombre_alergia'],
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Text(
                                      'Tipo: ${alergias[index]['tipo_alergia']}',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Text(
                                      'Gravedad: ${alergias[index]['gravedad']}',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Text(
                                      'Observación: ${alergias[index]['observacion']}',
                                      style: TextStyle(color: Colors.black54),
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
              )








            ],
          ),
        ),
      ),
    );
  }
}

Future<List<Alergia>> fetchAlergias(String tipo) async {
  final url = Uri.parse('http://192.168.0.104:8000/usuarios/api/alergias/?tipo=$tipo');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    // Si la solicitud es exitosa, parsea los datos
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => Alergia.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las alergias');
  }
}
