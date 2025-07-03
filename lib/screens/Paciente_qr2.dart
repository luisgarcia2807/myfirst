import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/screens/pantalla_doctor_mobile.dart';
import 'package:mifirst/screens/pantalla_doctor_paciente2.dart';
import 'package:mifirst/screens/pantallapaciente.dart';
import 'package:mifirst/screens/vista_paciente_bebe.dart';
import 'package:mifirst/screens/vista_paciente_bebe2.dart';
import 'package:mifirst/screens/vista_paciente_pacientedoctor.dart';
import 'package:mifirst/screens/vista_paciente_pacientedoctor2.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constans.dart';

class PacienteScreenqr2 extends StatefulWidget {
  final int id_paciente;
  final int idusuario;
  const PacienteScreenqr2({super.key, required this.id_paciente, required this.idusuario});

  @override
  State<PacienteScreenqr2> createState() => _PacienteScreenqr2();
}

class _PacienteScreenqr2 extends State<PacienteScreenqr2> {

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
  String tokenPaciente='';
  String tipoUsuario='';
  int idtipoUsuario=0;
  String sexo = '';
  bool aceptado= false;
  int idDoctor = 0;

  // Método para obtener los datos de la API
  Future<void> obtenerIdUsuarioDesdePaciente() async {
    final url = Uri.parse('$baseUrl/usuarios/api/usuario-desde-paciente/${widget.id_paciente}/');

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
          tokenPaciente=datos['token'];
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
  Future<void> obtenerDatosBebes(id) async {
    // La URL de tu API (reemplázala por la URL correcta)
    final url = Uri.parse('$baseUrl/usuarios/api/bebes/$id/'); // Asegúrate de cambiar esto

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // La respuesta fue exitosa, imprimimos los datos en la consola
        var datos = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          nombreUsuario = datos['nombre'];
          apellidoUsuario = datos['apellido'];
          fechaNacimientoUsuario = datos['fecha_nacimiento'];
          sexo= datos['sexo'];

        });

      } else {
        // Si el servidor no responde con un código 200
        print('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      // Si ocurre un error durante la petición
      print('Error: $e');
    }
  }
  Future<void> obtenerDatosDoctor(int idUsuario) async {
    final url = Uri.parse('$baseUrl/usuarios/api/doctores/por-usuario/$idUsuario/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final datos = jsonDecode(utf8.decode(response.bodyBytes));

        // Ejemplo: acceso a los campos
        idDoctor = datos['id_doctor'];




        // Aquí podrías actualizar el estado con setState o similar
      } else {
        print('Error al obtener doctor: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener doctor: $e');
    }
  }
  Future<void> obteneraceptaado() async {
    final url = Uri.parse('$baseUrl/usuarios/api/doctores/verificar-activo/$idDoctor/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final datos = jsonDecode(utf8.decode(response.bodyBytes));

        // Ejemplo: acceso a los campos
        aceptado = datos['aceptado'];
        print(aceptado);




        // Aquí podrías actualizar el estado con setState o similar
      } else {
        print('Error al obtener doctor: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener doctor: $e');
    }
  }
  int _selectedIndex = 3;

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return; // No hacer nada si ya está seleccionado

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PacienteScreen2(idusuario: widget.idusuario),
        ),
      );
    }
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolititudPaciente2(idusuario: widget.idusuario),
        ),
      );
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VistaBebe2(idusuario: widget.idusuario),
        ),
      );
    }if (index == 4) {
      if (aceptado == true) {
        // Si está aceptado, navegar al perfil de doctor
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorMobileScreen(idusuario: widget.idusuario,),
          ),
        );
      } else {
        // Si no está aceptado, mostrar mensaje de alerta
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Acceso no disponible',
                      style: TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Text(
                  'Aún el centro médico no te ha aceptado como doctor. Por favor espera la aprobación.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el diálogo
                  },
                  child: Text(
                    'Entendido',
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      }
    }else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }
  Future<void> _inicializarDatos() async {
    await obtenerIdUsuarioDesdePaciente();
    if (tipoUsuario == "bebe") {
      await obtenerDatosBebes(idtipoUsuario);
    } else {
      await obtenerDatos(idtipoUsuario);
    }
    await obtenerDatosDoctor(widget.idusuario);
    await obteneraceptaado();
  }
  @override
  Widget build(BuildContext context) {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: Colors.indigo,
              labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
                if (states.contains(MaterialState.selected)) {
                  return TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600);
                }
                return TextStyle(color: Colors.grey);
              }),
              iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
                if (states.contains(MaterialState.selected)) {
                  return IconThemeData(color: Colors.white);
                }
                return IconThemeData(color: Colors.grey);
              }),
            ),
          ),
          child: NavigationBar(
            height: 70,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.verified_user_outlined), // Nuevo ícono
                selectedIcon: Icon(Icons.verified_user), // Ícono cuando está seleccionado
                label: 'Doctores',
              ),
              NavigationDestination(
                icon: Icon(Icons.child_care_rounded),
                selectedIcon: Icon(Icons.child_care_rounded),
                label: 'Hijos',
              ),
              NavigationDestination(
                icon: Icon(Icons.qr_code),
                selectedIcon: Icon(Icons.qr_code_outlined),
                label: 'Qr',
              ),
              NavigationDestination(
                icon: Icon(Icons.switch_account_outlined),
                selectedIcon: Icon(Icons.switch_account),
                label: 'Perfil Doc',
              ),
            ],
          )

      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  SizedBox(height: 25),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {

                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.indigoAccent,
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
                      Expanded( // <- ¡Esta línea soluciona el overflow!
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4.0),
                            Text(
                              "Hola $nombreUsuario $apellidoUsuario",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis, // <-- por si aún se desborda
                            ),
                            SizedBox(height: 1.0),
                            Text(
                              fechaHoy,
                              style: TextStyle(color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis, // opcional
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),


                  SizedBox(height: 100),

                ],
              ),
            ),
            if (tokenPaciente.isNotEmpty)
              Column(
                children: [
                  Text(" QR del paciente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Builder(
                      builder: (context) {
                        double screenWidth = MediaQuery.of(context).size.width;
                        double qrSize = screenWidth * 0.8; // 80% del ancho de pantalla
                        return QrImageView(
                          data: tokenPaciente,
                          version: QrVersions.auto,
                          size: qrSize,
                          backgroundColor: Colors.white,
                        );
                      }
                  ),
                ],
              )


          ],
        ),
      ),
    );
  }
}



