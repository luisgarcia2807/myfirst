import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mifirst/screens/Escaner.dart';
import 'package:mifirst/screens/subir_archivo_pdf.dart';
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
  final Map<String, Map<String, List<Map<String, String>>>> tiposCategoriasExamenes = {
    'laboratorio': {
      'hematologia': [
        {'value': 'hemograma_completo', 'label': 'Hemograma Completo'},
        {'value': 'recuento_plaquetas', 'label': 'Recuento de Plaquetas'},
        {'value': 'velocidad_sedimentacion', 'label': 'Velocidad de Sedimentación'},
        {'value': 'grupo_sanguineo', 'label': 'Grupo Sanguíneo y Rh'},
      ],
      'bioquimica': [
        {'value': 'glucosa', 'label': 'Glucosa'},
        {'value': 'urea', 'label': 'Urea'},
        {'value': 'creatinina', 'label': 'Creatinina'},
        {'value': 'colesterol_total', 'label': 'Colesterol Total'},
        {'value': 'hdl', 'label': 'HDL'},
        {'value': 'ldl', 'label': 'LDL'},
        {'value': 'trigliceridos', 'label': 'Triglicéridos'},
        {'value': 'acido_urico', 'label': 'Ácido Úrico'},
        {'value': 'tgo', 'label': 'TGO (AST)'},
        {'value': 'tgp', 'label': 'TGP (ALT)'},
        {'value': 'bilirrubina_total', 'label': 'Bilirrubina Total'},
        {'value': 'bilirrubina_directa', 'label': 'Bilirrubina Directa'},
        {'value': 'bilirrubina_indirecta', 'label': 'Bilirrubina Indirecta'},
        {'value': 'fosfatasa_alcalina', 'label': 'Fosfatasa Alcalina'},
        {'value': 'ggt', 'label': 'GGT'},
        {'value': 'amilasa', 'label': 'Amilasa'},
        {'value': 'lipasa', 'label': 'Lipasa'},
        {'value': 'electrolitos', 'label': 'Electrolitos (Na, K, Cl)'},
        {'value': 'calcio', 'label': 'Calcio'},
        {'value': 'magnesio', 'label': 'Magnesio'},
        {'value': 'perfil_renal', 'label': 'Perfil Renal'},
        {'value': 'perfil_hepatico', 'label': 'Perfil Hepático'},
        {'value': 'perfil_lipidico', 'label': 'Perfil Lipídico'},
        {'value': 'perfil_20', 'label': 'Perfil 20'},
        {'value': 'perfil_21', 'label': 'Perfil 21'},
      ],
      'orina_y_heces': [
        {'value': 'orina_rutina', 'label': 'Orina (Examen de Rutina)'},
        {'value': 'urocultivo', 'label': 'Urocultivo'},
        {'value': 'coprologico', 'label': 'Coprológico'},
        {'value': 'parasitologico', 'label': 'Parasitológico'},
        {'value': 'sangre_oculta', 'label': 'Sangre Oculta en Heces'},
      ],
      'inmunologia': [
        {'value': 'vih', 'label': 'Prueba de VIH'},
        {'value': 'vdrl', 'label': 'VDRL'},
        {'value': 'hbsag', 'label': 'HBsAg (Hepatitis B)'},
        {'value': 'anticore', 'label': 'Anti-HBc'},
        {'value': 'anti_hcv', 'label': 'Anti-HCV'},
        {'value': 'toxoplasmosis', 'label': 'Toxoplasmosis (IgG, IgM)'},
        {'value': 'rubeola', 'label': 'Rubéola (IgG, IgM)'},
        {'value': 'citomegalovirus', 'label': 'Citomegalovirus (IgG, IgM)'},
        {'value': 'fiebre_tifoidea', 'label': 'Prueba de Widal'},
      ],
    },
    'pruebas_funcionales': {
      'espirometria': [
        {'value': 'espirometria_simple', 'label': 'Espirometría Simple'},
        {'value': 'espirometria_con_broncodilatador', 'label': 'Espirometría con Broncodilatador'},
      ],
      'prueba_esfuerzo': [
        {'value': 'prueba_esfuerzo_estandar', 'label': 'Prueba de Esfuerzo Estándar'},
      ],
    },
    'cardiologia': {
      'electrocardiograma': [
        {'value': 'ecg_reposo', 'label': 'Electrocardiograma en Reposo'},
      ],
      'ecocardiograma': [
        {'value': 'eco_transtoracico', 'label': 'Ecocardiograma Transtorácico'},
        {'value': 'eco_doppler', 'label': 'Ecocardiograma Doppler'},
      ],
      'holter': [
        {'value': 'holter_24h', 'label': 'Holter 24h'},
        {'value': 'holter_48h', 'label': 'Holter 48h'},
      ],
    },
    'neurologia': {
      'encefalograma': [
        {'value': 'eeg', 'label': 'Electroencefalograma'},
      ],
      'potenciales_evocados': [
        {'value': 'potenciales_auditivos', 'label': 'Potenciales Auditivos'},
        {'value': 'potenciales_visuales', 'label': 'Potenciales Visuales'},
      ],
    },
    'informes_medicos': {
      'interconsultas': [
        {'value': 'interconsulta_cardiologia', 'label': 'Interconsulta de Cardiología'},
        {'value': 'interconsulta_neurologia', 'label': 'Interconsulta de Neurología'},
      ],
      'resumenes_clinicos': [
        {'value': 'epicrisis', 'label': 'Epicrisis'},
        {'value': 'informe_alta', 'label': 'Informe de Alta'},
      ],
      'referencias': [
        {'value': 'referencia_hospitalaria', 'label': 'Referencia Hospitalaria'},
      ],
    },
    'otros_documentos': {
      'otros': [
        {'value': 'consentimiento_informado', 'label': 'Consentimiento Informado'},
        {'value': 'historia_medica', 'label': 'Historia Médica'},
      ],
      'sin_categoria': [
        {'value': 'no_clasificado', 'label': 'Documento No Clasificado'},
      ],
    },
  };


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

  IconData _getIconCategoria(String categoria) {
    const Map<String, IconData> iconosPorCategoria = {
      'laboratorio': Icons.science,                // Representa análisis de laboratorio
      'pruebas_funcionales': Icons.fitness_center, // Representa esfuerzo físico o pruebas funcionales
      'cardiologia': Icons.favorite,               // Representa el corazón
      'neurologia': Icons.psychology,              // Representa actividad cerebral
      'informes_medicos': Icons.description,       // Documentos médicos
      'otros_documentos': Icons.folder,            // Otros documentos o archivos
    };

    return iconosPorCategoria[categoria] ?? Icons.help_outline;
  }

  Color _getColorCategoria(String categoria) {
    const Map<String, Color> coloresPorCategoria = {
      'laboratorio': Colors.red,
      'pruebas_funcionales': Colors.green,
      'cardiologia': Colors.blue,
      'neurologia': Colors.purple,
      'informes_medicos': Colors.orange,
      'otros_documentos': Colors.grey,
    };

    return coloresPorCategoria[categoria] ?? Colors.black;
  }

  String formatNombreExamen(String nombre) {
    return nombre
        .replaceAll('_', ' ')                        // Reemplaza guiones bajos por espacios
        .split(' ')                                  // Divide en palabras
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1)
        : '')
        .join(' ');                                   // Une las palabras con espacio
  }


  @override
  void initState() {

    super.initState();
    _examenes = Future.value([]); // Evita que esté null al principio
    _inicializarDatos();
  }
  Future<void> _inicializarDatos() async {
    await obtenerDatos(); // no es necesario await si no depende de datos
    await obtenerDatosPacienteSangre(widget.idusuario);
    _examenes = obtenerExamenes(idPaciente);
     //// Llamar después de que idPaciente esté disponible
  }

  @override
  Widget build(BuildContext context) {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());
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

                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  padding: EdgeInsets.all(3),
                                  child: foto == null || foto!.isEmpty
                                      ? Icon(
                                    Icons.person_pin,
                                    color: Colors.white,
                                    size: 70,
                                  )
                                      : ClipOval(
                                    child: Image.network(
                                      '$baseUrl$foto',
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Expanded( // <- ¡Esta línea soluciona el overflow!
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4.0),
                                    Text(
                                      "Pc.$nombreUsuario $apellidoUsuario",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis, // <-- por si aún se desborda
                                    ),
                                    SizedBox(height: 1.0),
                                    Text(
                                      fechaHoy,
                                      style: TextStyle(color: Colors.grey[300],fontSize: 12),
                                      overflow: TextOverflow.ellipsis, // opcional
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Examenes ',
                            style: TextStyle(color: Colors.white,fontSize: 25),
                            overflow: TextOverflow.ellipsis, // opcional
                          ),
                          SizedBox(height: 25),

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
                                    onTap: () async{
                                      final resultado = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ScanView(idPaciente: idPaciente),
                                        ),
                                      );
                                      if (resultado == true) {
                                        setState(() {
                                          _examenes = obtenerExamenes(idPaciente);
                                        });
                                      }
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
                                    onTap: () async {
                                      final resultado = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SubirPDFPage(idPaciente: idPaciente),
                                        ),
                                      );

                                      if (resultado == true) {
                                        setState(() {
                                          _examenes = obtenerExamenes(idPaciente);
                                        });
                                      }
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
                              child: FutureBuilder<List<Examen>>(
                                future: _examenes,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return const Center(
                                      child: Text(
                                        '❌ Error al cargar los exámenes.\nRevisa tu conexión o intenta más tarde.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    );
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No hay exámenes disponibles para este paciente.',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    );
                                  }
                                  final examenes = snapshot.data!;

                                  return ListView.builder(
                                    itemCount: examenes.length,
                                    itemBuilder: (context, index) {
                                      final examen = examenes[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        color: Colors.white,
                                        elevation: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              /// Título (nombre del examen) + PDF a la derecha
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      formatNombreExamen(examen.nombreExamen),
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black87,
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
                                              const SizedBox(height: 10),

                                              /// Contenido principal: ícono + info
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      color: _getColorCategoria(examen.tipo),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Icon(
                                                      _getIconCategoria(examen.tipo),
                                                      color: Colors.white,
                                                      size: 40,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.folder_open, size: 18, color: Colors.black54),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              'Tipo: ${formatNombreExamen(examen.tipo)}',
                                                              style: const TextStyle(
                                                                color: Colors.black54,
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.category, size: 18, color: Colors.black54),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              'Categoría: ${formatNombreExamen(examen.categoria)}',
                                                              style: const TextStyle(
                                                                color: Colors.black54,
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 6),
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              'Fecha: ${examen.fechaRealizacion}',
                                                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 4),
                                                        if (examen.descripcion != null && examen.descripcion.isNotEmpty)
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              const Icon(Icons.description, size: 18, color: Colors.black54),
                                                              const SizedBox(width: 4),
                                                              Expanded(
                                                                child: Text(
                                                                  'Descripción: ${examen.descripcion}',
                                                                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                      ],
                                                    ),
                                                  ),


                                                ],
                                              ),
                                            ],
                                          )

                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            )

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
    final fileName = url.split('/').last.split('?').first; // quita el "?" final
    final filePath = '${tempDir.path}/$fileName';

    // Limpia URL si tiene "?" vacío
    final cleanedUrl = url.replaceAll(RegExp(r'\?$'), '');

    print('⬇️ Descargando desde: $cleanedUrl');
    await dio.download(cleanedUrl, filePath);
    await OpenFilex.open(filePath);
  }


}

Future<List<Examen>> obtenerExamenes(int pacienteId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/api/examenes/$pacienteId/'),
    );

    if (response.statusCode == 200) {
      List jsonData = json.decode(utf8.decode(response.bodyBytes));
      return jsonData.map((e) => Examen.fromJson(e)).toList();
    } else if (response.statusCode == 404) {
      // Puedes considerar devolver lista vacía si no hay exámenes
      return [];
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  } catch (e) {
    // Log o manejo personalizado
    throw Exception('Error de conexión o formato: $e');
  }
}
