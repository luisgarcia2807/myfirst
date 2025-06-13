import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:mifirst/screens/vista_alergia_doctor.dart';
import 'package:mifirst/screens/vista_enfermedadespersistente_doctor.dart';
import 'package:mifirst/screens/vista_examenlaboratorio_doctor.dart';
import 'package:mifirst/screens/vista_imagenologia_doctor.dart';
import 'package:mifirst/screens/vista_signovitales_doctor.dart';
import 'package:mifirst/screens/vista_tramientofrecuente_doctor.dart';
import 'package:mifirst/screens/vista_tratamiento_actual_doctor.dart';
import 'package:mifirst/screens/vista_vacuna_doctor.dart';
import '../constans.dart';
import 'fotoPerfil.dart';

class DetallePacienteScreen extends StatefulWidget {
  final int idusuariopac;
  final int idusuariodoc;
  final String nombre;
  final String apellido;

  const DetallePacienteScreen({super.key, required this.idusuariopac,required this.idusuariodoc, required this.nombre, required this.apellido});

  @override
  State<DetallePacienteScreen> createState() => _DetallePacienteScreen();
}

class _DetallePacienteScreen extends State<DetallePacienteScreen> {
  final TextEditingController _credencialController = TextEditingController();
  String nombreUsuario = '';
  String apellidoUsuario = '';
  String cedulaUsuario = '';
  String emailUsuario = '';
  String telefonoUsuario = '';
  String fechaNacimientoUsuario = '';
  bool estadoUsuario = false;
  int idRolUsuario = 0;
  String tipoUsuario='';
  int idtipoUsuario=0;
  bool isLoading = true; // Para controlar el estado de carga
  int idPaciente = 0; // Para almacenar el id del paciente
  int idSangre = 0;   // Para almacenar el id de sangre
  String tipoSangre = '';
  String? foto='';
  int idUsuario=0;
  bool isLoadingSignos = false;
  bool hasErrorSignos = false;
  List<dynamic> alergias = [];
  List<dynamic> EnfermedadesPersistente = [];
  List<dynamic> vacunas = [];
  List<dynamic> tratamientos = [];
  List<dynamic> Tratamientofrecuente = [];
  List<dynamic> signovitales = [];

