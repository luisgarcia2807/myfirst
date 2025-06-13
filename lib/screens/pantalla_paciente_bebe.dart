import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/screens/fotoPerfil.dart';
import 'package:mifirst/screens/vista_alergia.dart';
import 'package:mifirst/screens/vista_enfermedadespersistente.dart';
import 'package:mifirst/screens/vista_examenlaboratorio.dart';
import 'package:mifirst/screens/vista_imagenologia.dart';
import 'package:mifirst/screens/vista_paciente_pacientedoctor.dart';
import 'package:mifirst/screens/vista_tramientofrecuente.dart';
import 'package:mifirst/screens/vista_tratamiento_actual.dart';
import 'package:mifirst/screens/vista_vacuna.dart';
import '../util/emoticon_face.dart';
import '../constans.dart';
import 'informacion_Principal.dart';

class PacientebbScreen extends StatefulWidget {
  final int idusuario;
  const PacientebbScreen({super.key, required this.idusuario});

  @override
  State<PacientebbScreen> createState() => _PacientebbScreen();
}

class _PacientebbScreen extends State<PacientebbScreen> {

  String nombreUsuario = '';
  String apellidoUsuario = '';
  String cedulaUsuario = '';
  String emailUsuario = '';
  String telefonoUsuario = '';
  String fechaNacimientoUsuario = '';
  bool estadoUsuario = false;
  int idRolUsuario = 0;
  String? foto='';
  String sexo = '';
  bool isLoading = true;
  int idPaciente = 0;
  int idSangre = 0;
  String tipoSangre = '';

  // Método para obtener los datos de la API
  Future<void> obtenerDatos() async {
    // La URL de tu API (reemplázala por la URL correcta)
    final url = Uri.parse('$baseUrl/usuarios/api/bebes/${widget.idusuario}/'); // Asegúrate de cambiar esto

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
  Future<void> obtenerDatosPacienteSangre(int idUsuario) async {
    final url = Uri.parse('$baseUrl/usuarios/api/paciente/perfilbebe/$idUsuario/');

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
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
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

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
                icon: Icon(Icons.verified_user_outlined), // Nuevo ícono
                selectedIcon: Icon(Icons.verified_user), // Ícono cuando está seleccionado
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
                          padding: EdgeInsets.all(6),
                          child: foto == null || foto!.isEmpty
                              ? Icon(
                            Icons.child_care,
                            color: Colors.white,
                            size: 60,
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
                              "Hijo $nombreUsuario $apellidoUsuario",
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
                            emoji: '🩺',
                            title: 'Información Médica',
                            subtitle: 'Datos clave',
                            color: Colors.indigo.shade700,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InformacionPrincipalPaciente(idusuario: widget.idusuario),
                                ),
                              );
                            },
                          ),
                          CardItem(
                            emoji: '⚠️', // Más claro para indicar alergias/alertas
                            title: 'Alergias',
                            subtitle: 'Reacciones conocidas',
                            color: Colors.red.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VistaAlergia(id_paciente: idPaciente,),
                                ),
                              );
                            },
                          ),
                          CardItem(
                            emoji: '💉',
                            title: 'Vacunas',
                            subtitle: 'Historial de inmunización',
                            color: Colors.blue.shade700,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VistaVacuna(idusuario: widget.idusuario),
                                ),
                              );
                            },
                          ),
                          CardItem(
                            emoji: '💊',
                            title: 'Tratamiento Actual',
                            subtitle: 'Medicamentos en curso',
                            color: Colors.lightBlue.shade700,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VistaTratamientoActualmente(idusuario: widget.idusuario),
                                ),
                              );
                            },
                          ),
                          CardItem(
                            emoji: '🫁', // Más específico para enfermedades persistentes
                            title: 'Enfermedades Persistentes',
                            subtitle: 'Condiciones crónicas',
                            color: Colors.deepPurple.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VistaEnfermedadPersistente(idusuario: widget.idusuario),
                                ),
                              );
                            },
                          ),
                          CardItem(
                            emoji: '🧴', // Frasco de medicamentos
                            title: 'Tratamientos frecuentes',
                            subtitle: 'Medicinas habituales',
                            color: Colors.cyan.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VistaTratamientofrecuente(idusuario: widget.idusuario),
                                ),
                              );
                            },
                          ),
                          CardItem(
                            emoji: '🔬', // Laboratorio clínico
                            title: 'Exámenes',
                            subtitle: 'Resultados de laboratorio',
                            color: Colors.teal.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExamenesPage(idusuario: widget.idusuario),
                                ),
                              );
                            },
                          ),
                          CardItem(
                            emoji: '🩻', // Rayos X y estudios
                            title: 'Imagenología',
                            subtitle: 'Rayos X y estudios',
                            color: Colors.blueGrey.shade600,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImagenPage(idusuario: widget.idusuario),
                                ),
                              );
                            },
                          ),
                          CardItem(
                            emoji: '🏥', // Hospital/sistema de salud
                            title: 'Póliza de Seguro',
                            subtitle: 'Información de cobertura',
                            color: Colors.indigo.shade500,
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

