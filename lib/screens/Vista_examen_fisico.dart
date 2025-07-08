import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constans.dart';

class CuerpoInteractivoPage extends StatefulWidget {
  final int idConsulta;
  final String nombre;
  final String apellido;

  const CuerpoInteractivoPage({super.key, required this.idConsulta,required this.nombre, required this.apellido});

  @override
  _CuerpoInteractivoPageState createState() => _CuerpoInteractivoPageState();
}

class _CuerpoInteractivoPageState extends State<CuerpoInteractivoPage> {
  final Map<String, TextEditingController> _resumenController = {
    'general': TextEditingController(),
    'piel': TextEditingController(),
    'cabeza': TextEditingController(),
    'oidos': TextEditingController(),
    'nariz': TextEditingController(),
    'boca': TextEditingController(),
    'respiratorio': TextEditingController(),
    'osteomuscular': TextEditingController(),
    'cardiovascular': TextEditingController(),
    'gastrointestinal': TextEditingController(),
    'genitourinario': TextEditingController(),
    'nervioso': TextEditingController(),
  };
  final Map<String, String> textosPorDefecto = {
    'general': 'Dieta balanceada a base de carbohidratos, lípidos y proteínas. Niega aumento o pérdida de peso y otra sintomatología de importancia.',
    'piel': 'Niega coloración amarillenta o azulada de la piel, prurito. Niega otra sintomatología de importancia.',
    'cabeza': 'Niega sintomatología de importancia.',
    'oidos': 'Niega sintomatología de importancia.',
    'nariz': 'Niega sintomatología de importancia.',
    'boca': 'Niega sintomatología de importancia.',
    'respiratorio': 'Niega sintomatología de importancia.',
    'osteomuscular': 'Niega sintomatología de importancia.',
    'cardiovascular': 'Niega sintomatología de importancia.',
    'gastrointestinal': 'Hábito evacuatorio una vez al día, consistencia sólida, forma cilíndrica, color y olor sui generis, sin moco, sin sangre.',
    'genitourinario': 'Hábito miccional 3:0 color rojizo y olor sui generis. Niega sintomatología de importancia.',
    'nervioso': 'Paciente poco colaborador, despreocupado.',
  };
  Future<void> guardarExamenFuncional() async {
    final url = Uri.parse('$baseUrl/usuarios/api/examenfuncional/');
    Map<String, String> examenData = {};

    _resumenController.forEach((parte, controlador) {
      examenData[parte] = controlador.text.trim().isEmpty
          ? textosPorDefecto[parte]!
          : controlador.text.trim();
    });

    final data = {
      'consulta': widget.idConsulta,
      ...examenData,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Examen funcional guardado con éxito')),
        );

        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context, true);
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  final Map<String, bool> _zonasTocadas = {};

