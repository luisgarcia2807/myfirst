import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alergias.dart';
import '../constans.dart';
import '../models/enfermedadespersistente.dart';

class VistaEnfermedadPersistente extends StatefulWidget {
  final int idusuario;

  const VistaEnfermedadPersistente({super.key, required this.idusuario});

  @override
  State<VistaEnfermedadPersistente> createState() => _VistaEnfermedadPersistente();
}

class _VistaEnfermedadPersistente extends State<VistaEnfermedadPersistente> {
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
  String? tipoSeleccionado= 'Endocrina';
  int? selectedEnfermedadesPersistenteId;
  List<dynamic> EnfermedadesPersistente = [];  // Lista para almacenar las alergias



  final TextEditingController _descripcionEnfermdadController = TextEditingController();

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

  void _mostrarDialogoEnfermedades() {
    Future<List<EnfermedadPersistente>> futureEnfermedadesPersistente = fetchEnfermedadesPersistente(tipoSeleccionado!);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true, // Para evitar overflow vertical
              title: Text("Añadir Enfermedad persistente"),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85, // Ajustar el ancho máximo
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tipo de enfermedad
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: tipoSeleccionado,
                          onChanged: (String? newValue) {
                            setState(() {
                              tipoSeleccionado = newValue;
                              futureEnfermedadesPersistente = fetchEnfermedadesPersistente(newValue!);
                              selectedEnfermedadesPersistenteId= null;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Tipo de alergia",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                            ),
                          ),
                          items: ['Endocrina', 'Cardiovascular', 'Respiratoria', 'Neurologica','Psiquiatrica','Gastrointestinal','Reumatologica','Renal','Hematologica','Infectologia']


                        .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

                      // Lista de alergias según tipo
                      FutureBuilder<List<EnfermedadPersistente>>(
                        future: futureEnfermedadesPersistente,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No hay Enfermedad Persistente disponibles');
                          } else {
                            List<EnfermedadPersistente> enfermedades = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: DropdownButtonFormField<int>(
                                isExpanded: true, // ← necesario para permitir texto largo
                                decoration: InputDecoration(
                                  labelText: 'Enfermedad Persistente',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                value: selectedEnfermedadesPersistenteId,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedEnfermedadesPersistenteId = newValue;
                                  });
                                },
                                selectedItemBuilder: (BuildContext context) {
                                  return enfermedades.map((e) {
                                    return Text(
                                      e.nombre,
                                      overflow: TextOverflow.ellipsis, // ← recorta si es muy largo
                                      softWrap: false,
                                    );
                                  }).toList();
                                },
                                items: enfermedades.map((e) {
                                  return DropdownMenuItem<int>(
                                    value: e.id,
                                    child: Text(e.nombre), // ← aquí se muestra completo en el menú
                                  );
                                }).toList(),
                              ),
                            );
                          }
                        },
                      ),


                      // Descripción
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _descripcionEnfermdadController,
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
                    if (selectedEnfermedadesPersistenteId != null ) {
                      final url = Uri.parse('$baseUrl/usuarios/api/pacientes_enfermedades/');
                      final Map<String, dynamic> data = {
                        'paciente': idPaciente,
                        'enfermedad': selectedEnfermedadesPersistenteId,
                        'fecha_diagnostico': "2025-05-11",
                        'observacion': _descripcionEnfermdadController.text,
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
                            SnackBar(content: Text("Enfermedad persistente guardada correctamente")),
                          );
                          await _fetchEnfermedadesPersistente();
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



  Future<void> _fetchEnfermedadesPersistente() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/api/enfermedades/$idPaciente/paciente/'),
    );

    if (response.statusCode == 200) {
      // Si la petición fue exitosa, procesamos la respuesta
      setState(() {
        EnfermedadesPersistente = jsonDecode(utf8.decode(response.bodyBytes));  // Decodificar la respuesta JSON
      });
    } else {
      // Si hubo un error en la petición
      throw Exception('Error al cargar Enfermedades');
    }
  }
  IconData _getIcon(String tipo) {
    switch (tipo) {
      case 'Endocrina':
        return Icons.water_drop;
      case 'Cardiovascular':
        return Icons.favorite;
      case 'Respiratoria':
        return Icons.air;
      case 'Neurológica':
        return Icons.memory;
      case 'Psiquiátrica':
        return Icons.psychology;
      case 'Gastrointestinal':
        return Icons.lunch_dining;
      case 'Reumatológica':
        return Icons.accessibility_new;
      case 'Renal':
        return Icons.opacity;
      case 'Hematológica':
        return Icons.bloodtype;
      case 'Infecciosa':
        return Icons.sick;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getColor(String tipo) {
    switch (tipo) {
      case 'Endocrina':
        return Colors.purple;
      case 'Cardiovascular':
        return Colors.red;
      case 'Respiratoria':
        return Colors.lightBlue;
      case 'Neurológica':
        return Colors.indigo;
      case 'Psiquiátrica':
        return Colors.deepOrange;
      case 'Gastrointestinal':
        return Colors.brown;
      case 'Reumatológica':
        return Colors.teal;
      case 'Renal':
        return Colors.blueGrey;
      case 'Hematológica':
        return Colors.pink;
      case 'Infecciosa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> eliminarEnfermedadesPersistente(int idAlergiaPaciente) async {
    final url = Uri.parse('$baseUrl/usuarios/api/pacientes_enfermedades/$idAlergiaPaciente/');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Alergia eliminada correctamente")),
        );
        await _fetchEnfermedadesPersistente(); // Actualizar la lista después de eliminar
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
  Future<void> editarEnfermedadesPersistente({required int id, required String observacion,}) async {

    final url = Uri.parse('$baseUrl//usuarios/api/pacientes_enfermedades/$id/');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
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
    await _fetchEnfermedadesPersistente(); // Llamar después de que idPaciente esté disponible
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
                              "GESTOR DE ENFERMEDADES",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:22,
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
              SizedBox(height: 25),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Botón de "Añadir enfermedad"
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: _mostrarDialogoEnfermedades, // Reemplaza con tu función
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF0D47A1),
                                  Color(0xFF1976D2),
                                  Color(0xFF42A5F5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.add_circle_outline_sharp,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Añadir enfermedad",
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
                      const SizedBox(height: 12),
                      // Lista de enfermedades persistentes
                      Expanded(
                        child: EnfermedadesPersistente.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                          itemCount: EnfermedadesPersistente.length,
                          itemBuilder: (context, index) {
                            String tipo = EnfermedadesPersistente[index]['Tipo_enfermedad'];
                            final aprobado = EnfermedadesPersistente[index]['aprobado'] == true;
                            final doctor = EnfermedadesPersistente[index]['doctor_aprobador'];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white,
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // Parte izquierda con color e ícono
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

                                        // Información
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      EnfermedadesPersistente[index]['nombre_enfermedad'],
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  if (aprobado)
                                                    const Icon(Icons.verified, color: Colors.blue),
                                                ],
                                              ),
                                              Text(
                                                'Tipo: ${EnfermedadesPersistente[index]['Tipo_enfermedad']}',
                                                style: const TextStyle(color: Colors.black54),
                                              ),
                                              Text(
                                                'Observación: ${EnfermedadesPersistente[index]['observacion']}',
                                                style: const TextStyle(color: Colors.black54),
                                              ),
                                              if (aprobado && doctor != null && doctor.toString().isNotEmpty)
                                                Text('Doctor: $doctor', style: const TextStyle(color: Colors.black87)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Botones abajo si NO está aprobado
                                    if (!aprobado)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton.icon(
                                              icon: const Icon(Icons.edit, color: Colors.black54),
                                              label: const Text(''),
                                              onPressed: () {
                                                final TextEditingController observacionController = TextEditingController(
                                                  text: EnfermedadesPersistente[index]['observacion'],
                                                );

                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Editar enfermedad'),
                                                    content: TextField(
                                                      controller: observacionController,
                                                      decoration: const InputDecoration(labelText: 'Observación'),
                                                      maxLines: 2,
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: const Text('Cancelar'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          Navigator.of(context).pop();
                                                          await editarEnfermedadesPersistente(
                                                            id: EnfermedadesPersistente[index]['id'],
                                                            observacion: observacionController.text,
                                                          );
                                                          setState(() {
                                                            EnfermedadesPersistente[index]['observacion'] = observacionController.text;
                                                          });
                                                        },
                                                        child: const Text('Guardar'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            TextButton.icon(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              label: const Text(''),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Confirmar eliminación'),
                                                    content: const Text('¿Estás seguro de que deseas eliminar esta enfermedad?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: const Text('Cancelar'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          Navigator.of(context).pop();
                                                          await eliminarEnfermedadesPersistente(
                                                            EnfermedadesPersistente[index]['id'],
                                                          );
                                                        },
                                                        child: const Text('Eliminar'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
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

Future<List<EnfermedadPersistente>> fetchEnfermedadesPersistente(String tipo) async {
  final url = Uri.parse('$baseUrl/usuarios/api/enfermedades-persistentes/?tipo=$tipo');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    // Si la solicitud es exitosa, parsea los datos
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => EnfermedadPersistente.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las alergias');
  }
}