  Future<void> obtenerIdUsuarioDesdePaciente() async {
    final url = Uri.parse('$baseUrl/usuarios/api/usuario-desde-paciente/${widget.idusuariopac}/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var datos = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          idPaciente= datos['id_paciente'];
          idSangre=datos['id_sangre'];
          tipoSangre=datos['tipo_sangre'];
          tipoUsuario=datos['tipo'];
          idtipoUsuario=datos['id_u'];
          print(tipoUsuario);
          isLoading = false; // Terminamos la carga
        });
      } else {
        print('Error al obtener el id del usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> obtenerDatos(id) async {
    final url = Uri.parse('$baseUrl/usuarios/api/usuario/$id/');

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
  // Función para obtener el paciente, id_sangre y tipo de sangre
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
  Future<void> _fetchVacunas() async {


    final response = await http.get(Uri.parse('$baseUrl/usuarios/api/paciente/$idPaciente/ultimas-vacunas/'));




    if (response.statusCode == 200) {
      setState(() {
        vacunas = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Error al cargar vacunas');
    }
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
  Future<void> _fetchTratamientoActual() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/api/paciente/$idPaciente/tratamientos/'),
    );
    if (response.statusCode == 200) {
      setState(() {
        tratamientos = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Error al cargar vacunas');
    }
  }
  Future<void> _fetchTratamientofrecuente() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/api/tratamientos-cronicos/$idPaciente/'),
    );

    if (response.statusCode == 200) {
      setState(() {
        Tratamientofrecuente = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Error al cargar vacunas');
    }
  }
  Future<void> _fetchSignosVitales() async {
    setState(() {
      isLoadingSignos = true;
      hasErrorSignos = false;
    });

    try {
      final url = '$baseUrl/usuarios/api/signos_vitales/?paciente_id=$idPaciente';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          signovitales = data;

          // Verificar si hay signos viejos
          if (data.isNotEmpty) {
            final ultimaFecha = DateTime.parse(data.first['fecha']);
            final dias = DateTime.now().difference(ultimaFecha).inDays;

            if (dias > 30) {
              // Puedes mostrar una alerta o activar una bandera para mostrar advertencia visual
              Future.delayed(Duration.zero, () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Advertencia"),
                    content: Text("Los signos vitales registrados tienen más de 30 días."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Aceptar"),
                      ),
                    ],
                  ),
                );
              });
            }
          }
        });
      }
      else {
        setState(() {
          hasErrorSignos = true;
        });
      }
    } catch (e) {
      setState(() {
        hasErrorSignos = true;
      });
    } finally {
      setState(() {
        isLoadingSignos = false;
      });
    }
  }
  int calcularEdad(String fechaNacimiento) {
    DateTime fecha = DateTime.parse(fechaNacimiento);
    DateTime hoy = DateTime.now();
    int edad = hoy.year - fecha.year;
    if (hoy.month < fecha.month || (hoy.month == fecha.month && hoy.day < fecha.day)) {
      edad--;
    }
    return edad;
  }
  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }
  Future<void> _inicializarDatos() async {
    await obtenerIdUsuarioDesdePaciente();
    await obtenerDatos(idtipoUsuario); // no es necesario await si no depende de datos
    await obtenerDatosPacienteSangre(idUsuario);
    await _fetchSignosVitales();
    await _fetchAlergias(); // Llamar después de que idPaciente esté disponible
    await _fetchEnfermedadesPersistente(); // Llamar después de que idPaciente esté disponible
    await _fetchVacunas();
    await _fetchTratamientoActual();
    await _fetchTratamientofrecuente();

  }

  @override
  Widget build(BuildContext context) {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Indicador de carga mientras se obtienen los datos
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ENCABEZADO FIJO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),

                    // 👉 Nombre a la derecha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Dr. ${widget.nombre} ${widget.apellido}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CambiarFotoScreen(idusuario: idUsuario),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            padding: EdgeInsets.all(3),
                            child: foto == null || foto!.isEmpty
                                ? Icon(
                              Icons.person_pin,
                              color: Colors.white,
                              size: 70,
                            )
                                : ClipOval(
                              child: Image.network(
                                '$baseUrl$foto',
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4.0),
                              Text(
                                "Pc. $nombreUsuario $apellidoUsuario",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 1.0),
                              Text(
                                fechaHoy,
                                style: TextStyle(color: Colors.grey[300], fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),


              SizedBox(height: 25),

              // CONTENIDO DESLIZABLE
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Bloque: Información Personal
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[50]!, Colors.blue[100]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[800],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.person, color: Colors.white, size: 28),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Información personal",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text("$nombreUsuario $apellidoUsuario"),
                                    Text("CI: $cedulaUsuario"),
                                    fechaNacimientoUsuario != null && fechaNacimientoUsuario.isNotEmpty
                                        ? Text("${calcularEdad(fechaNacimientoUsuario)} años")
                                        : Text(""),
                                    Text("$telefonoUsuario"),
                                    Text("$emailUsuario"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tipo de sangre
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red[50]!, Colors.red[100]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[700],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.bloodtype, color: Colors.white, size: 28),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tipo de sangre",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.red[800],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "$tipoSangre",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Signos vitales
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VistaSignoVitalesDoctor(
                                  idusuario: idUsuario,
                                  nombre: widget.nombre,
                                  apellido: widget.apellido,
                                  idusuariodoc: widget.idusuariodoc,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.teal[50]!, Colors.teal[100]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.teal[700],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(Icons.monitor_heart, color: Colors.white, size: 28),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Signos vitales",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.teal[800],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      signovitales.isEmpty
                                          ? Text("No se registran signos vitales")
                                          : Builder(
                                        builder: (_) {
                                          final signo = signovitales.first;
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("• Fecha: ${signo['fecha'].toString().substring(0, 10)}"),
                                              Text("• Peso: ${signo['peso']} kg"),
                                              Text("• Altura: ${signo['altura']} m"),
                                              Text("• Presión: ${signo['presion_sistolica']}/${signo['presion_diastolica']} mmHg"),
                                              Text("• FC: ${signo['frecuencia_cardiaca']} lpm"),
                                              Text("• FR: ${signo['frecuencia_respiratoria']} rpm"),
                                              Text("• Temp: ${signo['temperatura']}°C"),
                                              Text("• SpO2: ${signo['spo2']}%"),
                                              Text("• Glucosa: ${signo['glucosa']} mg/dL"),
                                              Text("• IMC: ${signo['imc']}"),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Alergias
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VistaAlergiadoctor(
                                  id_paciente: widget.idusuariopac,
                                  nombre: widget.nombre,
                                  apellido: widget.apellido,
                                  idusuariodoc: widget.idusuariodoc,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange[50]!, Colors.orange[100]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[700],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(Icons.warning_amber, color: Colors.white, size: 28),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Alergias conocidas",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.orange[800],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      alergias.isEmpty
                                          ? Text("No se registran alergias")
                                          : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: alergias.map<Widget>((alergia) {
                                          return Text("• ${alergia['nombre_alergia']}");
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Vacunas
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VistaVacunadoctor(
                                  idusuario: idUsuario,
                                  nombre: widget.nombre,
                                  apellido: widget.apellido,
                                  idusuariodoc: widget.idusuariodoc,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green[50]!, Colors.green[100]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green[700],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(Icons.vaccines, color: Colors.white, size: 28),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Vacunas registradas",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      vacunas.isEmpty
                                          ? Text("No se registran vacunas")
                                          : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: vacunas.map<Widget>((vacuna) {
                                          return Text(
                                            "• ${vacuna['nombre_vacuna']} (${vacuna['dosis']}/${vacuna['max_dosis']})",
                                            style: TextStyle(fontSize: 14),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Enfermedades persistentes
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VistaEnfermedadPersistentedoctor(
                                  idusuario: idUsuario,
                                  nombre: widget.nombre,
                                  apellido: widget.apellido,
                                  idusuariodoc: widget.idusuariodoc,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple[50]!, Colors.purple[100]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[700],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(Icons.local_hospital, color: Colors.white, size: 28),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Enfermedades persistentes",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.purple[800],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      EnfermedadesPersistente.isEmpty
                                          ? Text("No se registran enfermedades")
                                          : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: EnfermedadesPersistente.map<Widget>((enfermedad) {
                                          return Text("• ${enfermedad['nombre_enfermedad']}");
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tratamientos actuales
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VistaTratamientoActualmenteDoctor(
                                  idusuario: idUsuario,
                                  nombre: widget.nombre,
                                  apellido: widget.apellido,
                                  idusuariodoc: widget.idusuariodoc,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.indigo[50]!, Colors.indigo[100]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo[700],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(Icons.medication, color: Colors.white, size: 28),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tratamientos actuales",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.indigo[800],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      tratamientos.where((item) => item['finalizado'] == false).isEmpty
                                          ? Text("No hay tratamientos activos")
                                          : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: tratamientos
                                            .where((item) => item['finalizado'] == false)
                                            .map<Widget>((item) {
                                          return Text("• ${item['nombre_medicamento']}");
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tratamiento frecuente
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VistaTratamientofrecuentedoctor(
                                  idusuario: idUsuario,
                                  nombre: widget.nombre,
                                  apellido: widget.apellido,
                                  idusuariodoc: widget.idusuariodoc,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.cyan[50]!, Colors.cyan[100]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyan.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan[700],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(Icons.history, color: Colors.white, size: 28),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tratamiento frecuente",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.cyan[800],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Tratamientofrecuente.isEmpty
                                          ? Text("No hay tratamientos registrados")
                                          : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: Tratamientofrecuente.map<Widget>((tratamiento) {
                                          return Text("• ${tratamiento['nombre_medicamento']}");
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Exámenes médicos
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExamenesPageDoctor(
                                  idusuario: idUsuario,
                                  nombre: widget.nombre,
                                  apellido: widget.apellido,
                                  idusuariodoc: widget.idusuariodoc,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.amber[50]!, Colors.amber[100]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[700],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(Icons.assignment, color: Colors.white, size: 28),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Ver exámenes médicos",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.amber[800],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Toque para revisar los archivos subidos",
                                        style: TextStyle(color: Colors.amber[700]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Imagenología médica
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImagenPageDoctor(
                                  idusuario: idUsuario,
                                  nombre: widget.nombre,
                                  apellido: widget.apellido,
                                  idusuariodoc: widget.idusuariodoc,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.deepOrange[50]!, Colors.deepOrange[100]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepOrange.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange[700],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(Icons.image, color: Colors.white, size: 28),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Ver imagenología médica",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.deepOrange[800],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Toque para revisar los archivos subidos",
                                        style: TextStyle(color: Colors.deepOrange[700]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
