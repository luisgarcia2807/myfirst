import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' as path;
import '../constans.dart';

class SubirPDFPageImagen extends StatefulWidget {
  final int idPaciente;
  final int? idusuariodoc;
  const SubirPDFPageImagen({super.key, required this.idPaciente, this.idusuariodoc});
  @override
  _SubirPDFPageImagenState createState() => _SubirPDFPageImagenState();
}

class _SubirPDFPageImagenState extends State<SubirPDFPageImagen> {
  File? archivoPDF;
  final Map<String, Map<String, List<Map<String, String>>>> tiposCategoriasExamenes = {
    'Rayos x': {
      'torax': [
        {'value': 'radiografía de tórax PA', 'label': 'Radiografía de tórax PA'},
        {'value': 'radiografía de tórax lateral', 'label': 'Radiografía de tórax Lateral'},
      ],
      'abdomen': [
        {'value': 'radiografía de abdomen simple', 'label': 'Radiografía de abdomen simple'},
      ],
      'extremidades': [
        {'value': 'radiografía de rodilla', 'label': 'Radiografía de rodilla'},
        {'value': 'radiografía de mano', 'label': 'Radiografía de mano'},
        {'value': 'radiografía de pie', 'label': 'Radiografía de pie'},
      ],
      'columna': [
        {'value': 'radiografía de columna cervical', 'label': 'Radiografía de columna cervical'},
        {'value': 'radiografía de columna lumbar', 'label': 'Radiografía de columna lumbar'},
        {'value': 'radiografía de columna dorsal', 'label': 'Radiografía de columna dorsal'},
      ],
      'cráneo': [
        {'value': 'Radiografía de cráneo', 'label': 'Radiografía de cráneo'},
      ],
    },
    'tomografia': {
      'cráneo': [
        {'value': 'TAC de cráneo sin contraste', 'label': 'TAC de cráneo sin contraste'},
      ],
      'torax': [
        {'value': 'TAC torácico de alta resolución (HRCT)', 'label': 'TAC torácico de alta resolución (HRCT)'},
      ],
      'abdomen y pelvis': [
        {'value': 'TAC abdomino-pélvico con contraste', 'label': 'TAC abdomino-pélvico con contraste'},
      ],
      'columna': [
        {'value': 'TAC de columna lumbar', 'label': 'TAC de columna lumbar)'},
      ],
      'vasos sanguineos': [
        {'value': 'Angio-TAC de aorta', 'label': 'Angio-TAC de aorta'},
      ],
    },
    'resonancia magnética': {
      'cráneo': [
        {'value': 'RMN cerebral funcional', 'label': 'RMN cerebral funcional'},
        {'value': 'RMN de silla turca', 'label': 'RMN de silla turca'},
      ],
      'columna': [
        {'value': 'RMN de columna cervical', 'label': 'RMN de columna cervical'},
        {'value': 'RMN de columna lumbar', 'label': 'RMN de columna lumbar'},
      ],
      'Abdomen': [
        {'value': 'RMN hepática', 'label': 'RMN hepática'},
        {'value': 'RMN pancreática', 'label': 'RMN pancreática'},
      ],
      'Articulaciones': [
        {'value': 'RMN de rodilla', 'label': 'RMN de rodilla'},
        {'value': 'RMN de hombro', 'label': 'RMN de hombro'},
      ],
      'Corazón': [
        {'value': 'RMN cardíaca', 'label': 'RMN cardíaca'},
      ],
    },
    'Ecografía': {
      'Abdominal': [
        {'value': 'Ecografía hepática', 'label': 'Ecografía hepática'},
        {'value': 'Ecografía de vesícula biliar', 'label': 'Ecografía de vesícula biliar'},
      ],
      'Obstétrica y Ginecológica': [
        {'value': 'Ecografía transvaginal', 'label': 'Ecografía transvaginal'},
        {'value': 'Ecografía morfología fetal', 'label': 'Ecografía morfología fetal'},
      ],
      'tiroidea': [
        {'value': 'Ecografía de tiroides', 'label': 'Ecografía de tiroides'},
      ],
      'renal': [
        {'value': 'Ecografía renal bilateral', 'label': 'Ecografía renal bilateral'},
      ],
      'Musculoesquelética': [
        {'value': 'Eco de partes blandas', 'label': 'Eco de partes blandas'},
      ],
      'Doppler': [
        {'value': 'Doppler carotideo', 'label': 'Doppler carotideo'},
        {'value': 'Doppler de miembros inferiores', 'label': 'Doppler de miembros inferiores'},
      ],
    },
    'mamografía': {
      'Diagnóstica': [
        {'value': 'Mamografía unilateral', 'label': 'Mamografía unilateral'},
        {'value': 'Mamografía bilateral', 'label': 'Mamografía bilateral'},
      ],
      'Tamizaje': [
        {'value': 'Mamografía de rutina', 'label': 'Mamografía de rutina'},
      ],
      'Digital': [
        {'value': 'Mamografía digital directa', 'label': 'Mamografía digital directa'},
      ],
    },
    'Densitometría Ósea': {
      'Cadera': [
        {'value': 'Densitometría ósea de cadera', 'label': 'Densitometría ósea de cadera'},
      ],
      'Columna': [
        {'value': 'Densitometría ósea de columna lumbar', 'label': 'Densitometría ósea de columna lumbar'},
      ],
      'total': [
        {'value': 'Densitometría corporal completa', 'label': 'Densitometría corporal completa'},
      ],
    },
    'Medicina Nuclear': {
      'osea': [
        {'value': 'Gammagrafía ósea', 'label': 'Gammagrafía ósea'},
      ],
      'renal': [
        {'value': 'Gammagrafía renal', 'label': 'Gammagrafía renal'},
      ],
      'tiroidea': [
        {'value': 'Captación de yodo radiactivo (RAIU)', 'label': 'Captación de yodo radiactivo (RAIU)'},
      ],
      'Cardíaca': [
        {'value': 'Perfusión miocárdica', 'label': 'Perfusión miocárdica'},
      ],
    },
    'Angiografía': {
      'Cerebral': [
        {'value': 'Angiografía cerebrala', 'label': 'Angiografía cerebral'},
      ],
      'Coronaria': [
        {'value': 'Cateterismo cardíaco', 'label': 'Cateterismo cardíaco'},
      ],
      'Periférica': [
        {'value': 'Angiografía de extremidades', 'label': 'Angiografía de extremidades'},
      ],
    },
    'Fluoroscopía': {
      'Tracto digestivo': [
        {'value': 'Serie esofagogastroduodenal', 'label': 'Serie esofagogastroduodenal'},
        {'value': 'Enema opaco', 'label': 'Enema opaco'},

      ],
      'Articulaciones': [
        {'value': 'Artrografía', 'label': 'Artrografía'},
      ],

    },
    'pet scan': {
      'Oncológica': [
        {'value': 'PET/CT para estudio de cáncer', 'label': 'PET/CT para estudio de cáncer'},
      ],
      'Neurológica': [
        {'value': 'PET cerebral', 'label': 'PET cerebral'},
      ],
      'Cardíaca': [
        {'value': 'PET de viabilidad miocárdica', 'label': 'PET de viabilidad miocárdica'},
      ],
    },
  };
  String? _tipoSeleccionado;
  String? _categoriaSeleccionada;
  List<String> _categoriasFiltradas = [];

