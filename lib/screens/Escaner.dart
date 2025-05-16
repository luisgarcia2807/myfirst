import 'dart:io';
import 'dart:typed_data';  // Para Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  List<File> _imagenes = [];
  File? _pdfFile;
  bool _mejorarImagen = false;

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
    if (picked != null) {
      _imageBytesToCrop = await picked.readAsBytes();

      // Mostrar diálogo para recortar la imagen
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 300,
            height: 400,
            child: Crop(
              image: _imageBytesToCrop!,
              controller: _cropController,
              onCropped: (croppedData) async {
                Navigator.of(context).pop();

                final tempDir = await getTemporaryDirectory();
                final path =
                    '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
                File finalImage = await File(path).writeAsBytes(croppedData);

                if (_mejorarImagen) {
                  final img.Image? original =
                  img.decodeImage(await finalImage.readAsBytes());
                  if (original != null) {
                    final mejorada =
                    img.adjustColor(original, contrast: 1.2, brightness: 0.1);
                    final mejoradaPath =
                        '${tempDir.path}/mejorada_${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final nuevaImagen =
                    File(mejoradaPath)..writeAsBytesSync(img.encodeJpg(mejorada));
                    finalImage = nuevaImagen;
                  }
                }

                setState(() => _imagenes.add(finalImage));
              },
              fixArea: true,
              aspectRatio: 1.0,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _saveAsPdf() async {
    if (_imagenes.isEmpty) return;

    final pdf = pw.Document();

    for (File imagen in _imagenes) {
      final image = pw.MemoryImage(imagen.readAsBytesSync());
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ),
      );
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/documento_escaneado_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    setState(() => _pdfFile = file);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF creado. Subiendo...')),
    );

    await _subirPdfAlServidor(file);
  }

  Future<void> _subirPdfAlServidor(File archivo) async {
    try {
      final uri = Uri.parse('$baseUrl/usuarios/api/examenes/');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath('archivo', archivo.path));
      request.fields['paciente'] = pacienteId.toString();
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
              if (_imagenes.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagenes.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.file(_imagenes[index]),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => setState(() => _imagenes.removeAt(index)),
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
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Crear y Subir PDF'),
                onPressed: _saveAsPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colores[2],
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
