import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mifirst/screens/fotoPerfil.dart';
import 'package:mifirst/screens/pantallapaciente.dart';
import 'package:mifirst/util/emoticon_face.dart';
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
  final _formKey = GlobalKey<FormState>();


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


  List<SolicitudDoctorPaciente> solicitudes = [];
  Future<void> _fetchSolicitudes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/api/solicitudes/paciente/$idPaciente/'),
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
    final url = Uri.parse('$baseUrl/usuarios/api/doctor-paciente/$id/aceptar/');

    final response = await http.post(
      url,

    );

    if (response.statusCode == 200) {
      print('Solicitud aceptada correctamente');
      await _fetchSolicitudes(); // Aquí podrías actualizar el estado de tu UI si usas setState o algún gestor de estado
    } else {
      print('Error al aceptar la solicitud: ${response.statusCode}');
    }
  }
  Future<void> rechazarSolicitud(int id) async {
    final url = Uri.parse('$baseUrl/usuarios/api/doctor-paciente/$id/rechazar/');

    final response = await http.post(
      url,
    );

    if (response.statusCode == 200) {
      print('Solicitud rechazada correctamente');
      await _fetchSolicitudes();// Aquí también puedes actualizar la UI si es necesario
    } else {
      print('Error al rechazar la solicitud: ${response.statusCode}');
    }
  }


  int _selectedIndex = 1; // Ya estamos en la pestaña de doctores

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return; // Ya está en Doctores, no hace nada

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PacienteScreen(idusuario: widget.idusuario),
        ),
      );
    } else {
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
    await obtenerDatos(); // no es necesario await si no depende de datos
    await obtenerDatosPacienteSangre(widget.idusuario);
    await _fetchSolicitudes(); // Llamar después de que idPaciente esté disponible
  }



  @override
  Widget build(BuildContext context) {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());
    return Scaffold(
      bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: Colors.indigo.withOpacity(0.2),
              labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
                if (states.contains(MaterialState.selected)) {
                  return TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600);
                }
                return TextStyle(color: Colors.grey);
              }),
              iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
                if (states.contains(MaterialState.selected)) {
                  return IconThemeData(color: Colors.indigo);
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
                icon: Icon(Icons.verified_user_outlined),
                selectedIcon: Icon(Icons.verified_user),
                label: 'Doctores',
              ),
              NavigationDestination(
                icon: Icon(Icons.qr_code_outlined),
                selectedIcon: Icon(Icons.qr_code),
                label: 'QR',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Ajustes',
              ),
            ],
          )


      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(

             child: SafeArea(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CambiarFotoScreen(idusuario: widget.idusuario,)), // Reemplaza con tu widget de destino
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
                        Expanded( // <- ¡Esta línea soluciona el overflow!
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4.0),
                              Text(
                                "Pc. $nombreUsuario $apellidoUsuario",
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
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Doctores Tratantes',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.more_horiz, color: Colors.indigo),
                      ],
                    ),
                    SizedBox(height: 25),

                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.indigo, // Fondo gris claro
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.indigo,
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



