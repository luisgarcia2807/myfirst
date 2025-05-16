import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mifirst/screens/Escaner.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/examenlaboratorio.dart';

import 'package:intl/intl.dart';
import 'dart:convert';
import '../constans.dart';
class ExamenesPage extends StatefulWidget {
  final int idusuario;

  const ExamenesPage({super.key, required this.idusuario});

  @override
  State<ExamenesPage> createState() => _ExamenesPageState();
}

class _ExamenesPageState extends State<ExamenesPage> {

  String nombreUsuario = '';
  String apellidoUsuario = '';
  String cedulaUsuario = '';
  String emailUsuario = '';
  String telefonoUsuario = '';
  String fechaNacimientoUsuario = '';
  bool estadoUsuario = false;
  int idRolUsuario = 0;
  String? foto='';
  bool isLoading = true;
  int idPaciente = 0;
  int idSangre = 0;
  String tipoSangre = '';
  String? nivelSeleccionado;
  String? tipoSeleccionado= 'medicamento';
  int? selectedAlergiaId;
  late Future<List<Examen>> _examenes;

  Future<void> obtenerDatos() async {
    final url = Uri.parse('$baseUrl/usuarios/api/usuario/${widget.idusuario}/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var datos = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          nombreUsuario = datos['nombre'];
          apellidoUsuario = datos['apellido'];
          cedulaUsuario = datos['cedula'];
          emailUsuario = datos['email'];
          telefonoUsuario = datos['telefono'];
          fechaNacimientoUsuario = datos['fecha_nacimiento'];
          estadoUsuario = datos['estado'];
          idRolUsuario = datos['id_rol'];
          foto =datos['foto_perfil'];

          if (foto != null && foto!.isNotEmpty) {
            // Reemplazamos 'localhost' por tu baseUrl
            String nuevaFotoUrl = foto!.replaceFirst('http://localhost:8000', baseUrl);
            print(nuevaFotoUrl); // Esto imprimirá la URL con tu baseUrl
          } else {
            // Si la foto es nula o vacía, puedes manejar el caso como desees
            print('La foto no está disponible');
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }
  Future<void> obtenerDatosPacienteSangre(int idUsuario) async {
    final url = Uri.parse('$baseUrl/usuarios/api/pacientes/por-usuario/$idUsuario/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var datos = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          idPaciente = datos['id_paciente']; // Asignamos el id del paciente
          idSangre = datos['id_sangre']['id_sangre']; // Asignamos el id de sangre
          tipoSangre = datos['id_sangre']['tipo_sangre']; // Asignamos el tipo de sangre
          isLoading = false; // Cambiamos el estado de carga
        });
      } else {
        print('Error al obtener el tipo de sangre: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  IconData _getIconExamen(String nombre) {
    switch (nombre) {
      case 'Hemograma completo':
      case 'Hematológica':
        return Icons.bloodtype;

      case 'Química sanguínea':
      case 'Perfil lipídico':
      case 'Glucosa en ayunas':
      case 'Curva de tolerancia a la glucosa':
        return Icons.analytics;

      case 'Examen general de orina':
        return Icons.water_drop;

      case 'Coprológico':
        return Icons.inventory_2;

      case 'Función hepática':
        return Icons.local_bar;

      case 'Función renal':
        return Icons.opacity;

      case 'Electrolitos séricos':
        return Icons.bolt;

      case 'Pruebas tiroideas':
        return Icons.threesixty;

      case 'Prueba de embarazo (beta-hCG)':
        return Icons.pregnant_woman;

      case 'Serología para VIH':
      case 'Prueba de hepatitis B':
      case 'Prueba de hepatitis C':
      case 'Prueba de COVID-19':
        return Icons.sick;

      case 'Pruebas de coagulación':
        return Icons.scatter_plot;

      case 'Antígeno prostático específico (PSA)':
      case 'Marcador tumoral CA-125':
      case 'Marcador tumoral CEA':
        return Icons.biotech;

      default:
        return Icons.device_unknown;
    }
  }
  Color _getColorExamen(String nombre) {
    switch (nombre) {
      case 'Hemograma completo':
        return Colors.red;

      case 'Química sanguínea':
      case 'Perfil lipídico':
      case 'Glucosa en ayunas':
      case 'Curva de tolerancia a la glucosa':
        return Colors.orange;

      case 'Examen general de orina':
        return Colors.yellow;

      case 'Coprológico':
        return Colors.brown;

      case 'Función hepática':
        return Colors.green;

      case 'Función renal':
        return Colors.blue;

      case 'Electrolitos séricos':
        return Colors.indigo;

      case 'Pruebas tiroideas':
        return Colors.purple;

      case 'Prueba de embarazo (beta-hCG)':
        return Colors.pink;

      case 'Serología para VIH':
      case 'Prueba de hepatitis B':
      case 'Prueba de hepatitis C':
      case 'Prueba de COVID-19':
        return Colors.teal;

      case 'Pruebas de coagulación':
        return Colors.deepOrange;

      case 'Antígeno prostático específico (PSA)':
      case 'Marcador tumoral CA-125':
      case 'Marcador tumoral CEA':
        return Colors.grey;

      default:
        return Colors.black45;
    }
  }

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }
  Future<void> _inicializarDatos() async {
    await obtenerDatos(); // no es necesario await si no depende de datos
    await obtenerDatosPacienteSangre(widget.idusuario);
    _examenes = obtenerExamenes(idPaciente); // Llamar después de que idPaciente esté disponible
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Examen>>(
        future: _examenes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('Error al cargar los exámenes'));

          final examenes = snapshot.data!;
          return Scaffold(
            body: isLoading
                ? Center(child: CircularProgressIndicator())
                : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D47A1), // Azul oscuro
                      Color(0xFF1976D2), // Azul medio
                      Color(0xFF42A5F5), // Azul claro
                      Color(0xFF7E57C2), // Morado
                      Color(0xFF26C6DA), // Turquesa,
                    ]),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        children: [
                          SizedBox(height: 25),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                padding: EdgeInsets.all(3), // Reducido
                                child: foto == null || foto!.isEmpty
                                    ? Icon(
                                  Icons.person_pin,
                                  color: Colors.white,
                                  size: 100, // Reducido
                                )
                                    : ClipOval(
                                  child: Image.network(
                                    '$baseUrl$foto',
                                    width: 100, // Reducido
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 12),
                                  Text(
                                    "Vista de examen",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    nombreUsuario,
                                    style: TextStyle(color: Colors.white.withOpacity(0.7),fontSize: 30),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.0),


                            ],
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ScanView(idPaciente: idPaciente),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF0D47A1),
                                            Color(0xFF1976D2),
                                            Color(0xFF42A5F5),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                                          SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              "Scanear Examen",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      // Función futura
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF0D47A1),
                                            Color(0xFF1976D2),
                                            Color(0xFF42A5F5),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.file_present_sharp, color: Colors.white, size: 20),
                                          SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              "Subir Examen",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),


                            const SizedBox(height: 12),
                            Expanded(
                              child: examenes.isEmpty
                                  ? const Center(child: CircularProgressIndicator())
                                  : ListView.builder(
                                itemCount: examenes.length,
                                itemBuilder: (context, index) {
                                  final examen = examenes[index];

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    color: Colors.white,
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Espaciado arriba para alinear con la parte baja
                                          Padding(
                                            padding: const EdgeInsets.only(top: 30), // ajusta este valor si lo deseas más abajo
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _getColorExamen(examen.nombreExamen).withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(10),
                                              child: Icon(
                                                _getIconExamen(examen.nombreExamen),
                                                color: _getColorExamen(examen.nombreExamen),
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        examen.nombreExamen,
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                                      onPressed: () {
                                                        _abrirPDF(examen.archivo);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  'Fecha: ${examen.fechaRealizacion}',
                                                  style: const TextStyle(color: Colors.black54),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Descripción: ${examen.descripcion}',
                                                  style: const TextStyle(color: Colors.black54),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )













                  ],
                ),
              ),
            ),
          );




        },
      ),
    );
  }

  Future<void> _abrirPDF(String url) async {
    final dio = Dio();
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${url.split('/').last}';
    await dio.download('$baseUrl$url', filePath);
    await OpenFilex.open(filePath);
  }
}

Future<List<Examen>> obtenerExamenes(int pacienteId) async {
  final response = await http.get(Uri.parse('$baseUrl/usuarios/api/examenes/$pacienteId/'));

  if (response.statusCode == 200) {
    List jsonData = json.decode(utf8.decode(response.bodyBytes));
    return jsonData.map((e) => Examen.fromJson(e)).toList();
  } else {
    throw Exception('Error al cargar los exámenes');
  }
}
