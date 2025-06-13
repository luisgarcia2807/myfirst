import 'dart:io';
import 'dart:typed_data';  // Para Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mifirst/screens/prueba%20de%20imagen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
// Import para crop_your_image:
import 'package:crop_your_image/crop_your_image.dart';

import '../constans.dart'; // Ajusta la ruta según tu proyecto

class ScanViewImagen extends StatefulWidget {
  final int idPaciente;
  final int? idusuariodoc;
  const ScanViewImagen({super.key, required this.idPaciente, this.idusuariodoc});

  @override
  State<ScanViewImagen> createState() => _ScanViewImagenState();
}

class _ScanViewImagenState extends State<ScanViewImagen> {
  List<File> _imagenes = [];
  List<File> _imagenesRecortadas = []; // <-- Nueva lista para las imágenes recortadas originales
  List<Uint8List> imagenesOriginales = [];
  File? _pdfFile;
  bool _mejorarImagen = false;
  bool _usarRecortadas = true;

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


  // Controlador para crop_your_image
  final _cropController = CropController();
  Uint8List? _imageBytesToCrop;

  Future<void> _pickAndCropImage() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de cámara denegado')),
      );
      return;
    }

    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;

    File imageToProcess;

    // Intentar recortar
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar imagen',
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Recortar imagen',
        ),
      ],
    );

    if (croppedFile != null && await File(croppedFile.path).exists()) {
      imageToProcess = File(croppedFile.path);
    } else {
      // Copiar la imagen original a un archivo temporal para asegurarse de que sea válido
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/original_${DateTime.now().millisecondsSinceEpoch}.jpg';
      imageToProcess = await File(picked.path).copy(tempPath);
    }

    try {
      final tempDir = await getTemporaryDirectory();

      // Guardar la imagen que vamos a procesar
      if (mounted) {
        setState(() => _imagenesRecortadas.add(imageToProcess));
      }

      Uint8List? imagenProcesadaBytes = await ProcesadorDeDocumento.procesar(imageToProcess);

      if (imagenProcesadaBytes == null || imagenProcesadaBytes.isEmpty) {
        throw Exception('La imagen procesada está vacía o falló el procesamiento');
      }

      final processedPath = '${tempDir.path}/procesada_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File processedFile = await File(processedPath).writeAsBytes(imagenProcesadaBytes);

      if (_mejorarImagen) {
        final original = img.decodeImage(imagenProcesadaBytes);
        if (original != null) {
          final mejorada = img.adjustColor(original, contrast: 1.2, brightness: 0.1);
          final mejoradaBytes = img.encodeJpg(mejorada);
          await processedFile.writeAsBytes(mejoradaBytes);
        }
      }

      if (mounted) {
        setState(() => _imagenes.add(processedFile));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar imagen: $e')),
        );
      }
    }
  }


  // Modificar _saveAsPdf para que solo cree el PDF y lo guarde

  Future<void> _saveAsPdf() async {
    final listaImagenes = _usarRecortadas ? _imagenesRecortadas : _imagenes;

    if (listaImagenes.isEmpty) return;

    final pdf = pw.Document();

    for (File imagen in listaImagenes) {
      final image = pw.MemoryImage(imagen.readAsBytesSync());
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/documento_escaneado_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    setState(() => _pdfFile = file);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF creado correctamente')),
    );
  }


