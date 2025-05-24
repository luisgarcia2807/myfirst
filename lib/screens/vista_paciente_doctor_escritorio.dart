import 'package:flutter/material.dart';
import 'package:mifirst/screens/bienvenido.dart';
import 'package:mifirst/screens/pantalla_doctor_escritorio.dart';
import 'package:mifirst/screens/vista_perfil_paciente_escritorio.dart';


class PacientesPorDoctorScreen extends StatefulWidget {
  const PacientesPorDoctorScreen({super.key});

  @override
  State<PacientesPorDoctorScreen> createState() =>
      _PacientesPorDoctorScreenState();
}

class _PacientesPorDoctorScreenState extends State<PacientesPorDoctorScreen> {
  int _selectedIndex = 2;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Inicio'},
    {'icon': Icons.calendar_today, 'label': 'Citas programadas'},
    {'icon': Icons.people, 'label': 'Pacientes'},
    {'icon': Icons.receipt_long, 'label': 'Órdenes médicas'},
    {'icon': Icons.settings, 'label': 'Ajustes'},
    {'icon': Icons.logout, 'label': 'Cerrar sesión'},
  ];

  final List<Map<String, String>> _pacientes = [
    {'nombre': 'Juan Pérez', 'cedula': '12345678'},
    {'nombre': 'María García', 'cedula': '87654321'},
    {'nombre': 'Luis Torres', 'cedula': '11223344'},
  ];

  String _busqueda = '';

  void _mostrarFormularioRegistro() {
    final TextEditingController cedulaController = TextEditingController();
    final TextEditingController comentarioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar nuevo paciente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cedulaController,
                decoration: const InputDecoration(
                  labelText: 'Cédula',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: comentarioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comentario / Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final cedula = cedulaController.text.trim();
                if (cedula.isEmpty || cedula.length < 8) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'La cédula es obligatoria y debe tener al menos 8 dígitos.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  _pacientes.add({
                    'nombre': 'Nuevo Paciente',
                    'cedula': cedula,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmarEliminacion(Map<String, String> paciente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar al paciente con cédula ${paciente['cedula']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _pacientes.removeWhere(
                        (p) => p['cedula'] == paciente['cedula']);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Paciente con cédula ${paciente['cedula']} eliminado correctamente.'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pacientesFiltrados = _pacientes.where((paciente) {
      final nombre = paciente['nombre']!.toLowerCase();
      final cedula = paciente['cedula']!;
      return nombre.contains(_busqueda.toLowerCase()) ||
          cedula.contains(_busqueda);
    }).toList();

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
                    'SISTEMA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
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
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pacientes Registrados',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: _mostrarFormularioRegistro,
                        icon:
                        const Icon(Icons.person_add, color: Colors.white),
                        label: const Text(
                          'Registrar nuevo paciente',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar paciente por nombre o cédula',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _busqueda = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pacientesFiltrados.length,
                      itemBuilder: (context, index) {
                        final paciente = pacientesFiltrados[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(paciente['nombre']!),
                            subtitle:
                            Text('Cédula: ${paciente['cedula']}'),
                            trailing: IconButton(
                              icon:
                              const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _confirmarEliminacion(paciente),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const PerfilPacienteScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Panel derecho
          Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INFORMACIÓN GENERAL',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total de pacientes registrados:',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '${_pacientes.length}',
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

        // Redirección
        if (label == 'Inicio') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DoctorDesktopScreen()),
          );
        } else if (label == 'Cerrar sesión') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
      },
      child: Container(
        color:
        isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}