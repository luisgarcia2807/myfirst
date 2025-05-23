import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mifirst/screens/registrarCredencial.dart';
import '../theme/theme.dart';
import '../util/emoticon_face.dart';

class DoctorMobileScreen extends StatefulWidget {
  final String nombre;
  const DoctorMobileScreen({super.key, required this.nombre});

  @override
  State<DoctorMobileScreen> createState() => _DoctorMobileScreenState();
}

class _DoctorMobileScreenState extends State<DoctorMobileScreen> {
  String selectedOption = "Home";

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
              icon: Icon(Icons.person_pin),
              selectedIcon: Icon(Icons.person_pin),
              label: 'Paciente',
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hola ${widget.nombre}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            fechaHoy,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
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
                      )
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
