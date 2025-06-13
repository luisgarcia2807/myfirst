import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mifirst/screens/Escanerimagenologia.dart';
import 'package:mifirst/screens/subir_archivo_pdr_imagenologia.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/examenlaboratorio.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../constans.dart';
class ImagenPage extends StatefulWidget {
  final int idusuario;

  const ImagenPage({super.key, required this.idusuario});

  @override
  State<ImagenPage> createState() => _ImagenPageState();
}

class _ImagenPageState extends State<ImagenPage> {

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
  Future<void> eliminarExamen(int idExamen) async {
    final url = Uri.parse('$baseUrl/usuarios/api/imagenologia/eliminar/$idExamen/');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Examen eliminado correctamente")),
        );

        setState(() {
          _examenes = _examenes.then((lista) {
            lista.removeWhere((examen) => examen.id == idExamen);
            return lista;
          });
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar con el servidor")),
      );
      print('Error: $e');
    }
  }

  IconData _getIconTipo(String tipo) {
    const Map<String, IconData> iconosPorTipo = {
      'Rayos x': Icons.wb_iridescent, // Rayos X o imagen clásica
      'tomografia': Icons.dns, // TAC
      'resonancia magnética': Icons.blur_circular, // Resonancia
      'Ecografía': Icons.monitor_heart, // Ultrasonido
      'mamografía': Icons.female,
      'Densitometría Ósea': Icons.fitness_center,
      'Medicina Nuclear': Icons.bubble_chart,
      'Angiografía': Icons.bloodtype,
      'Fluoroscopía': Icons.theater_comedy, // o 'sync_alt'
      'pet scan': Icons.brightness_7, // o Icons.science
    };

    // Ignora mayúsculas y tildes
    final tipoNormalizado = tipo.toLowerCase().replaceAll('í', 'i').replaceAll('é', 'e').replaceAll('ó', 'o').replaceAll('ú', 'u').replaceAll('á', 'a');

    // Normaliza las claves del mapa también
    for (var entry in iconosPorTipo.entries) {
      final claveNormalizada = entry.key.toLowerCase().replaceAll('í', 'i').replaceAll('é', 'e').replaceAll('ó', 'o').replaceAll('ú', 'u').replaceAll('á', 'a');
      if (tipoNormalizado == claveNormalizada) return entry.value;
    }

    return Icons.help_outline; // Si no coincide
  }

  Color _getColorTipo(String tipo) {
    const Map<String, Color> coloresPorTipo = {
      'Rayos x': Colors.blueGrey,
      'tomografia': Colors.deepPurple,
      'resonancia magnética': Colors.indigo,
      'Ecografía': Colors.teal,
      'mamografía': Colors.pinkAccent,
      'Densitometría Ósea': Colors.orange,
      'Medicina Nuclear': Colors.green,
      'Angiografía': Colors.redAccent,
      'Fluoroscopía': Colors.amber,
      'pet scan': Colors.cyan,
    };

    // Normaliza la entrada para evitar errores por tildes o mayúsculas
    final tipoNormalizado = tipo.toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');

    for (var entry in coloresPorTipo.entries) {
      final claveNormalizada = entry.key.toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u');

      if (tipoNormalizado == claveNormalizada) return entry.value;
    }

    return Colors.grey; // Color por defecto si no hay coincidencia
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
                            'Imagenologia ',
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
                                          builder: (context) => ScanViewImagen(idPaciente: idPaciente,),
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
                                              "Scanear Imagen",
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
                                          builder: (context) => SubirPDFPageImagen(idPaciente: idPaciente,),
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
                                              "Subir Archivo",
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
                                                    if (examen.doctor != null)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green.shade50,
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: Row(
                                                          children: const [
                                                            Icon(Icons.verified, color: Colors.green, size: 18),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              "Aprobado",
                                                              style: TextStyle(
                                                                color: Colors.green,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ],
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
                                                        color:  _getColorTipo(examen.tipo),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Icon(
                                                        _getIconTipo(examen.tipo),
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
                                                          if (examen.doctor != null && examen.doctor.toString().isNotEmpty) ...[
                                                            const SizedBox(height: 4),
                                                            Row(
                                                              children: [
                                                                const Icon(Icons.medical_services, size: 18, color: Colors.black54),
                                                                const SizedBox(width: 4),
                                                                Text('Doctor: ${examen.nombre_doctor}', style: const TextStyle(color: Colors.black87, fontSize: 12)),
                                                              ],
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (examen.doctor == null)
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [

                                                      IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              title: const Text('Confirmar eliminación'),
                                                              content: const Text('¿Estás seguro de que deseas eliminar esta examen?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.of(context).pop(),
                                                                  child: const Text('Cancelar'),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () async {
                                                                    Navigator.of(context).pop();
                                                                    await eliminarExamen(examen.id);
                                                                    setState(() {
                                                                      examenes.removeAt(examen.id);
                                                                    });
                                                                  },
                                                                  child: const Text('Eliminar'),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
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
      Uri.parse('$baseUrl/usuarios/api/imagenologia/$pacienteId/'),
    );

    if (response.statusCode == 200) {
      // Decodificar respuesta y mapear a lista de objetos Examen
      List jsonData = json.decode(utf8.decode(response.bodyBytes));
      return jsonData.map((e) => Examen.fromJson(e)).toList();
    } else {
      // Otros errores del servidor
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  } catch (e) {
    // Manejo de errores de red o parsing
    throw Exception('Error al obtener los exámenes: $e');
  }
}
