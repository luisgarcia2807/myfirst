import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';

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
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Container(
              color: const Color.fromARGB(255, 55, 112, 191),  // Fondo para el menú
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // Nombre y ícono de usuario
                  Row(
                    children: [
                      // Ícono de usuario en lugar de foto
                      CircleAvatar(
                        radius: 40,  // Ícono más grande
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person, // Ícono de usuario
                          size: 35,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dr. ${widget.nombre}",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            fechaHoy,
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            _menuItem("Home", Icons.home),
            _menuItem("Ver Pacientes", Icons.person_search),
            _menuItem("Ver Citas", Icons.calendar_today),
            _menuItem("Mi Información", Icons.account_circle),
            const Divider(),
            _menuItem("Cerrar Sesión", Icons.exit_to_app),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/ima2.jpg',  // Ruta de la imagen
              fit: BoxFit.cover,
            ),
          ),
          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 15),
                // Botón de menú y título alineados a la izquierda
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Botón de menú
                    Builder(
                      builder: (context) {
                        return IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();  // Abre el menú al presionar el ícono
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    // Título de la acción seleccionada
                    Text(
                      _getAppBarTitle(),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 90),
                    // Botón de reporte
                    IconButton(
                      icon: const Icon(Icons.support_agent, color: Colors.white,size: 30,),
                      onPressed: () {
                        // Lógica para el reporte
                        print("Acción de Reporte");
                      },
                    ),
                    const SizedBox(width: 10),
                    // Botón de notificaciones
                    IconButton(
                      icon: const Icon(Icons.notifications_active, color: Colors.white, size: 30,),
                      onPressed: () {
                        // Lógica para las notificaciones
                        print("Acción de Notificaciones");
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20), // Espacio entre el título y el cuadro de contenido
                // Cuadro de contenido más grande que ocupa la parte inferior de la pantalla
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,  // Hace que el cuadro ocupe todo el ancho disponible
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Botón flotante para abrir el Drawer
      floatingActionButton: SizedBox(), // Eliminamos el botón flotante
    );
  }

  Widget _menuItem(String title, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10), // Espacio en el contenido
      leading: Icon(
        icon,
        color: selectedOption == title ? Color.fromARGB(255, 130, 20, 20) : Colors.black,  // Aseguramos que el ícono sea visible
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selectedOption == title ? const Color.fromARGB(255, 130, 20, 20) : Colors.black,  // Texto blanco cuando se selecciona
          fontSize: 18,
        ),
      ),
      tileColor: selectedOption == title ? Colors.blue : null,  // Barra azul en la opción seleccionada
      selected: selectedOption == title,
      onTap: () {
        setState(() {
          selectedOption = title;
          Navigator.of(context).pop();  // Cierra el menú al seleccionar una opción
        });
      },
    );
  }

  // Función para obtener el título dinámico según la opción seleccionada
  String _getAppBarTitle() {
    switch (selectedOption) {
      case "Ver Pacientes":
        return "Ver Pacientes";
      case "Ver Citas":
        return "Ver Citas";
      case "Mi Información":
        return "Mi Información";
      default:
        return "Inicio";
    }
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
