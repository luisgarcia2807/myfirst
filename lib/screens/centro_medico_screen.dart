import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctores_centro.dart';

class CentroMedicoDesktopScreen extends StatefulWidget {
  const CentroMedicoDesktopScreen({super.key});

  @override
  State<CentroMedicoDesktopScreen> createState() => _CentroMedicoDesktopScreenState();
}

class _CentroMedicoDesktopScreenState extends State<CentroMedicoDesktopScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.verified_user, 'label': 'Verificar doctor'},
    {'icon': Icons.people, 'label': 'Ver paciente'},
    {'icon': Icons.logout, 'label': 'Cerrar sesión'},
  ];

  // Lista de doctores para mostrar
  List<Doctor> doctores = [];

  @override
  void initState() {
    super.initState();
    fetchDoctores();  // Llamar a la API para cargar los doctores
  }

  Future<void> fetchDoctores() async {
    final url = Uri.parse('http://127.0.0.1:8000/usuarios/api/centro-medico/1/doctores/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(utf8DecodedBody);
      setState(() {
        doctores = data.map((json) => Doctor.fromJson(json)).toList();
      });
    } else {
      throw Exception('Error al cargar doctores');
    }
  }

  Future<void> activarDoctor(int idDoctor) async {
    final url = Uri.parse('http://127.0.0.1:8000/usuarios/api/centro-medico/1/activar-doctor/$idDoctor/');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, actualiza el estado
      print("Doctor aprobado con éxito.");
      setState(() {
        // Actualizar el doctor a 'activo' o realizar cualquier otro cambio necesario
        doctores.firstWhere((doctor) => doctor.idDoctor == idDoctor).activo = true;
      });
    } else {
      // Si la solicitud falla, lanza un error
      throw Exception('Error al aprobar doctor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: const Color(0xFF0D47A1),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Centro Médico',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                for (int i = 0; i < _menuItems.length; i++)
                  buildSidebarItem(
                    icon: _menuItems[i]['icon'],
                    label: _menuItems[i]['label'],
                    index: i,
                  ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _selectedIndex == 0
                  ? ListView.builder(
                itemCount: doctores.length,
                itemBuilder: (context, index) {
                  final doctor = doctores[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('${doctor.nombre} ${doctor.apellido}'),
                      subtitle: Text(doctor.cedula),
                      trailing: doctor.activo
                          ? Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                        onPressed: () => activarDoctor(doctor.idDoctor),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Botón rojo
                        ),
                        child: const Text('Aprobar'),
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  _menuItems[_selectedIndex]['label'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSidebarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Transform.translate(
        offset: isSelected ? const Offset(10, 0) : Offset.zero, // se desplaza hacia afuera
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: isSelected
                ? const BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            )
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF0D47A1) : Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF0D47A1) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
