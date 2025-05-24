import 'package:flutter/material.dart';

class PerfilPacienteScreen extends StatelessWidget {
  const PerfilPacienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> secciones = [
      {
        'titulo': 'Exámenes',
        'color': Colors.indigoAccent,
        'icono': Icons.science_outlined,
        'contenido': 'Resultados de laboratorio, imágenes, etc.',
      },
      {
        'titulo': 'Historia Clínica',
        'color': Colors.orangeAccent,
        'icono': Icons.history_edu,
        'contenido': 'Diagnósticos previos, tratamientos, alergias, etc.',
      },
      {
        'titulo': 'Medicamentos',
        'color': Colors.greenAccent,
        'icono': Icons.medication_outlined,
        'contenido': 'Prescripciones médicas actuales y pasadas.',
      },
      {
        'titulo': 'Notas del Doctor',
        'color': Colors.purpleAccent,
        'icono': Icons.note_alt_outlined,
        'contenido': 'Anotaciones de los doctores tratantes.',
      },
    ];

    return Scaffold(
      body: Row(
        children: [
          // Barra lateral azul con botón de retroceso
          Container(
            width: 250,
            color: Colors.blue.shade800,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/women/65.jpg',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Iveta Prokopciuk',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '+58 123 456 7890',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'iveta@email.com',
                  style: TextStyle(
                    color: Colors.white70,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings, color: Colors.white),
                )
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: secciones.map((seccion) {
                  return Container(
                    decoration: BoxDecoration(
                      color: seccion['color'],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(seccion['icono'], color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                seccion['titulo'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Icon(Icons.more_vert, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Text(
                            seccion['contenido'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            CircleAvatar(
                                radius: 10, backgroundColor: Colors.white),
                            SizedBox(width: 6),
                            CircleAvatar(
                                radius: 10, backgroundColor: Colors.white),
                            SizedBox(width: 6),
                            CircleAvatar(
                                radius: 10, backgroundColor: Colors.white),
                            Spacer(),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.add, size: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}