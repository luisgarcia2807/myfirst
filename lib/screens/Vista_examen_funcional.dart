import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constans.dart';

class CuerpoInteractivoFisicoPage extends StatefulWidget {
  final int idConsulta;
  final String nombre;
  final String apellido;

  const CuerpoInteractivoFisicoPage({super.key, required this.idConsulta,required this.nombre, required this.apellido});

  @override
  _CuerpoInteractivoFisicoPage createState() => _CuerpoInteractivoFisicoPage();
}

class _CuerpoInteractivoFisicoPage extends State<CuerpoInteractivoFisicoPage> {
  final Map<String, TextEditingController> _resumenController = {
    'general': TextEditingController(),
    'piel': TextEditingController(),
    'uñas': TextEditingController(),
    'cabeza': TextEditingController(),
    'ojos': TextEditingController(),
    'nariz': TextEditingController(),
    'oidos': TextEditingController(),
    'boca_faringe': TextEditingController(),
    'cuello': TextEditingController(),
    'ganglios': TextEditingController(),
    'torax': TextEditingController(),
    'pulmones': TextEditingController(),
    'corazon': TextEditingController(),
    'abdomen': TextEditingController(),
    'genitales': TextEditingController(),
    'recto': TextEditingController(),
    'osteomuscular': TextEditingController(),
    'neurologico_psiquico': TextEditingController(),
  };

  final Map<String, String> textosPorDefecto = {
    'general': 'No se realizó evaluación del estado general.',
    'piel': 'Exploración de piel no realizada.',
    'uñas': 'No se evaluaron las uñas.',
    'cabeza': 'Cabeza no evaluada.',
    'ojos': 'Ojos no evaluados.',
    'nariz': 'Nariz no evaluada.',
    'oidos': 'Oídos no evaluados.',
    'boca_faringe': 'Boca y faringe no evaluadas.',
    'cuello': 'Cuello no evaluado.',
    'ganglios': 'Ganglios linfáticos no evaluados.',
    'torax': 'Tórax no evaluado.',
    'pulmones': 'Pulmones no evaluados.',
    'corazon': 'Corazón no evaluado.',
    'abdomen': 'Abdomen no evaluado.',
    'genitales': 'Examen genital no realizado.',
    'recto': 'Examen rectal no realizado.',
    'osteomuscular': 'Sistema osteomuscular no evaluado.',
    'neurologico_psiquico': 'Sistema neurológico y psíquico no evaluado.',
  };

