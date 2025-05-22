import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

import '../constans.dart';
import '../models/verseguimiento.dart';

class SeguimientoListPage extends StatefulWidget {
  final int tratamientoId;

  const SeguimientoListPage({super.key, required this.tratamientoId});

  @override
  State<SeguimientoListPage> createState() => _SeguimientoListPageState();
}

class _SeguimientoListPageState extends State<SeguimientoListPage> {
  late Future<List<Seguimiento>> seguimientos;

  Future<List<Seguimiento>> fetchSeguimientos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/api/tratamiento/${widget.tratamientoId}/seguimientos'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Seguimiento.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar seguimientos');
    }
  }

  @override
  void initState() {
    super.initState();
    seguimientos = fetchSeguimientos();
  }

  /// Función para descargar y abrir el PDF
  Future<void> _abrirPDF(String archivo) async {
    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${archivo.split('/').last}';

      // Descarga el archivo desde el servidor
      await dio.download('$baseUrl$archivo', filePath);

      // Abre el archivo PDF
      await OpenFilex.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir el PDF: $e')),
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
        title: const Text("Ver Seguimientos"),
        backgroundColor: colores[0],
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder<List<Seguimiento>>(
        future: seguimientos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(child: Text("No hay seguimientos disponibles"));
          }

          return ListView.builder(
            itemCount: data.length,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemBuilder: (context, index) {
              final seguimiento = data[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ícono de PDF a la izquierda
                      seguimiento.archivo != null && seguimiento.archivo.trim().isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
                        onPressed: () => _abrirPDF(seguimiento.archivo),
                      )
                          : Column(
                        children: const [
                          Icon(Icons.picture_as_pdf, color: Colors.grey, size: 30),
                          SizedBox(height: 4),
                          Text(
                            'Sin PDF',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(width: 16),

                      // Contenido principal
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Fecha: ${seguimiento.fecha}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Observación",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,

                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              seguimiento.comentario,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
