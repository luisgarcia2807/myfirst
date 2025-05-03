import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CentroMedicoScreen extends StatefulWidget {
  final String nombreCentro;
  const CentroMedicoScreen({super.key, required this.nombreCentro});

  @override
  State<CentroMedicoScreen> createState() => _CentroMedicoScreenState();
}

class _CentroMedicoScreenState extends State<CentroMedicoScreen> {
  String selectedOption = "Inicio";

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
                width: 220,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
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
                          child: Icon(Icons.local_hospital, color: Colors.black, size: 30),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Clinica: ${widget.nombreCentro}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
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
                    _menuItem("Inicio", Icons.home),
                    _menuItem("Ver Paciente", Icons.people),
                    _menuItem("Validar Doctores", Icons.verified_user),
                    _menuItem("Perfil del Centro", Icons.local_hospital),
                    const Spacer(),
                    _menuItem("Cerrar Sesión", Icons.exit_to_app),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: Container(
        width: 5,
        height: 40,
        color: selectedOption == title ? Colors.blue : Colors.transparent,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selectedOption == title ? Colors.indigo : Colors.black,
          fontSize: 18,
        ),
      ),
      tileColor: selectedOption == title ? Colors.blue : null,
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
      case "Ver Usuarios":
        return const Center(child: Text("Listado de usuarios que visitan el centro médico"));
      case "Validar Doctores":
        return const Center(child: Text("Sección para validar doctores del centro"));
      case "Perfil del Centro":
        return const Center(child: Text("Información del centro médico"));
      case "Cerrar Sesión":
        return const Center(child: Text("Sesión cerrada"));
      default:
        return const Center(child: Text("Bienvenido al panel del centro médico"));
    }
  }
}