  Future<void> guardarExamenFuncional() async {
    final url = Uri.parse('$baseUrl/usuarios/api/examen-fisico/');
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
          SnackBar(content: Text('Examen fisico guardado con éxito')),
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
      'piel': 'Piel',
      'uñas': 'Uñas',
      'cabeza': 'Cabeza',
      'ojos': 'Ojos',
      'nariz': 'Nariz',
      'oidos': 'Oídos',
      'boca_faringe': 'Boca y Faringe',
      'cuello': 'Cuello',
      'ganglios': 'Ganglios Linfáticos',
      'torax': 'Tórax',
      'pulmones': 'Pulmones',
      'corazon': 'Corazón',
      'abdomen': 'Abdomen',
      'genitales': 'Genitales',
      'recto': 'Recto',
      'osteomuscular': 'Sistema Osteomuscular',
      'neurologico_psiquico': 'Sistema Neurológico y Psíquico',
    };
    return nombres[parte] ?? parte;
  }


  IconData _getIconoParte(String parte) {
    final iconos = {
      'general': Icons.person_outline,
      'piel': Icons.fingerprint,
      'uñas': Icons.cut,
      'cabeza': Icons.face_outlined,
      'ojos': Icons.remove_red_eye_outlined,
      'nariz': Icons.air,
      'oidos': Icons.hearing_outlined,
      'boca_faringe': Icons.mic_none_outlined,
      'cuello': Icons.accessibility_outlined,
      'ganglios': Icons.scatter_plot_outlined,
      'torax': Icons.accessibility_new_outlined,
      'pulmones': Icons.wind_power_outlined,
      'corazon': Icons.favorite_outline,
      'abdomen': Icons.airline_seat_flat_outlined,
      'genitales': Icons.wc_outlined,
      'recto': Icons.block_outlined,
      'osteomuscular': Icons.fitness_center_outlined,
      'neurologico_psiquico': Icons.psychology_outlined,
    };
    return iconos[parte] ?? Icons.medical_services;
  }


  Color _getColorParte(String parte) {
    final colores = {
      'general': Color(0xFF3F51B5),
      'signos_vitales': Color(0xFF009688),
      'piel': Color(0xFF8D6E63),
      'uñas': Color(0xFF6D4C41),
      'cabeza': Color(0xFF9C27B0),
      'ojos': Color(0xFF2196F3),
      'nariz': Color(0xFF4CAF50),
      'oidos': Color(0xFFFF9800),
      'boca_faringe': Color(0xFFE91E63),
      'cuello': Color(0xFF795548),
      'ganglios': Color(0xFF607D8B),
      'torax': Color(0xFF3E2723),
      'pulmones': Color(0xFF00ACC1),
      'corazon': Color(0xFFF44336),
      'abdomen': Color(0xFFFF7043),
      'genitales': Color(0xFF00BCD4),
      'recto': Color(0xFFBDBDBD),
      'osteomuscular': Color(0xFF009688),
      'neurologico_psiquico': Color(0xFF673AB7),
    };
    return colores[parte] ?? Colors.grey;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Examen Fisico ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF1565C0),
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
                    colors: [Color(0xFF1565C0).withOpacity(0.1), Color(0xFF3F51B5).withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF1565C0).withOpacity(0.2)),
                ),
                child: Text(
                  'Toca cada zona del cuerpo para registrar los hallazgos del examen físico',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1565C0),
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
                    // Cuerpo humano pintado
                    Center(
                      child: Container(
                        width: 260,
                        height: 540,
                        child: CustomPaint(
                          painter: RealisticBodyPainter(),
                        ),
                      ),
                    ),

                    // ZONAS INTERACTIVAS POSICIONADAS
                    ...[
                      {'parte': 'general', 'top': -10.0, 'left': 5.0},
                      {'parte': 'cabeza', 'top': -20.0, 'left': 128.0},
                      {'parte': 'ojos', 'top': 12.0, 'left': 110.0},
                      {'parte': 'oidos', 'top': 30.0, 'left': 75.0},
                      {'parte': 'nariz', 'top': 35.0, 'left': 135.0},
                      {'parte': 'boca_faringe', 'top': 65.0, 'left': 125.0},
                      {'parte': 'cuello', 'top': 95.0, 'left': 125.0},
                      {'parte': 'ganglios', 'top': 100.0, 'left': 60.0},
                      {'parte': 'torax', 'top': 150.0, 'left': 125.0},
                      {'parte': 'pulmones', 'top': 180.0, 'left': 95.0},
                      {'parte': 'corazon', 'top': 130.0, 'left': 155.0},
                      {'parte': 'abdomen', 'top': 220.0, 'left': 125.0},
                      {'parte': 'piel', 'top': 180.0, 'left': 200.0},
                      {'parte': 'uñas', 'top': 260.0, 'left': 200.0},
                      {'parte': 'osteomuscular', 'top': 220.0, 'left': 45.0},
                      {'parte': 'neurologico_psiquico', 'top': -5.0, 'left': 180.0},
                      {'parte': 'genitales', 'top': 275.0, 'left': 125.0},
                      {'parte': 'recto', 'top': 310.0, 'left': 125.0},
                      {'parte': 'osteomuscular', 'top': 380.0, 'left': 85.0},
                      {'parte': 'osteomuscular', 'top': 380.0, 'left': 145.0},
                    ].map((zona) {
                      final parte = zona['parte'] as String;
                      return Positioned(
                        top: zona['top'] as double,
                        left: zona['left'] as double,
                        child: zonaInteractiva(
                          parte,
                          _getIconoParte(parte),
                          _getColorParte(parte),
                        ),
                      );
                    }).toList(),

                    // NOMBRE DEL PACIENTE
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Text(
                        '${widget.nombre} ${widget.apellido}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                          backgroundColor: Colors.white70,
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
                          color: Color(0xFF1565C0),
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Progreso del Examen ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
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
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
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
                          backgroundColor: Color(0xFF1565C0), // Azul oscuro/índigo
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Puedes cambiar a 0 si lo quieres más cuadrado aún
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Tamaño
                        ),
                        child: Text(
                          'Guardar Examen Fisico',
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
          width: 30,
          height: 30,
          child: Stack(
            children: [
              Center(
                child: Icon(
                  icono,
                  color: Colors.white,
                  size: 15,
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