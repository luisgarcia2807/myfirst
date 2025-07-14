import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/screens/fotoPerfil.dart';
import 'package:mifirst/screens/vista_alergia.dart';
import 'package:mifirst/screens/vista_enfermedadespersistente.dart';
import 'package:mifirst/screens/vista_examenlaboratorio.dart';
import 'package:mifirst/screens/vista_imagenologia.dart';
import 'package:mifirst/screens/vista_paciente_bebe.dart';
import 'package:mifirst/screens/vista_paciente_pacientedoctor.dart';
import 'package:mifirst/screens/vista_signovitales.dart';
import 'package:mifirst/screens/vista_tramientofrecuente.dart';
import 'package:mifirst/screens/vista_tratamiento_actual.dart';
import 'package:mifirst/screens/vista_vacuna.dart';
import '../util/emoticon_face.dart';
import '../constans.dart';
import 'Paciente_qr.dart';
import 'bienvenido.dart';
import 'informacion_Principal.dart';

class PacienteScreen extends StatefulWidget {
  final int idusuario;
  const PacienteScreen({super.key, required this.idusuario});

  @override
  State<PacienteScreen> createState() => _PacienteScreen();
}

class _PacienteScreen extends State<PacienteScreen> {

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

  // Método para obtener los datos de la API
  Future<void> obtenerDatos() async {
    // La URL de tu API (reemplázala por la URL correcta)
    final url = Uri.parse('$baseUrl/usuarios/api/usuario/${widget.idusuario}/'); // Asegúrate de cambiar esto

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // La respuesta fue exitosa, imprimimos los datos en la consola
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
            String nuevaFotoUrl = foto!.replaceFirst('http://localhost:8000', baseUrl);
            print('URL final de la imagen: $nuevaFotoUrl');

          } else {
            print('La foto no está disponible');

          }
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

  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return; // No hacer nada si ya está seleccionado

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolititudPaciente(idusuario: widget.idusuario),
        ),
      );
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VistaBebe(idusuario: widget.idusuario),
        ),
      );
    }
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PacienteScreenqr(idusuario: widget.idusuario, id_paciente: idPaciente,),
        ),
      );
    }
    if (index == 4) {
      // Opción de cerrar sesión
      _mostrarDialogoCerrarSesion().then((shouldLogout) {
        if (shouldLogout) {
          _cerrarSesion();
        }
      });
    }
    else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Método para mostrar el diálogo de confirmación de cierre de sesión
  Future<bool> _mostrarDialogoCerrarSesion() async {
    return await showDialog(
      context: context,
      barrierDismissible: false, // No permite cerrar tocando fuera del diálogo
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.red,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 60,
              ),
              SizedBox(height: 20),
              Text(
                '¿Estás seguro que quieres cerrar sesión?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Se perderá la sesión actual y tendrás que iniciar sesión nuevamente.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Retorna false (no cerrar)
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Retorna true (cerrar sesión)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false; // Retorna false si se cierra el diálogo sin seleccionar
  }

  // Método para cerrar sesión
  void _cerrarSesion() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  Future<void> _inicializarDatos() async {
    await obtenerDatos(); // no es necesario await si no depende de datos
    await obtenerDatosPacienteSangre(widget.idusuario);
  }

  @override
  Widget build(BuildContext context) {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return WillPopScope(
      onWillPop: () async {
        // Intercepta el botón de retroceso
        bool shouldLogout = await _mostrarDialogoCerrarSesion();
        if (shouldLogout) {
          _cerrarSesion();
        }
        return false; // Siempre retorna false para evitar el comportamiento por defecto
      },
      child: Scaffold(
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
                  icon: Icon(Icons.verified_user_outlined),
                  selectedIcon: Icon(Icons.verified_user),
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
                  icon: Icon(Icons.logout),
                  selectedIcon: Icon(Icons.logout),
                  label: 'Salir',
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CambiarFotoScreen(idusuario: widget.idusuario,)), // Reemplaza con tu widget de destino
                            );
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

                    SizedBox(height: 25),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.indigo),
                          SizedBox(width: 5),
                          Text(
                            'Explorar',
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '¿Cómo te sientes?',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.more_horiz, color: Colors.indigo),
                      ],
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            EmoticonFace(emoticonface: '😃', color: Colors.green),
                            SizedBox(height: 8),
                            Text('Excelente', style: TextStyle(color: Colors.black)),
                          ],
                        ),
                        Column(
                          children: [
                            EmoticonFace(emoticonface: '🙂', color: Colors.limeAccent),
                            SizedBox(height: 8),
                            Text('Bien', style: TextStyle(color: Colors.black)),
                          ],
                        ),
                        Column(
                          children: [
                            EmoticonFace(emoticonface: '😐', color: Colors.orangeAccent),
                            SizedBox(height: 8),
                            Text('Regular', style: TextStyle(color: Colors.black)),
                          ],
                        ),
                        Column(
                          children: [
                            EmoticonFace(emoticonface: '😢', color: Colors.red),
                            SizedBox(height: 8),
                            Text('Mal', style: TextStyle(color: Colors.black)),
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
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Principal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.indigo,
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            CardItem(
                              emoji: '📊',
                              title: 'Signos Vitales',
                              subtitle: 'Indicadores clave',
                              color: Color(0xFF1F2937), // Gris carbón
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VistaSignoVitales(id_paciente: idPaciente),
                                  ),
                                );
                              },
                            ),
                            CardItem(
                              emoji: '⚠️',
                              title: 'Alergias',
                              subtitle: 'Reacciones conocidas',
                              color: Color(0xFF991B1B), // Rojo oscuro elegante
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VistaAlergia(id_paciente: idPaciente),
                                  ),
                                );
                              },
                            ),
                            CardItem(
                              emoji: '💉',
                              title: 'Vacunas',
                              subtitle: 'Historial de inmunización',
                              color: Color(0xFF1E40AF), // Azul real
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VistaVacuna(id_paciente: idPaciente),
                                  ),
                                );
                              },
                            ),
                            CardItem(
                              emoji: '💊',
                              title: 'Tratamiento Actual',
                              subtitle: 'Medicamentos en curso',
                              color: Color(0xFF0F766E), // Verde azulado oscuro
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VistaTratamientoActualmente(id_paciente: idPaciente),
                                  ),
                                );
                              },
                            ),
                            CardItem(
                              emoji: '🫁',
                              title: 'Enfermedades Persistentes',
                              subtitle: 'Condiciones crónicas',
                              color: Color(0xFF581C87), // Púrpura profundo
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VistaEnfermedadPersistente(id_paciente: idPaciente),
                                  ),
                                );
                              },
                            ),
                            CardItem(
                              emoji: '🩹',
                              title: 'Tratamientos Frecuentes',
                              subtitle: 'Medicinas habituales',
                              color: Color(0xFF374151), // Gris pizarra
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VistaTratamientofrecuente(id_paciente: idPaciente),
                                  ),
                                );
                              },
                            ),
                            CardItem(
                              emoji: '🔬',
                              title: 'Exámenes',
                              subtitle: 'Resultados de laboratorio',
                              color: Color(0xFF0C4A6E), // Azul petróleo
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExamenesPage(id_paciente: idPaciente),
                                  ),
                                );
                              },
                            ),
                            CardItem(
                              emoji: '🩻',
                              title: 'Imagenología',
                              subtitle: 'Rayos X y estudios',
                              color: Color(0xFF0F172A), // Azul slate muy oscuro
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImagenPage(id_paciente: idPaciente),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap; // Nueva propiedad

  const CardItem({
    Key? key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap, // Acepta función opcional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Detecta el toque
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}