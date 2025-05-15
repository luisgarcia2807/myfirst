import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alergias.dart';
import '../constans.dart';

class VistaAlergia extends StatefulWidget {
  final int idusuario;

  const VistaAlergia( {super.key, required this.idusuario});

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
  String? foto='';
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
    final url = Uri.parse('$baseUrl/usuarios/api/usuario/${widget.idusuario}/');

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
          foto =datos['foto_perfil'];

          if (foto != null && foto!.isNotEmpty) {
            // Reemplazamos 'localhost' por tu baseUrl
            String nuevaFotoUrl = foto!.replaceFirst('http://localhost:8000', baseUrl);
            print(nuevaFotoUrl); // Esto imprimirá la URL con tu baseUrl
          } else {
            // Si la foto es nula o vacía, puedes manejar el caso como desees
            print('La foto no está disponible');
          }
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
    final url = Uri.parse('$baseUrl/usuarios/api/pacientes/por-usuario/$idUsuario/');

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
              scrollable: true, // Para evitar overflow vertical
              title: Text("Añadir Alergia"),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85, // Ajustar el ancho máximo
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tipo de alergia
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                            ),
                          ),
                          items: ['medicamento', 'alimento', 'ambiental', 'otro']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

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
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Alergia',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
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
                              ),
                            );
                          }
                        },
                      ),

                      // Nivel de alergia
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: nivelSeleccionado,
                          onChanged: (String? newValue) {
                            setState(() {
                              nivelSeleccionado = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Nivel de alergia',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          items: ['leve', 'moderada', 'severo'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

                      // Descripción
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _descripcionAlergiaController,
                          decoration: InputDecoration(
                            labelText: "Descripción",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
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
                      final url = Uri.parse('$baseUrl/usuarios/api/pacientes-alergias/');
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
      Uri.parse('$baseUrl/usuarios/api/pacientes/$idPaciente/alergias/'),
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
        return Icons.local_hospital;  // Ícono para medicamentos
      case 'Ambiental':
        return Icons.ac_unit;  // Ícono para alergias ambientales
      case 'Alimento':
        return Icons.restaurant_menu;  // Ícono más sano que simboliza comida 🍏
      default:
        return Icons.precision_manufacturing
    ;  // Ícono genérico para otros tipos
    }
  }
  Color _getColor(String tipo) {
    switch (tipo) {
      case 'Medicamento':
        return Colors.blue;  // Color azul para alergias a medicamentos
      case 'Ambiental':
        return Colors.green;  // Color verde para alergias ambientales
      case 'Alimento':
        return Colors.red;  // Ícono más sano que simboliza comida 🍏
      default:
        return Colors.grey;  // Color gris para otros tipos
    }
  }

  Future<void> eliminarAlergia(int idAlergiaPaciente) async {
    final url = Uri.parse('$baseUrl/usuarios/api/pacientes-alergias/$idAlergiaPaciente/');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Alergia eliminada correctamente")),
        );
        await _fetchAlergias(); // Actualizar la lista después de eliminar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar con el servidor")),
      );
      print('Error: $e');
    }
  }

  Future<void> editarAlergia({required int id, required String gravedad, required String observacion,}) async {

    final url = Uri.parse('$baseUrl//usuarios/api/pacientes-alergias/$id/');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'gravedad': gravedad,
          'observacion': observacion,
        }),
      );

      if (response.statusCode == 200) {
        print('Alergia actualizada exitosamente');
      } else {
        print('Error al editar alergia: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Excepción al editar alergia: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }
  Future<void> _inicializarDatos() async {
    await obtenerDatos(); // no es necesario await si no depende de datos
    await obtenerDatosPacienteSangre(widget.idusuario);
    await _fetchAlergias(); // Llamar después de que idPaciente esté disponible
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
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: EdgeInsets.all(3), // Reducido
                          child: foto == null || foto!.isEmpty
                              ? Icon(
                            Icons.person_pin,
                            color: Colors.white,
                            size: 100, // Reducido
                          )
                              : ClipOval(
                            child: Image.network(
                              '$baseUrl$foto',
                              width: 100, // Reducido
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 12),
                            Text(
                              "GESTOR DE ALERGIA",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              nombreUsuario,
                              style: TextStyle(color: Colors.white.withOpacity(0.7),fontSize: 30),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),


                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Fondo gris claro
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Botón de "Añadir alergias" en la parte superior derecha
                      Align(
                        alignment: Alignment.center, // Asegura que quede arriba y a la derecha
                        child: GestureDetector(
                          onTap: _mostrarDialogoAlergia,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF0D47A1), // Azul oscuro
                                    Color(0xFF1976D2), // Azul medio
                                    Color(0xFF42A5F5), // Azul claro


                                  ]),
                              borderRadius:  BorderRadius.circular(12),

                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // Evita que ocupe todo el ancho
                              children: [
                                const Icon(
                                  Icons.add_circle_outline_sharp,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Añadir alergias",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12,),
                      // Lista de alergias
                      Expanded(
                        child: alergias.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                          itemCount: alergias.length,
                          itemBuilder: (context, index) {
                            String tipo = alergias[index]['tipo_alergia'];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white,
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    // Parte izquierda con fondo dinámico
                                    Container(
                                      width: 60,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: _getColor(tipo),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _getIcon(tipo),
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),

                                    // Información de la alergia
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            alergias[index]['nombre_alergia'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Tipo: ${alergias[index]['tipo_alergia']}',
                                            style: const TextStyle(color: Colors.black54),
                                          ),
                                          Text(
                                            'Gravedad: ${alergias[index]['gravedad']}',
                                            style: const TextStyle(color: Colors.black54),
                                          ),
                                          Text(
                                            'Observación: ${alergias[index]['observacion']}',
                                            style: const TextStyle(color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Icono de opciones y botón de eliminar
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.black54),
                                          onPressed: () {
                                            final TextEditingController observacionController = TextEditingController(
                                              text: alergias[index]['observacion'],
                                            );

                                            String gravedadSeleccionada = alergias[index]['gravedad'].toString().toLowerCase();



                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Editar alergia'),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    // Menú de selección de gravedad
                                                    DropdownButtonFormField<String>(
                                                      value: gravedadSeleccionada,
                                                      decoration: InputDecoration(labelText: 'Gravedad'),
                                                      items: ['leve', 'moderada', 'grave'].map((valor) {
                                                        return DropdownMenuItem(
                                                          value: valor,
                                                          child: Text(valor),
                                                        );
                                                      }).toList(),
                                                      onChanged: (valor) {
                                                        if (valor != null) {
                                                          gravedadSeleccionada = valor;
                                                        }
                                                      },
                                                    ),
                                                    const SizedBox(height: 10),

                                                    // Campo de texto para observación
                                                    TextField(
                                                      controller: observacionController,
                                                      decoration: InputDecoration(labelText: 'Observación'),
                                                      maxLines: 2,
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(context).pop();

                                                      await editarAlergia(
                                                        id: alergias[index]['id'],
                                                        gravedad: gravedadSeleccionada,
                                                        observacion: observacionController.text,
                                                      );

                                                      // Actualiza los valores en la lista
                                                      setState(() {
                                                        alergias[index]['gravedad'] = gravedadSeleccionada;
                                                        alergias[index]['observacion'] = observacionController.text;
                                                      });
                                                    },
                                                    child: Text('Guardar'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),

                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Confirmar eliminación'),
                                                content: Text('¿Estás seguro de que deseas eliminar esta alergia?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: Text('Cancelar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(context).pop();
                                                      await eliminarAlergia(alergias[index]['id']);// Usa aquí el ID real
                                                    },
                                                    child: Text('Eliminar'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),

                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
  final url = Uri.parse('$baseUrl/usuarios/api/alergias/?tipo=$tipo');
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
