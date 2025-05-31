import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/screens/vista_alergia.dart';
import 'package:mifirst/screens/vista_alergia_doctor.dart';
import 'package:mifirst/screens/vista_enfermedadespersistente.dart';
import 'package:mifirst/screens/vista_enfermedadespersistente_doctor.dart';
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
  bool isLoading = true; // Para controlar el estado de carga
  int idPaciente = 0; // Para almacenar el id del paciente
  int idSangre = 0;   // Para almacenar el id de sangre
  String tipoSangre = '';
  String? foto='';
  int idUsuario=0;
  List<dynamic> alergias = [];
  List<dynamic> EnfermedadesPersistente = [];
  List<dynamic> vacunas = [];
  List<dynamic> tratamientos = [];

  Future<void> obtenerIdUsuarioDesdePaciente() async {
    final url = Uri.parse('$baseUrl/usuarios/api/usuario-desde-paciente/${widget.idusuariopac}/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var datos = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          idUsuario = datos['id_usuario']; // Asignamos el id del usuario
          print(idUsuario);
          isLoading = false; // Terminamos la carga
        });
      } else {
        print('Error al obtener el id del usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> obtenerDatos() async {
    final url = Uri.parse('$baseUrl/usuarios/api/usuario/$idUsuario/');

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
          isLoading = false; // Cambiamos el estado de carga cuando los datos se han cargado
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
  Future<void> _fetchTratamientofrecuente() async {
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
    await obtenerDatos(); // no es necesario await si no depende de datos
    await obtenerDatosPacienteSangre(idUsuario);
    await _fetchAlergias(); // Llamar después de que idPaciente esté disponible
    await _fetchEnfermedadesPersistente(); // Llamar después de que idPaciente esté disponible
    await _fetchVacunas();
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
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Text("🧍", style: TextStyle(fontSize: 40)),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Información personal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    SizedBox(height: 10),
                                    Text("$nombreUsuario $apellidoUsuario"),
                                    Text("Ci: $cedulaUsuario"),
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
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Text("🩸", style: TextStyle(fontSize: 40)),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Tipo de sangre", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red[800])),
                                    SizedBox(height: 10),
                                    Text("$tipoSangre"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Alergias
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => VistaAlergiadoctor(idusuario: idUsuario, nombre: widget.nombre, apellido: widget.apellido,idusuariodoc: widget.idusuariodoc,)),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              children: [
                                Text("💊", style: TextStyle(fontSize: 40)),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Alergias conocidas",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.orange[800])),
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
                        // Vacuna
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
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              children: [
                                Text("🧪", style: TextStyle(fontSize: 40)), // Cambia el emoji si prefieres otro
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
                                          color: Colors.blue[800],
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
                        //enfermedades
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VistaEnfermedadPersistentedoctor(idusuario: idUsuario,
                                  nombre: widget.nombre,
                                  apellido: widget.apellido,
                                  idusuariodoc: widget.idusuariodoc,),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                Text("🏥", style: TextStyle(fontSize: 40)),
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
                                          ? Text("No se registran Enfermedades")
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
                        //tratamiento actual
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
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              children: [
                                Text("💊", style: TextStyle(fontSize: 40)),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Tratamientos actuales",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.blue[800])),
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



                        // Medicamentos
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Text("💉", style: TextStyle(fontSize: 40)),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Medicamentos actuales", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green[800])),
                                    SizedBox(height: 10),
                                    Text("• Metformina 500 mg (2 veces al día)"),
                                    Text("• Salbutamol Inhalador (constantemente)"),
                                  ],
                                ),
                              ),
                            ],
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
