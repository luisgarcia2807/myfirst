import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mifirst/constans.dart';
import 'package:mifirst/screens/fotoPerfil.dart';
import 'package:mifirst/screens/registrarCredencial.dart';
import 'package:mifirst/screens/vista_doctor_buscarPaciente.dart';
import '../theme/theme.dart';
import '../util/emoticon_face.dart';
import 'package:http/http.dart' as http;
class DoctorMobileScreen extends StatefulWidget {
  final int idusuario;
  const DoctorMobileScreen({super.key, required this.idusuario});

  @override
  State<DoctorMobileScreen> createState() => _DoctorMobileScreenState();
}

class _DoctorMobileScreenState extends State<DoctorMobileScreen> {
  String selectedOption = "Home";
  String nombreUsuario = '';
  String apellidoUsuario = '';
  String cedulaUsuario = '';
  String emailUsuario = '';
  String telefonoUsuario = '';
  String fechaNacimientoUsuario = '';
  bool estadoUsuario = false;
  int idRolUsuario = 0;
  String? foto='';

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
  int _selectedIndex = 0;
  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return; // No hacer nada si ya está seleccionado

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => buscarPaciente(idusuario: widget.idusuario),
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
    obtenerDatos(); // Llamamos al método para obtener los datos
  }

  @override
  Widget build(BuildContext context) {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor:Colors.white,
            indicatorColor: Colors.blue.shade900,
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
              icon: Icon(Icons.person_pin),
              selectedIcon: Icon(Icons.person_pin),
              label: 'Paciente',
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
                              "Hola Dr.$nombreUsuario $apellidoUsuario",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis, // <-- por si aún se desborda
                            ),
                            SizedBox(height: 1.0),
                            Text(
                              fechaHoy,
                              style: TextStyle(color: Colors.grey[300]),
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
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.white70),
                        SizedBox(width: 5),
                        Text(
                          'Explorar',
                          style: TextStyle(color: Colors.white70),
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
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.more_horiz, color: Colors.white),
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
                          Text('Excelente', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Column(
                        children: [
                          EmoticonFace(emoticonface: '🙂', color: Colors.limeAccent),
                          SizedBox(height: 8),
                          Text('Bien', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Column(
                        children: [
                          EmoticonFace(emoticonface: '😐', color: Colors.orangeAccent),
                          SizedBox(height: 8),
                          Text('Regular', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Column(
                        children: [
                          EmoticonFace(emoticonface: '😢', color: Colors.red),
                          SizedBox(height: 8),
                          Text('Mal', style: TextStyle(color: Colors.white)),
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
                      'Información reciente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
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
                            color: Colors.white38,
                          ),
                          CardItem(
                            emoji: '🔬',
                            title: 'Exámenes',
                            subtitle: 'Últimos resultados',
                            color: Colors.white38,
                          ),
                          CardItem(
                            emoji: '📑',
                            title: 'Póliza de Seguro',
                            subtitle: 'Detalles de cobertura',
                            color: Colors.white38,
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

  const CardItem({
    Key? key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 42, color: Colors.indigo),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.indigo),
          ),
        ],
      ),
    );
  }
}
