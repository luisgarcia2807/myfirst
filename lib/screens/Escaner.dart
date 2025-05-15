import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../constans.dart'; // Asegúrate de que esta ruta sea correcta

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  List<File> _imagenes = [];
  File? _pdfFile;
  bool _mejorarImagen = false;

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
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatioPresets: [CropAspectRatioPreset.original],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar imagen',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
        ],
      );
      if (cropped != null) {
        File finalImage = File(cropped.path);

        if (_mejorarImagen) {
          final img.Image? original = img.decodeImage(await finalImage.readAsBytes());
          if (original != null) {
            final mejorada = img.adjustColor(original, contrast: 1.2, brightness: 0.1);
            final tempPath = '${(await getTemporaryDirectory()).path}/mejorada_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final nuevaImagen = File(tempPath)..writeAsBytesSync(img.encodeJpg(mejorada));
            finalImage = nuevaImagen;
          }
        }

        setState(() => _imagenes.add(finalImage));
      }
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
      final uri = Uri.parse('$baseUrl/usuarios/api/subir-pdf/');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath('archivo', archivo.path));
      request.fields['nombre'] = 'documento_${DateTime.now().millisecondsSinceEpoch}';

      final response = await request.send();

      if (response.statusCode == 200) {
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
    return Scaffold(
      appBar: AppBar(
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _imagenes.isNotEmpty
              ? SizedBox(
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
                        onPressed: () {
                          setState(() => _imagenes.removeAt(index));
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          )
              : const Padding(
            padding: EdgeInsets.all(20),
            child: Text('No se han añadido imágenes.'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Agregar imagen'),
            onPressed: _pickAndCropImage,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Guardar y subir PDF'),
            onPressed: _saveAsPdf,
          ),
          const SizedBox(height: 10),
          if (_pdfFile != null)
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Ver PDF generado'),
              onPressed: _verPdfPreview,
            ),
        ],
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
      appBar: AppBar(title: const Text("Vista previa del PDF")),
      body: PdfPreview(
        build: (format) => file.readAsBytes(),
      ),
    );
  }
}
