import 'package:flutter/material.dart';

class DoctorDesktopScreen extends StatelessWidget {
  const DoctorDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: const Color(0xFF0D47A1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Text('MediSys LO', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 30),
                buildSidebarItem(Icons.dashboard, 'Inicio'),
                buildSidebarItem(Icons.calendar_today, 'Citas programadas'),
                buildSidebarItem(Icons.people, 'Pacientes'),
                buildSidebarItem(Icons.payment, 'Ordenes medicas'),
                buildSidebarItem(Icons.settings, 'Ajustes'),
                buildSidebarItem(Icons.logout, 'Cerrar sesion'),
              ],
            ),
          ),

          // Main content
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Banner
                  Container(
                    height: 120,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.phone_android, size: 48, color: Colors.blue),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Get Our App\nDownload our app from your appstore or playstore.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text('Learn more'),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Patient activity chart (placeholder)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      child: Center(child: Text('Patient Activity Chart Here')),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right panel
          Container(
            width: 300,
            padding: EdgeInsets.all(24),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                ),
                SizedBox(height: 16),//informacion doctor
                Text('Dr. Philip Kennedy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Surgery Doctor - Sardjito Hospital'),
                SizedBox(height: 16),
                Divider(),
                metricItem('Appointments', '2,543'),
                metricItem('Total Patients', '3,567'),
                SizedBox(height: 16),
                Text('Appointments Limit'),
                LinearProgressIndicator(value: 136 / 200),
                SizedBox(height: 16),
                metricItem('Consultations', '13,078'),
                metricItem('Return Patients', '2,736'),
                SizedBox(height: 16),
                Center(child: Text('15,814 Patients')),
                SizedBox(height: 8),
                Center(
                  child: CircularProgressIndicator(
                    value: 0.75,
                    strokeWidth: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSidebarItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: TextStyle(color: Colors.white)),
      onTap: () {},
    );
  }

  Widget metricItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}