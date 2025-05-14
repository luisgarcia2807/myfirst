import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
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
      Uri.parse('$baseUrl/usuarios/api/usuarios/${widget.idusuario}/actualizar-foto/'),
    );
    request.files.add(await http.MultipartFile.fromPath('foto_perfil', _imagen!.path));

    var response = await request.send();

    setState(() {
      _subiendo = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto actualizada con éxito')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir la foto')));
    }
  }

  void _eliminarImagen() {
    setState(() {
      _imagen = null;
    });
  }

  void _recortarImagen() {
    // Aquí puedes implementar la lógica de recorte si usas una librería como image_cropper
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Función de recorte no implementada')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar Foto de Perfil'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _seleccionarImagen,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: Radius.circular(12),
                  dashPattern: [8, 4],
                  color: Colors.indigo,
                  strokeWidth: 2,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.indigo.withOpacity(0.05),
                    ),
                    child: _imagen == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 50, color: Color.fromARGB(255, 113, 134, 255)),
                        SizedBox(height: 8),
                        Text(
                          'Agregar Foto',
                          style: TextStyle(color: Colors.indigo, fontSize: 16),
                        ),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _imagen!,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // Botones recortar y eliminar
              if (_imagen != null) ...[
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.indigo,
                      child: IconButton(
                        icon: Icon(Icons.crop, color: Colors.white, size: 20),
                        onPressed: _recortarImagen,
                        tooltip: 'Recortar imagen',
                      ),
                    ),
                    SizedBox(width: 20),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.redAccent,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white, size: 20),
                        onPressed: _eliminarImagen,
                        tooltip: 'Eliminar imagen',
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 30),
              _subiendo
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: _subirImagen,
                icon: Icon(Icons.upload, color: Colors.black),
                label: Text(
                  'Subir imagen',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}