// Nuevo método para subir PDF manualmente
  Future<void> _uploadPdf() async {
    if (_pdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero crea el PDF')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subiendo PDF...')),
    );

    await _subirPdfAlServidor(_pdfFile!);
  }

  String limpiarNombreArchivo(String input) {
    final conAcentos = 'áéíóúÁÉÍÓÚñÑ';
    final sinAcentos = 'aeiouAEIOUnN';

    for (int i = 0; i < conAcentos.length; i++) {
      input = input.replaceAll(conAcentos[i], sinAcentos[i]);
    }

    return input.replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_').toLowerCase();
  }

  Future<void> _subirPdfAlServidor(File archivoOriginal) async {
    try {
      final directory = archivoOriginal.parent;

      // 🧼 Limpiar nombre original del archivo
      String nombreOriginal = limpiarNombreArchivo(
        path.basenameWithoutExtension(archivoOriginal.path).replaceAll(' ', '_'),
      );

      // 📋 Datos del paciente y examen
      String idPaciente = widget.idPaciente.toString();
      String nombreExamen = limpiarNombreArchivo(_nombreExamenSeleccionado ?? 'Sin_especificar');

      // 🧾 Generar nombre final del archivo
      String nuevoNombre = '${nombreOriginal}_paciente${idPaciente}_$nombreExamen.pdf';
      String nuevoPath = path.join(directory.path, nuevoNombre);

      // 📄 Crear archivo renombrado temporalmente
      final archivoRenombrado = await archivoOriginal.copy(nuevoPath);

      // 🌐 Crear la solicitud HTTP
      final uri = Uri.parse('$baseUrl/usuarios/api/imagenologia/');
      final request = http.MultipartRequest('POST', uri);

      // 📎 Adjuntar el archivo renombrado
      request.files.add(await http.MultipartFile.fromPath('archivo', archivoRenombrado.path));

      // 📝 Campos del formulario
      request.fields['paciente'] = idPaciente;
      request.fields['tipo'] = _tipoSeleccionado!;
      request.fields['categoria'] = _categoriaSeleccionada!;
      request.fields['nombre_examen'] = _nombreExamenSeleccionado ?? 'Sin especificar';
      request.fields['descripcion'] = _descripcionController.text;
      request.fields['fecha_realizacion'] = _fechaRealizacion.toIso8601String().split('T').first;

      if (widget.idusuariodoc != null) {
        request.fields['doctor'] = widget.idusuariodoc.toString();
      }

      // 🚀 Enviar la solicitud
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

      // 🧹 Borrar archivo temporal
      await archivoRenombrado.delete();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  void _verPdfPreview() {
    if (_pdfFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfPreviewScreen(file: _pdfFile!),
        ),
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
    final listaAMostrar = _usarRecortadas ? _imagenesRecortadas : _imagenes;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colores[0],
        title: const Text('Escanear Imagen',style: TextStyle(color:Colors.white),),
        actions: [
          Switch(
            value: _usarRecortadas,
            onChanged: (value) => setState(() => _usarRecortadas = value),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: Text('')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // VISUALIZACIÓN DE IMÁGENES O MENSAJE
              if (listaAMostrar.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: listaAMostrar.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Stack(
                          children: [
                            Material(
                              elevation: 6,
                              borderRadius: BorderRadius.circular(16),
                              shadowColor: Colors.grey.shade300,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  listaAMostrar[index],
                                  height: 180,
                                  width: 140,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  iconSize: 20,
                                  onPressed: () => setState(() {
                                    if (_usarRecortadas) {
                                      _imagenesRecortadas.removeAt(index);
                                    } else {
                                      _imagenes.removeAt(index);
                                    }
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.grey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_not_supported, size: 60, color: Colors.grey.shade400),
                          SizedBox(height: 12),
                          Text(
                            'No se han añadido imágenes.',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // CAMPOS DE FORMULARIO
              Card(

                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Dropdown tipo
                      DropdownButtonFormField<String>(
                        value: _tipoSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Tipo de documento',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        isExpanded: true,
                        items: tiposCategoriasExamenes.keys.map((tipo) {
                          return DropdownMenuItem<String>(
                            value: tipo,
                            child: Text(tipo.replaceAll('_', ' ').toUpperCase()),
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
                        onChanged: (nuevoTipo) {
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

                      // Dropdown categoría
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
                            child: Text(categoria.replaceAll('_', ' ').toUpperCase()),
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
                        onChanged: (nuevaCategoria) {
                          setState(() {
                            _categoriaSeleccionada = nuevaCategoria;
                            _nombreExamenSeleccionado = null;
                          });
                        },
                        validator: (value) => value == null ? 'Selecciona una categoría' : null,
                      ),

                      const SizedBox(height: 16),

                      // Dropdown examen
                      DropdownButtonFormField<String>(
                        value: _nombreExamenSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Imagenologia',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        isExpanded: true,
                        items: _obtenerExamenesDeCategoria().map((examen) {
                          return DropdownMenuItem<String>(
                            value: examen['value'],
                            child: Text(examen['label'] ?? examen['value'] ?? ''),
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
                        onChanged: (nuevoExamen) {
                          setState(() {
                            _nombreExamenSeleccionado = nuevoExamen;
                          });
                        },
                        validator: (value) => value == null ? 'Selecciona un examen' : null,
                      ),

                      const SizedBox(height: 20),

                      // Descripción
                      TextField(
                        controller: _descripcionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción (opcional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),

                      // Fecha
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha de realización',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
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

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // BOTONES
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Agregar imagen'),
                    onPressed: _pickAndCropImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colores[1],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Crear PDF'),
                    onPressed: _saveAsPdf,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colores[2],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Subir PDF'),
                    onPressed: _pdfFile != null ? _uploadPdf : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pdfFile != null ? colores[4] : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (_pdfFile != null)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ver PDF'),
                      onPressed: _verPdfPreview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colores[3],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class PdfPreviewScreen extends StatelessWidget {
  final File file;

  const PdfPreviewScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista previa PDF'),
      ),
      body: PdfPreview(
        build: (format) => file.readAsBytesSync(),
      ),
    );
  }
}
