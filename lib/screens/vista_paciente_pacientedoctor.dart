import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/models/alergias.dart';
import '../constans.dart';
import '../models/solicitudes.dart';

class SolititudPaciente extends StatefulWidget {
  final int idusuario;
  const SolititudPaciente({super.key, required this.idusuario, });

  @override
  State<SolititudPaciente> createState() => _SolititudPaciente();
}

class _SolititudPaciente extends State<SolititudPaciente> {
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
      Uri.parse('http://192.168.0.103:8000/usuarios/api/solicitudes/paciente/1/'),
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

  Future<void> aceptarSolicitud(int id) async {
    final url = Uri.parse('http://192.168.0.103:8000/usuarios/api/doctor-paciente/$id/aceptar/');

    final response = await http.post(
      url,

    );

    if (response.statusCode == 200) {
      print('Solicitud aceptada correctamente');
      // Aquí podrías actualizar el estado de tu UI si usas setState o algún gestor de estado
    } else {
      print('Error al aceptar la solicitud: ${response.statusCode}');
    }
  }



  Future<void> rechazarSolicitud(int id) async {
    final url = Uri.parse('http://192.168.0.103:8000/usuarios/api/doctor-paciente/$id/rechazar/');

    final response = await http.post(
      url,
    );

    if (response.statusCode == 200) {
      print('Solicitud rechazada correctamente');
      // Aquí también puedes actualizar la UI si es necesario
    } else {
      print('Error al rechazar la solicitud: ${response.statusCode}');
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
              Color(0xFF0D47A1), // Azul oscuro
              Color(0xFF1976D2), // Azul medio
              Color(0xFF42A5F5), // Azul claro
              Color(0xFF7E57C2), // Morado
              Color(0xFF26C6DA), // más oscuro que 0xFF26C6DA
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
                              "DOCTORES TRATANTES",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              ' ${nombreUsuario ?? ''}',
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
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 3,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Ícono del doctor
                                      Container(
                                        width: 60,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.userDoctor,
                                            size: 30,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Información
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Nombre del doctor
                                            Text(
                                              'Dr ${item.doctorNombre.toString().toUpperCase()} ${item.doctorApellido.toString().toUpperCase()}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),

                                            // Cédula
                                            Text(
                                              'C.I.: ${item.doctorCedula}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(height: 10),

                                            // Estado
                                            Row(
                                              children: [
                                                const Text(
                                                  'Estado: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  item.estado.toUpperCase(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: item.estado == 'pendiente'
                                                        ? Colors.orange[800]
                                                        : item.estado == 'aceptado'
                                                        ? Colors.green[700]
                                                        : item.estado == 'rechazado'
                                                        ? Colors.red[700]
                                                        : Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),


                                            // Botones según estado
                                            if (item.estado == 'pendiente')
                                              if (item.estado == 'pendiente')
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        aceptarSolicitud(item.id);
                                                        print('Aceptar solicitud de ${item.doctorNombre}');
                                                      },
                                                      icon: const Icon(Icons.check_circle, size: 22, color: Colors.green),
                                                      tooltip: 'Aceptar',
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        rechazarSolicitud(item.id);
                                                        print('Rechazar solicitud de ${item.doctorNombre}');
                                                      },
                                                      icon: const Icon(Icons.cancel, size: 22, color: Colors.red),
                                                      tooltip: 'Rechazar',
                                                    ),
                                                  ],
                                                )
                                              else if (item.estado == 'aceptado')
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: IconButton(
                                                    onPressed: () {
                                                      print('Ver detalles de ${item.doctorNombre}');
                                                    },
                                                    icon: const Icon(Icons.visibility, size: 22, color: Colors.blue),
                                                    tooltip: 'Ver detalles',
                                                  ),
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