  void mostrarResumen(String parte) {
    setState(() {
      _zonasTocadas[parte] = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: EdgeInsets.zero, // Evita espacio extra
        content: SingleChildScrollView( // Evita desbordamiento con el teclado
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título con ícono
                Row(
                  children: [
                    Icon(
                      _getIconoParte(parte),
                      color: _getColorParte(parte),
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _getNombreParte(parte),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getColorParte(parte),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Área de texto
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: TextField(
                    controller: _resumenController[parte],
                    maxLines: 8,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(15),
                      hintText:
                      'Describe los hallazgos del ${_getNombreParte(parte).toLowerCase()}...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Edita o complementa la información del examen',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 20),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getColorParte(parte),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Guardar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNombreParte(String parte) {
    final nombres = {
      'general': 'Estado General',
      'piel': 'Piel y Anexos',
      'cabeza': 'Cabeza',
      'oidos': 'Oídos',
      'nariz': 'Nariz',
      'boca': 'Boca y Garganta',
      'respiratorio': 'Sistema Respiratorio',
      'osteomuscular': 'Sistema Osteomuscular',
      'cardiovascular': 'Sistema Cardiovascular',
      'gastrointestinal': 'Sistema Gastrointestinal',
      'genitourinario': 'Sistema Genitourinario',
      'nervioso': 'Sistema Nervioso y Mental',
    };
    return nombres[parte] ?? parte;
  }

  IconData _getIconoParte(String parte) {
    final iconos = {
      'general': Icons.person_outline,
      'piel': Icons.fingerprint,
      'cabeza': Icons.face_outlined,
      'oidos': Icons.hearing_outlined,
      'nariz': Icons.air,
      'boca': Icons.record_voice_over_outlined,
      'respiratorio': Icons.air,
      'osteomuscular': Icons.fitness_center_outlined,
      'cardiovascular': Icons.favorite_outline,
      'gastrointestinal': Icons.restaurant_outlined,
      'genitourinario': Icons.water_drop_outlined,
      'nervioso': Icons.psychology_outlined,
    };
    return iconos[parte] ?? Icons.medical_services;
  }

  Color _getColorParte(String parte) {
    final colores = {
      'general': Color(0xFF3F51B5),
      'piel': Color(0xFF8D6E63),
      'cabeza': Color(0xFF9C27B0),
      'oidos': Color(0xFFFF9800),
      'nariz': Color(0xFF4CAF50),
      'boca': Color(0xFFE91E63),
      'respiratorio': Color(0xFF03A9F4),
      'osteomuscular': Color(0xFF009688),
      'cardiovascular': Color(0xFFF44336),
      'gastrointestinal': Color(0xFFFF5722),
      'genitourinario': Color(0xFF00BCD4),
      'nervioso': Color(0xFF673AB7),
    };
    return colores[parte] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Examen Funcional por Sistemas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF3F51B5),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Título informativo
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3F51B5).withOpacity(0.1), Color(0xFF3F51B5).withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF3F51B5).withOpacity(0.2)),
                ),
                child: Text(
                  'Toca cada zona del cuerpo para registrar los hallazgos del examen funcional',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3F51B5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Cuerpo humano con zonas interactivas mejoradas
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(30),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Cuerpo humano más realista
                    Center(
                      child: Container(
                        width: 260,
                        height: 540,
                        child: CustomPaint(
                          painter: RealisticBodyPainter(),
                        ),
                      ),
                    ),

                    // Zonas interactivas con mejor posicionamiento
                    // Estado General
                    // GENERAL

// CABEZA
                    Positioned(
                      top: -20,
                      left: 120,
                      child: zonaInteractiva('cabeza',  Icons.face_outlined, Color(0xFF9C27B0)),
                    ),

// OÍDOS
                    Positioned(
                      top: 30,
                      left: 65,
                      child: zonaInteractiva('oidos',  Icons.hearing_outlined, Color(0xFFFF9800)),
                    ),

// NARIZ
                    Positioned(
                      top: 25,
                      left: 120,
                      child: zonaInteractiva('nariz',Icons.air_outlined, Color(0xFF4CAF50)), // Si no tienes, usa Icons.sick
                    ),

// BOCA Y GARGANTA
                    Positioned(
                      top: 70,
                      left: 120,
                      child: zonaInteractiva('boca', Icons.mic_external_on_outlined, Color(0xFFE91E63)),
                    ),

// SISTEMA NERVIOSO
                    Positioned(
                      top: -5,
                      left: 165,
                      child: zonaInteractiva('nervioso', Icons.psychology_outlined, Color(0xFF673AB7)),
                    ),

// RESPIRATORIO
                    Positioned(
                      top: 170,
                      left: 100,
                      child: zonaInteractiva('respiratorio', Icons.wind_power_outlined, Color(0xFF03A9F4)),
                    ),

// CARDIOVASCULAR
                    Positioned(
                      top: 120,
                      left: 140,
                      child: zonaInteractiva('cardiovascular', Icons.favorite, Color(0xFFF44336)),
                    ),

// PIEL
                    Positioned(
                      top: 230,
                      left: 200,
                      child: zonaInteractiva('piel', Icons.texture_outlined, Color(0xFF8D6E63)),
                    ),

// OSTEOMUSCULAR - BRAZO
                    Positioned(
                      top: 220,
                      left: 45,
                      child: zonaInteractiva('osteomuscular', Icons.sports_mma, Color(0xFF009688)),
                    ),

// GASTROINTESTINAL
                    Positioned(
                      top: 225,
                      left: 123,
                      child: zonaInteractiva('gastrointestinal', Icons.lunch_dining, Color(0xFFFF5722)),
                    ),

// GENITOURINARIO
                    Positioned(
                      top: 270,
                      left: 120,
                      child: zonaInteractiva('genitourinario', Icons.water_drop_outlined, Color(0xFF00BCD4)),
                    ),

// OSTEOMUSCULAR - PIERNA IZQUIERDA
                    Positioned(
                      top: 380,
                      left: 85,
                      child: zonaInteractiva('osteomuscular', Icons.directions_run, Color(0xFF00695C)),
                    ),

// OSTEOMUSCULAR - PIERNA DERECHA
                    Positioned(
                      top: 380,
                      left: 145,
                      child: zonaInteractiva('osteomuscular', Icons.directions_walk, Color(0xFF00695C)),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Text(
                        '${widget.nombre} ${widget.apellido}',// aquí la variable con el nombre del paciente
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                          backgroundColor: Colors.white70, // fondo semitransparente para mejor lectura
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Resumen de zonas evaluadas con mejor diseño
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.medical_information_outlined,
                          color: Color(0xFF3F51B5),
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Progreso del Examen ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F51B5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _resumenController.keys.map((zona) {
                        bool evaluada = _zonasTocadas[zona] ?? false;
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: evaluada
                                ? LinearGradient(
                              colors: [_getColorParte(zona).withOpacity(0.15), _getColorParte(zona).withOpacity(0.05)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : null,
                            color: evaluada ? null : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: evaluada ? _getColorParte(zona) : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                evaluada ? Icons.check_circle : Icons.radio_button_unchecked,
                                size: 16,
                                color: evaluada ? _getColorParte(zona) : Colors.grey,
                              ),
                              SizedBox(width: 6),
                              Text(
                                _getNombreParte(zona),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: evaluada ? _getColorParte(zona) : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 15),
                    LinearProgressIndicator(
                      value: _zonasTocadas.length / _resumenController.length,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F51B5)),
                      minHeight: 6,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${_zonasTocadas.length} de ${_resumenController.length} sistemas evaluados',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight, // Lo pega a la derecha
                      child: ElevatedButton(
                        onPressed: () {
                          guardarExamenFuncional();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[800], // Azul oscuro/índigo
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Puedes cambiar a 0 si lo quieres más cuadrado aún
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Tamaño
                        ),
                        child: Text(
                          'Guardar Examen Funcional',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )



                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget zonaInteractiva(String parte, IconData icono, Color color) {
    bool evaluada = _zonasTocadas[parte] ?? false;

    return GestureDetector(
      onTap: () => mostrarResumen(parte),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(evaluada ? 1.1 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: evaluada
                  ? [color, color.withOpacity(0.8)]
                  : [color.withOpacity(0.9), color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(evaluada ? 0.4 : 0.25),
                blurRadius: evaluada ? 12 : 8,
                offset: Offset(0, evaluada ? 4 : 2),
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 2.5,
            ),
          ),
          width: 40,
          height: 40,
          child: Stack(
            children: [
              Center(
                child: Icon(
                  icono,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (evaluada)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _resumenController.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}

// Painter mejorado para un cuerpo más realista
class RealisticBodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(0xFFF4D2A7),
          Color(0xFFE8C5A0),
          Color(0xFFDEB887),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Color(0xFFD4A574)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final shadowPaint = Paint()
      ..color = Color(0xFFD4A574).withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);

    double centerX = size.width / 2;

    // Crear path más realista para el cuerpo
    Path bodyPath = Path();

    // === CABEZA MÁS REALISTA ===
    RRect head = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, 50),
        width: 70,
        height: 85,
      ),
      Radius.circular(35),
    );
    bodyPath.addRRect(head);

    // === CUELLO PROPORCIONADO ===
    RRect neck = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, 95),
        width: 32,
        height: 25,
      ),
      Radius.circular(16),
    );
    bodyPath.addRRect(neck);

    // === TORSO MÁS ANATÓMICO ===
    Path torsoPath = Path();
    // Hombros más anchos
    torsoPath.moveTo(centerX - 60, 115);
    // Curva del hombro izquierdo
    torsoPath.quadraticBezierTo(centerX - 70, 125, centerX - 65, 140);
    // Lateral izquierdo del torso
    torsoPath.quadraticBezierTo(centerX - 55, 170, centerX - 50, 200);
    // Cintura
    torsoPath.quadraticBezierTo(centerX - 45, 220, centerX - 45, 240);
    // Cadera izquierda
    torsoPath.quadraticBezierTo(centerX - 50, 270, centerX - 45, 300);
    // Base de la pelvis
    torsoPath.lineTo(centerX + 45, 300);
    // Cadera derecha
    torsoPath.quadraticBezierTo(centerX + 50, 270, centerX + 45, 240);
    // Cintura derecha
    torsoPath.quadraticBezierTo(centerX + 45, 220, centerX + 50, 200);
    // Lateral derecho
    torsoPath.quadraticBezierTo(centerX + 55, 170, centerX + 65, 140);
    // Hombro derecho
    torsoPath.quadraticBezierTo(centerX + 70, 125, centerX + 60, 115);
    torsoPath.close();

    bodyPath.addPath(torsoPath, Offset.zero);

    // === BRAZOS MÁS PROPORCIONADOS ===
    // Brazo izquierdo - parte superior
    RRect leftUpperArm = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX - 80, 150), width: 30, height: 65),
      Radius.circular(15),
    );
    bodyPath.addRRect(leftUpperArm);

    // Brazo izquierdo - antebrazo
    RRect leftForearm = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX - 75, 220), width: 26, height: 60),
      Radius.circular(13),
    );
    bodyPath.addRRect(leftForearm);

    // Mano izquierda
    RRect leftHand = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX - 75, 265), width: 24, height: 32),
      Radius.circular(12),
    );
    bodyPath.addRRect(leftHand);

    // Brazo derecho - parte superior
    RRect rightUpperArm = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX + 80, 150), width: 30, height: 65),
      Radius.circular(15),
    );
    bodyPath.addRRect(rightUpperArm);

    // Brazo derecho - antebrazo
    RRect rightForearm = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX + 75, 220), width: 26, height: 60),
      Radius.circular(13),
    );
    bodyPath.addRRect(rightForearm);

    // Mano derecha
    RRect rightHand = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX + 75, 265), width: 24, height: 32),
      Radius.circular(12),
    );
    bodyPath.addRRect(rightHand);

    // === PIERNAS MÁS ANATÓMICAS ===
    // Muslo izquierdo
    RRect leftThigh = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX - 25, 350), width: 38, height: 75),
      Radius.circular(19),
    );
    bodyPath.addRRect(leftThigh);

    // Pantorrilla izquierda
    RRect leftCalf = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX - 25, 420), width: 32, height: 65),
      Radius.circular(16),
    );
    bodyPath.addRRect(leftCalf);

    // Pie izquierdo
    RRect leftFoot = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX - 35, 465), width: 45, height: 20),
      Radius.circular(10),
    );
    bodyPath.addRRect(leftFoot);

    // Muslo derecho
    RRect rightThigh = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX + 25, 350), width: 38, height: 75),
      Radius.circular(19),
    );
    bodyPath.addRRect(rightThigh);

    // Pantorrilla derecha
    RRect rightCalf = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX + 25, 420), width: 32, height: 65),
      Radius.circular(16),
    );
    bodyPath.addRRect(rightCalf);

    // Pie derecho
    RRect rightFoot = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX + 35, 465), width: 45, height: 20),
      Radius.circular(10),
    );
    bodyPath.addRRect(rightFoot);

    // Dibujar sombra suave
    canvas.translate(2, 3);
    canvas.drawPath(bodyPath, shadowPaint);
    canvas.translate(-2, -3);

    // Dibujar cuerpo
    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    // === DETALLES ANATÓMICOS SUTILES ===
    final detailPaint = Paint()
      ..color = Color(0xFFD4A574).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Línea del cuello
    canvas.drawLine(
      Offset(centerX - 15, 108),
      Offset(centerX + 15, 108),
      detailPaint,
    );

    // Línea central del torso
    canvas.drawLine(
      Offset(centerX, 115),
      Offset(centerX, 210),
      detailPaint,
    );

    // Líneas de los pectorales
    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerX - 20, 140), width: 30, height: 20),
      0,
      3.14,
      false,
      detailPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerX + 20, 140), width: 30, height: 20),
      0,
      3.14,
      false,
      detailPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
