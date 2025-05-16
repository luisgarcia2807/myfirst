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

// Import para crop_your_image:
import 'package:crop_your_image/crop_your_image.dart';

import '../constans.dart'; // Ajusta la ruta según tu proyecto

class ScanView extends StatefulWidget {
  final int idPaciente;
  const ScanView({super.key, required this.idPaciente});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  List<File> _imagenes = [];
  List<File> _imagenesRecortadas = []; // <-- Nueva lista para las imágenes recortadas originales
  List<Uint8List> imagenesOriginales = [];
  File? _pdfFile;
  bool _mejorarImagen = false;
  bool _usarRecortadas = false;




  final List<String> _opcionesExamen = [
    'Radiografía',
    'Análisis de sangre',
    'Ecografía',
    'Resonancia magnética',
    'Otro'
  ];
  String? _nombreExamenSeleccionado;
  final TextEditingController _descripcionController = TextEditingController();
  DateTime _fechaRealizacion = DateTime.now();
  final int pacienteId = 1; // Cambia por el ID real del paciente

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

    _imageBytesToCrop = await picked.readAsBytes();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 300,
                  height: 400,
                  child: Crop(
                    image: _imageBytesToCrop!,
                    controller: _cropController,
                    onCropped: (croppedData) async {
                      try {
                        final tempDir = await getTemporaryDirectory();

                        // 1. Guardar la imagen recortada (como "original" desde tu punto de vista)
                        final croppedPath = '${tempDir.path}/original_recortada_${DateTime.now().millisecondsSinceEpoch}.jpg';
                        final croppedFile = await File(croppedPath).writeAsBytes(croppedData);

                        if (mounted) {
                          setState(() => _imagenesRecortadas.add(croppedFile)); // Guardar recortada como "original"
                        }

                        // 2. Procesar la imagen recortada
                        Uint8List? imagenProcesadaBytes = await ProcesadorDeDocumento.procesar(croppedFile);

                        if (imagenProcesadaBytes == null) {
                          throw Exception('Error al procesar imagen');
                        }

                        // 3. Guardar la imagen procesada
                        final processedPath = '${tempDir.path}/procesada_${DateTime.now().millisecondsSinceEpoch}.jpg';
                        File processedFile = await File(processedPath).writeAsBytes(imagenProcesadaBytes);

                        // 4. Mejora adicional si se habilitó
                        if (_mejorarImagen) {
                          final original = img.decodeImage(imagenProcesadaBytes);
                          if (original != null) {
                            final mejorada = img.adjustColor(
                              original,
                              contrast: 1.2,
                              brightness: 0.1,
                            );
                            processedFile = File(processedPath)
                              ..writeAsBytesSync(img.encodeJpg(mejorada));
                          }
                        }

                        if (mounted) {
                          setState(() => _imagenes.add(processedFile)); // Guardar la imagen procesada
                          Navigator.of(context).pop(); // Cierra el diálogo
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al procesar imagen: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cancelar recorte
                      },
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _cropController.crop(); // Inicia recorte
                        });
                      },
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
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


  Future<void> _subirPdfAlServidor(File archivo) async {
    try {
      final uri = Uri.parse('$baseUrl/usuarios/api/examenes/');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath('archivo', archivo.path));
      request.fields['paciente'] = widget.idPaciente.toString();
      request.fields['nombre_examen'] = _nombreExamenSeleccionado ?? 'Sin especificar';
      request.fields['descripcion'] = _descripcionController.text;
      request.fields['fecha_realizacion'] = _fechaRealizacion.toIso8601String().split('T').first;

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF subido correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir el PDF: ${response.statusCode}')),
        );
      }
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
        title: const Text('Escanear y Subir PDF'),
        actions: [
          Switch(
            value: _mejorarImagen,
            onChanged: (value) => setState(() => _mejorarImagen = value),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: Text('Mejorar imágenes')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [

              if (listaAMostrar.isNotEmpty)
          SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: listaAMostrar.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.file(listaAMostrar[index]),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => setState(() {
                        if (_usarRecortadas) {
                          _imagenesRecortadas.removeAt(index);
                        } else {
                          _imagenes.removeAt(index);
                        }
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        )
          else
          const Padding(
          padding: EdgeInsets.all(20),
      child: Text('No se han añadido imágenes.'),
    ),

    DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipo de examen'),
                value: _nombreExamenSeleccionado,
                items: _opcionesExamen.map((String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _nombreExamenSeleccionado = newValue;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Fecha: ${_fechaRealizacion.toLocal().toString().split(' ')[0]}'),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
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
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Agregar imagen'),
                onPressed: _pickAndCropImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colores[1],
                ),
              ),
              SwitchListTile(
                title: const Text('Usar imágenes recortadas'),
                value: _usarRecortadas,
                onChanged: (value) {
                  setState(() {
                    _usarRecortadas = value;
                  });
                },
              ),

              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Crear PDF'),
                onPressed: _saveAsPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colores[2],
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Subir PDF'),
                onPressed: _pdfFile != null ? _uploadPdf : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colores[4],
                ),
              ),

              const SizedBox(height: 10),

              if (_pdfFile != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('Ver PDF'),
                  onPressed: _verPdfPreview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colores[3],
                  ),
                ),

              const SizedBox(height: 10),

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
