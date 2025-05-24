import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/models/alergias.dart';
import '../constans.dart';
import '../models/solicitudes.dart';

class buscarPaciente extends StatefulWidget {
  final int idusuario;
  const buscarPaciente({super.key, required this.idusuario, });

  @override
  State<buscarPaciente> createState() => _buscarPaciente();
}

class _buscarPaciente extends State<buscarPaciente> {
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
  final TextEditingController _descripcionAlergiaController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  String? _nombrePaciente;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _datosPaciente; // para guardar todos los datos
  bool _pacienteSeleccionado = false;

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




  TextEditingController _comentarioController = TextEditingController();

  void _mostrarDialogoAlergia() {
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

                    final url = Uri.parse('http://192.168.0.106:8000/usuarios/api/doctor-paciente/');
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

  List<SolicitudDoctorPaciente> solicitudes = [];

  Future<void> _fetchSolicitudes() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.103:8000/usuarios/api/solicitudes/doctor/1/'),
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


  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }
  Future<void> _inicializarDatos() async {
    await obtenerDatos(); // no es necesario await si no depende de datos
    await obtenerDatosPacienteSangre(widget.idusuario);
    await _fetchSolicitudes(); // Llamar después de que idPaciente esté disponible
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
              Color(0xFF0B3C91), // más oscuro que 0xFF0D47A1
              Color(0xFF155A9C), // más oscuro que 0xFF1976D2
              Color(0xFF2E7AC7), // más oscuro que 0xFF42A5F5
              Color(0xFF5E35B1), // más oscuro que 0xFF7E57C2
              Color(0xFF0097A7), // más oscuro que 0xFF26C6DA
            ],
          ),
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
                              "GESTOR DE PACIENTE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Dr ${nombreUsuario ?? ''}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 30,
                              ),
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
                  padding: const EdgeInsets.all(15),
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
                                  "Registar un Paciente",
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
                      )


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