  void _actualizarCategorias() {
    if (_tipoSeleccionado != null) {
      final categoriasMap = tiposCategoriasExamenes[_tipoSeleccionado];
      if (categoriasMap != null) {
        _categoriasFiltradas = categoriasMap.keys.toList();
      } else {
        _categoriasFiltradas = [];
      }
    }
  }

  List<Map<String, String>> _obtenerExamenesDeCategoria() {
    if (_tipoSeleccionado != null && _categoriaSeleccionada != null) {
      final categoria = tiposCategoriasExamenes[_tipoSeleccionado]?[_categoriaSeleccionada];
      if (categoria != null) {
        return categoria;
      }
    }
    return [];
  }

  String? _nombreExamenSeleccionado;
  final TextEditingController _descripcionController = TextEditingController();
  DateTime _fechaRealizacion = DateTime.now();

  Future<void> seleccionarPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        archivoPDF = File(result.files.single.path!);
      });
    }
  }

  // Función para limpiar caracteres especiales del nombre del archivo
  String limpiarNombreArchivo(String input) {
    final conAcentos = 'áéíóúÁÉÍÓÚñÑ';
    final sinAcentos = 'aeiouAEIOUnN';

    for (int i = 0; i < conAcentos.length; i++) {
      input = input.replaceAll(conAcentos[i], sinAcentos[i]);
    }

    return input.replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_').toLowerCase();
  }

  Future<void> subirPDF() async {
    if (archivoPDF == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un archivo PDF primero')),
      );
      return;
    }

    // Verificar que sea un archivo PDF
    if (!archivoPDF!.path.toLowerCase().endsWith('.pdf')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo se permiten archivos PDF')),
      );
      return;
    }

    try {
      final originalFile = archivoPDF!;
      final directory = originalFile.parent;

      // 🔧 Nombre original limpio
      String originalName = limpiarNombreArchivo(
        path.basenameWithoutExtension(originalFile.path).replaceAll(' ', '_'),
      );

      // 🔧 Datos adicionales
      String idPaciente = widget.idPaciente.toString();
      String nombreExamen = limpiarNombreArchivo(_nombreExamenSeleccionado ?? 'Sin_especificar');

      // 🧾 Nombre final del archivo
      String nuevoNombre = '${originalName}_paciente${idPaciente}_$nombreExamen.pdf';
      String newPath = path.join(directory.path, nuevoNombre);

      // Crear nuevo archivo con nombre modificado
      final renamedFile = await originalFile.copy(newPath);

      final uri = Uri.parse('$baseUrl/usuarios/api/imagenologia/');
      final request = http.MultipartRequest('POST', uri);

      // Campos del formulario
      request.fields['paciente'] = idPaciente;
      request.fields['tipo'] = _tipoSeleccionado!;
      request.fields['categoria'] = _categoriaSeleccionada!;
      request.fields['nombre_examen'] = _nombreExamenSeleccionado ?? 'Sin especificar';
      request.fields['descripcion'] = _descripcionController.text;
      request.fields['fecha_realizacion'] = _fechaRealizacion.toIso8601String().split('T').first;
      if (widget.idusuariodoc != null) {
        request.fields['doctor'] = widget.idusuariodoc.toString();
      }

      // Adjuntar archivo
      request.files.add(
        await http.MultipartFile.fromPath('archivo', renamedFile.path),
      );

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF subido correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir el PDF: ${response.statusCode}')),
        );
      }

      // Eliminar archivo temporal renombrado
      await renamedFile.delete();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final colores = [
      const Color(0xFF0D47A1),
      const Color(0xFF1976D2),
      const Color(0xFF42A5F5),
      const Color(0xFF7E57C2),
      const Color(0xFF26C6DA),
    ];
    return Scaffold(
      appBar: AppBar(
          backgroundColor: colores[0],
          title: Text("Cargar Imagen",style: TextStyle(color:Colors.white),)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Color(0xFFF5F8FA), // Fondo claro, puedes cambiarlo
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botón para seleccionar PDF

                const SizedBox(height: 10),

                // Visualización elegante del archivo seleccionado
                archivoPDF != null
                    ? Card(
                  color: Colors.grey[100],
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                    title: Text(archivoPDF!.path.split('/').last),
                    subtitle: Text("Archivo listo para subir"),
                  ),
                )
                    : Text(
                  "Ningún archivo seleccionado",
                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),

                const SizedBox(height: 20),

                // Formulario dentro del Card
                Card(
                  color: Color(0xFFF5F8FA),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _tipoSeleccionado,
                          decoration: InputDecoration(
                            labelText: 'Tipo de documento',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          isExpanded: true, // MUY IMPORTANTE para evitar desbordamiento horizontal
                          items: tiposCategoriasExamenes.keys.map((tipo) {
                            return DropdownMenuItem<String>(
                              value: tipo,
                              child: Text(
                                tipo.replaceAll('_', ' ').toUpperCase(),
                                overflow: TextOverflow.visible, // En el menú desplegable se ve completo
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (BuildContext context) {
                            return tiposCategoriasExamenes.keys.map((tipo) {
                              final texto = tipo.replaceAll('_', ' ').toUpperCase();
                              return Tooltip(
                                message: texto,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    texto,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (String? nuevoTipo) {
                            setState(() {
                              _tipoSeleccionado = nuevoTipo;
                              _categoriaSeleccionada = null;
                              _nombreExamenSeleccionado = null;
                              _categoriasFiltradas = tiposCategoriasExamenes[nuevoTipo]?.keys.toList() ?? [];
                            });
                          },
                          validator: (value) => value == null ? 'Selecciona un tipo' : null,
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _categoriaSeleccionada,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          isExpanded: true,
                          items: _categoriasFiltradas.map((categoria) {
                            return DropdownMenuItem<String>(
                              value: categoria,
                              child: Text(
                                categoria.replaceAll('_', ' ').toUpperCase(),
                                overflow: TextOverflow.visible,
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (BuildContext context) {
                            return _categoriasFiltradas.map((categoria) {
                              final texto = categoria.replaceAll('_', ' ').toUpperCase();
                              return Tooltip(
                                message: texto,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    texto,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (String? nuevaCategoria) {
                            setState(() {
                              _categoriaSeleccionada = nuevaCategoria;
                              _nombreExamenSeleccionado = null;
                            });
                          },
                          validator: (value) => value == null ? 'Selecciona una categoría' : null,
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _nombreExamenSeleccionado,
                          decoration: InputDecoration(
                            labelText: 'Examen',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          isExpanded: true,
                          items: _obtenerExamenesDeCategoria().map((examen) {
                            return DropdownMenuItem<String>(
                              value: examen['value'],
                              child: Text(
                                examen['label'] ?? examen['value'] ?? '',
                                overflow: TextOverflow.visible,
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (BuildContext context) {
                            return _obtenerExamenesDeCategoria().map((examen) {
                              final texto = examen['label'] ?? examen['value'] ?? '';
                              return Tooltip(
                                message: texto,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    texto,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (String? nuevoExamen) {
                            setState(() {
                              _nombreExamenSeleccionado = nuevoExamen;
                            });
                          },
                          validator: (value) => value == null ? 'Selecciona un examen' : null,
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: _descripcionController,
                          decoration: InputDecoration(
                            labelText: 'Descripción (opcional)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),

                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Fecha de realización',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today, color: Colors.blueAccent),
                              onPressed: () async {
                                final fecha = await showDatePicker(
                                  context: context,
                                  initialDate: _fechaRealizacion,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (fecha != null) {
                                  setState(() => _fechaRealizacion = fecha);
                                }
                              },
                            ),
                          ),
                          child: Text(
                            _fechaRealizacion.toLocal().toString().split(' ')[0],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: seleccionarPDF,
                  icon: Icon(Icons.attach_file),
                  label: Text("Seleccionar archivo PDF"),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                ),
                SizedBox(height: 10,),

                // Botón para subir
                ElevatedButton.icon(
                  onPressed: subirPDF,
                  icon: Icon(Icons.upload_file,color: Colors.white,),
                  label: Text("Subir Examen",style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colores[0],
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
}
