import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/screens/registrarCredencial.dart';
import 'package:mifirst/screens/vista_alergia.dart';
import 'package:mifirst/screens/vista_enfermedadespersistente.dart';
import 'package:mifirst/screens/vista_vacuna.dart';
import '../util/emoticon_face.dart';
import '../constans.dart';
import 'informacion_Principal.dart';

class PacienteScreen extends StatefulWidget {
  final int idusuario;
  const PacienteScreen({super.key, required this.idusuario});

  @override
  State<PacienteScreen> createState() => _PacienteScreen();
}

class _PacienteScreen extends State<PacienteScreen> {
  final TextEditingController _credencialController = TextEditingController();

  String nombreUsuario = '';
  String apellidoUsuario = '';
  String cedulaUsuario = '';
  String emailUsuario = '';
  String telefonoUsuario = '';
  String fechaNacimientoUsuario = '';
  bool estadoUsuario = false;
  int idRolUsuario = 0;

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

  @override
  void initState() {
    super.initState();
    obtenerDatos(); // Llamamos al método para obtener los datos
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
          selectedIndex: 0, // cambia esto si necesitas manejar el estado
          onDestinationSelected: (int index) {
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegistrarCredencialScreen()),
              );
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.qr_code_outlined),
              selectedIcon: Icon(Icons.qr_code),
              label: 'QR',
            ),
            NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              selectedIcon: Icon(Icons.medical_services),
              label: 'Doctor',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
          ],
        ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(1000),
                            ),
                            padding: EdgeInsets.all(15),
                            child: Icon(
                              Icons.person_pin,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4.0),
                              Text(
                                "Hola $nombreUsuario $apellidoUsuario", // Aquí mostramos el nombre completo
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.0),
                              Text(
                                fechaHoy,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
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
                            color: Colors.blueAccent.shade700,
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
                            emoji: '💊', // Emoji más expresivo para alergias
                            title: 'Alergias',
                            subtitle: 'Ver todas',
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VistaAlergia(idusuario: widget.idusuario),
                                ),
                              );
                            },
                          ),
                          CardItem(
                            emoji: '💉', // Emoji representativo para vacunas
                            title: 'Vacunas',
                            subtitle: 'Ver todas',
                            color: Colors.green.shade700,
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
                            emoji: '🏥', // Representa enfermedades o chequeo médico
                            title: 'Enfermedades Persistentes',
                            subtitle: 'Revisar historial',
                            color: Colors.blueGrey,
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
                            emoji: '🔬',
                            title: 'Exámenes',
                            subtitle: 'Últimos resultados',
                            color: Colors.blueAccent.shade700,
                          ),
                          CardItem(
                            emoji: '📑',
                            title: 'Póliza de Seguro',
                            subtitle: 'Detalles de cobertura',
                            color: Colors.blueAccent.shade700,
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

