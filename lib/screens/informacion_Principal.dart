import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InformacionPrincipalPaciente extends StatefulWidget {
  final int idusuario;
  const InformacionPrincipalPaciente({super.key, required this.idusuario, });

  @override
  State<InformacionPrincipalPaciente> createState() => _InformacionPrincipalPaciente();
}

class _InformacionPrincipalPaciente extends State<InformacionPrincipalPaciente> {
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
    obtenerDatos();
    obtenerDatosPacienteSangre(widget.idusuario);
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
              Color(0xFF42A5F5),
              Color(0xFF7E57C2),
              Color(0xFF26C6DA),
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
                              "$nombreUsuario",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              fechaHoy,
                              style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.notifications_on,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.phone,
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
                                    Text("${calcularEdad(fechaNacimientoUsuario)} años"),
                                    Text("$telefonoUsuario"),


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
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Text("💊", style: TextStyle(fontSize: 40)),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Alergias conocidas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange[800])),
                                    SizedBox(height: 10),
                                    Text("• Penicilina"),
                                    Text("• Mariscos"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Enfermedades
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
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
                                    Text("Enfermedades persistentes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[800])),
                                    SizedBox(height: 10),
                                    Text("• Diabetes tipo 2"),
                                    Text("• Asma"),
                                  ],
                                ),
                              ),
                            ],
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
