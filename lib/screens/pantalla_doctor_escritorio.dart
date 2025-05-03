import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';

class DoctorScreen extends StatefulWidget {
  final String nombre;
  const DoctorScreen({super.key, required this.nombre});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  String selectedOption = "Home";

  @override
  Widget build(BuildContext context) {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/ima2.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 220,  // Menú más grande
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),  // Fondo más blanco
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white54,
                          child: Icon(Icons.person, color: Colors.black, size: 30),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hola Dr. ${widget.nombre}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,  // Letra más grande
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              fechaHoy,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _menuItem("Home", Icons.home),
                    _menuItem("Ver Pacientes", Icons.person_search),
                    _menuItem("Ver Citas", Icons.calendar_today),
                    _menuItem("Mi Información", Icons.account_circle),
                    Spacer(),  // Espacio para mover "Cerrar Sesión" hacia abajo
                    _menuItem("Cerrar Sesión", Icons.exit_to_app),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(15),  // Sección más pequeña
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),  // Fondo más blanco
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String title, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10), // Espacio en el contenido
      leading: Container(
        width: 5,
        height: 40,
        color: selectedOption == title ? Colors.blue : Colors.transparent, // Barra azul a la izquierda
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selectedOption == title ? Colors.white : Colors.black,  // Texto blanco cuando se selecciona
          fontSize: 18,  // Letra un poco más grande en el menú
        ),
      ),
      tileColor: selectedOption == title ? Colors.blue : null,  // Barra azul en la opción seleccionada
      selected: selectedOption == title,
      onTap: () {
        setState(() {
          selectedOption = title;
        });
      },
    );
  }

  Widget _buildContent() {
    switch (selectedOption) {
      case "Ver Pacientes":
        return const Center(child: Text("Lista de Pacientes"));
      case "Ver Citas":
        return const Center(child: Text("Lista de Citas"));
      case "Mi Información":
        return const Center(child: Text("Información del Doctor"));
      case "Cerrar Sesión":
        return const Center(child: Text("Sesión Cerrada"));
      default:
        return const Center(child: Text("Inicio"));
    }
  }
}
