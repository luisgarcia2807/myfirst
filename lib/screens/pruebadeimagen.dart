import 'dart:typed_data';
import 'dart:io' as io; // Se ignora en web

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SubirImagenPage extends StatefulWidget {
  @override
  _SubirImagenPageState createState() => _SubirImagenPageState();
}

class _SubirImagenPageState extends State<SubirImagenPage> {
  final ImagePicker picker = ImagePicker();
  io.File? _imagenFile;
  Uint8List? _imagenEnBytes;
  XFile? _archivoSeleccionado;
  String _mensaje = '';

  Future<void> _seleccionarImagen() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imagenEnBytes = bytes;
          _archivoSeleccionado = pickedFile;
        });
      } else {
        setState(() {
          _imagenFile = io.File(pickedFile.path);
          _archivoSeleccionado = pickedFile;
        });
      }
    }
  }

  Future<void> _subirImagen() async {
    if (_archivoSeleccionado == null) {
      setState(() {
        _mensaje = 'Selecciona una imagen primero';
      });
      return;
    }

    var uri = Uri.parse('http://127.0.0.1:8000/usuarios/api/subir-imagen/'); // usa tu IP local
    var request = http.MultipartRequest('POST', uri);
    request.fields['nombre'] = 'Mi imagen desde Flutter';

    request.files.add(
      http.MultipartFile.fromBytes(
        'imagen',
        await _archivoSeleccionado!.readAsBytes(),
        filename: _archivoSeleccionado!.name,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 201) {
      setState(() {
        _mensaje = 'Imagen subida correctamente';
      });
    } else {
      setState(() {
        _mensaje = 'Error al subir la imagen';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagenWidget = kIsWeb
        ? (_imagenEnBytes != null
        ? Image.memory(_imagenEnBytes!, width: 200)
        : Text('No hay imagen seleccionada'))
        : (_imagenFile != null
        ? Image.file(_imagenFile!, width: 200)
        : Text('No hay imagen seleccionada'));

    return Scaffold(
      appBar: AppBar(title: Text('Subir Imagen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _seleccionarImagen,
              child: Text('Seleccionar imagen'),
            ),
            SizedBox(height: 10),
            imagenWidget,
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _subirImagen,
              child: Text('Subir imagen'),
            ),
            SizedBox(height: 10),
            Text(_mensaje),
          ],
        ),
      ),
    );
  }
}

