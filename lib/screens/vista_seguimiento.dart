import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mifirst/screens/convertir%20pdf.dart';
import 'dart:io';

import '../constans.dart';

class SeguimientoPage extends StatefulWidget {
  final int idPaciente;
  final int idtratamiento;
  const SeguimientoPage({super.key, required this.idPaciente, required this.idtratamiento});
  @override
  _SeguimientoPageState createState() => _SeguimientoPageState();
}

class _SeguimientoPageState extends State<SeguimientoPage> {
  File? archivoPDF;


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

  Future<void> subirPDF() async {
    if (_descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El comentario es obligatorio')),
      );
      return;
    }

    try {
      final uri = Uri.parse('$baseUrl/usuarios/api/tratamiento/seguimiento/nuevo/');
      final request = http.MultipartRequest('POST', uri);

      request.fields['tratamiento'] = widget.idtratamiento.toString();
      request.fields['comentario'] = _descripcionController.text;

      if (archivoPDF != null) {
        // Verificar que sea un archivo PDF
        if (!archivoPDF!.path.toLowerCase().endsWith('.pdf')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solo se permiten archivos PDF')),
          );
          return;
        }

        request.files.add(
          await http.MultipartFile.fromPath('archivo', archivoPDF!.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seguimiento enviado correctamente')),
        );
        _descripcionController.clear();
        setState(() {
          archivoPDF = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar seguimiento: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error: $e')),
      );
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> seleccionarDesdeGaleria() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imagen = File(pickedFile.path);
      File pdfConvertido = await convertirImagenAPDF(imagen);
      setState(() {
        archivoPDF = pdfConvertido;
      });
    }
  }

  Future<void> tomarFoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File imagen = File(pickedFile.path);
      File pdfConvertido = await convertirImagenAPDF(imagen);
      setState(() {
        archivoPDF = pdfConvertido;
      });
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
          title: Text("Seguimiento",style: TextStyle(color:Colors.white),)),
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
                        TextField(
                          controller: _descripcionController,
                          decoration: InputDecoration(
                            labelText: 'Comentario ',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),

                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                      builder: (_) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.picture_as_pdf),
                              title: Text('Seleccionar archivo PDF'),
                              onTap: () {
                                Navigator.pop(context);
                                seleccionarPDF();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo),
                              title: Text('Seleccionar imagen de galería'),
                              onTap: () {
                                Navigator.pop(context);
                                seleccionarDesdeGaleria();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text('Tomar foto'),
                              onTap: () {
                                Navigator.pop(context);
                                tomarFoto();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.attach_file),
                  label: Text("Seleccionar archivo"),
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


