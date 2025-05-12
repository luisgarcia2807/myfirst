import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../constans.dart';

class CambiarFotoScreen extends StatefulWidget {
  final int idusuario;
  const CambiarFotoScreen({super.key, required this.idusuario});

  @override
  State<CambiarFotoScreen> createState() => _CambiarFotoScreenState();
}

class _CambiarFotoScreenState extends State<CambiarFotoScreen> {
  File? _imagen;
  final picker = ImagePicker();
  bool _subiendo = false;

  Future<void> _seleccionarImagen() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagen = File(pickedFile.path);
      });
    }
  }

  Future<void> _subirImagen() async {
    if (_imagen == null) return;

    setState(() {
      _subiendo = true;
    });

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/usuarios/api/usuarios/1/actualizar-foto/'),
    );
    request.files.add(await http.MultipartFile.fromPath('foto_perfil', _imagen!.path));

    var response = await request.send();

    setState(() {
      _subiendo = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto actualizada con éxito')));
      Navigator.pop(context); // Volver a la pantalla anterior
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir la foto')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar Foto de Perfil'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _imagen == null
                ? Text('No has seleccionado ninguna imagen.')
                : Image.file(_imagen!, height: 200),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _seleccionarImagen,
              icon: Icon(Icons.photo_library),
              label: Text('Seleccionar imagen'),
            ),
            SizedBox(height: 20),
            _subiendo
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: _subirImagen,
              icon: Icon(Icons.upload),
              label: Text('Subir imagen'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }
}
