import 'package:flutter/material.dart';

class DoctorDesktopScreen extends StatefulWidget {
  const DoctorDesktopScreen({super.key});

  @override
  State<DoctorDesktopScreen> createState() => _DoctorDesktopScreenState();
}

class _DoctorDesktopScreenState extends State<DoctorDesktopScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'label': 'Inicio'},
    {'icon': Icons.calendar_today, 'label': 'Citas programadas'},
    {'icon': Icons.people, 'label': 'Pacientes'},
    {'icon': Icons.receipt_long, 'label': 'Órdenes médicas'},
    {'icon': Icons.settings, 'label': 'Ajustes'},
    {'icon': Icons.logout, 'label': 'Cerrar sesión'},
  ];

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
                    'MediSys LO',
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
                children: [
                  Container(
                    height: 120,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.phone_android, size: 48, color: Colors.blue.shade700),
                        const SizedBox(width: 20),
                        const Expanded(
                          child: Text(
                            'Descarga nuestra app\nDisponible en App Store y Play Store.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {},
                          child: const Text('Saber más'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                      ),
                      child: const Center(
                        child: Text(
                          'Gráfico de actividad de pacientes',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right panel
          Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                ),
                const SizedBox(height: 16),
                const Text('Dr. Philip Kennedy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('Cirujano - Hospital Sardjito'),
                const SizedBox(height: 24),
                const Divider(thickness: 1.2),
                const SizedBox(height: 12),
                metricItem('Citas', '2,543'),
                metricItem('Pacientes totales', '3,567'),
                const SizedBox(height: 16),
                const Text('Límite de Citas'),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: 136 / 200,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                ),
                const SizedBox(height: 20),
                metricItem('Consultas', '13,078'),
                metricItem('Pacientes Recurrentes', '2,736'),
                const SizedBox(height: 20),
                const Center(
                  child: Text('Total Pacientes Atendidos', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: 0.75,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                        ),
                      ),
                      const Text('15.8k'),
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

  Widget buildSidebarItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget metricItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
