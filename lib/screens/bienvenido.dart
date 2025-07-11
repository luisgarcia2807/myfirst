import 'package:flutter/material.dart';
import 'package:mifirst/screens/iniciar_sesion.dart';
import 'package:mifirst/screens/pantalla_doctor_mobile.dart';
import 'package:mifirst/screens/registrar_doctor.dart';
import 'package:mifirst/screens/registrarse.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con degradado multicolor, ahora cubre todo el espacio
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D47A1), // Azul oscuro
                  Color(0xFF1976D2), // Azul medio
                  Color(0xFF42A5F5), // Azul claro
                  Color(0xFF7E57C2), // Morado
                  Color(0xFF26C6DA), // Turquesa
                ],
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 120),
              Container(
                width: 400,
                height: 80,
                child: Image.asset(
                  'assets/images/fotologo.png', // Cambia esto por la ruta de tu imagen
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 1),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '\nBienvenido a tu respaldo de datos',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 8,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              // Cuadro blanco reducido abajo
              const SizedBox(height: 80),
              ClipPath(
                clipper: WavyTopClipper(),
                child: Container(
                  width: double.infinity,
                  height: 478.3,
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 120),
                      _buildButton(
                        text: 'Registrarse como Paciente',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                        },
                        color: Colors.blue.shade900,
                      ),
                      const SizedBox(height: 25),
                      _buildButton(
                        text: 'Registrarse como Doctor',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreendoctor(),
                            ),
                          );
                        },
                        color: Colors.blue.shade400,
                      ),
                      const SizedBox(height: 25),
                      _buildButton(
                        text: 'Iniciar Sesión',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SingInScreen(),
                            ),
                          );
                        },
                        color: Colors.lightBlue.shade800,
                      ),
                      const Spacer(),
                      Text(
                        '¿Necesitas ayuda? Contáctanos aquí.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Botón reutilizable
  Widget _buildButton({
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// Clipper para curva superior
class WavyTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 50);
    path.quadraticBezierTo(size.width / 4, 10, size.width / 2, 40);
    path.quadraticBezierTo(size.width * 3 / 4, 80, size.width, 50);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
