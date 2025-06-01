import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class SubirArchivoPagesupa extends StatefulWidget {
  @override
  _SubirArchivoPagesupaState createState() => _SubirArchivoPagesupaState();
}

class _SubirArchivoPagesupaState extends State<SubirArchivoPagesupa> {
  String? _urlArchivo;
  bool _subiendo = false;

  Future<void> _seleccionarYSubirArchivo() async {
    // Abrir selector de archivos (puede ser imagen o PDF)
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _subiendo = true;
        _urlArchivo = null;
      });

      final fileBytes = result.files.single.bytes;
      final fileName = result.files.single.name;

      // Si fileBytes es null, lee desde el path
      final filePath = result.files.single.path;

      var uri = Uri.parse('http://192.168.0.105:8000/usuarios/api/subir-archivosupa/');

      var request = http.MultipartRequest('POST', uri);
      if (fileBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('archivo', fileBytes, filename: fileName));
      } else if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('archivo', filePath));
      } else {
        setState(() {
          _subiendo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al leer el archivo')));
        return;
      }

      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          setState(() {
            _urlArchivo = respStr; // aquí puedes parsear el JSON para obtener la URL limpia
            _subiendo = false;
          });
        } else {
          setState(() {
            _subiendo = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir archivo: ${response.statusCode}')));
        }
      } catch (e) {
        setState(() {
          _subiendo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Subir archivo a Supabase')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _subiendo ? null : _seleccionarYSubirArchivo,
                child: Text(_subiendo ? 'Subiendo...' : 'Seleccionar y subir archivo'),
              ),
              SizedBox(height: 20),
              if (_urlArchivo != null)
                SelectableText(
                  'Respuesta:\n$_urlArchivo',
                  style: TextStyle(fontSize: 14),
                ),
            ],
          ),
        ));
  }
}
