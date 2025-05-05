import 'package:flutter/material.dart';
import 'package:mifirst/screens/registrarCredencial.dart';
import 'package:mifirst/util/Informacion_principal.dart';
import 'package:mifirst/util/emoticon_face.dart';
import '../theme/theme.dart';
import 'package:intl/intl.dart';

class InformacionPrincipalPaciente extends StatefulWidget {
  final String nombre;
  const InformacionPrincipalPaciente({super.key, required this.nombre});

  @override
  State<InformacionPrincipalPaciente> createState() => _InformacionPrincipalPaciente();
}

class _InformacionPrincipalPaciente extends State<InformacionPrincipalPaciente> {
  final TextEditingController _credencialController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
        body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D47A1), // Azul oscuro
          Color(0xFF1976D2), // Azul medio
          Color(0xFF42A5F5), // Azul claro
          Color(0xFF7E57C2), // Morado
          Color(0xFF26C6DA), // azul más claro
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
                            "${widget.nombre}",
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
                                  Text("Juan Pérez"),
                                  Text("Ci: V-12345678"),
                                  Text("28 años"),
                                  Text("0414-1234567"),
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
                                  Text("O+"),
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
            )



          ],
        ),
      ),
    ));
  }

}

