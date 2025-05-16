import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mifirst/constans.dart';
import 'package:path/path.dart';

class ProcesadorDeDocumento {
  static Future<Uint8List?> procesar(File imagen) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/api/procesar_documento/');
      final request = http.MultipartRequest('POST', url);

      final bytes = await imagen.readAsBytes();

      request.files.add(http.MultipartFile.fromBytes(
        'imagen',
        bytes,
        filename: basename(imagen.path),
        contentType: MediaType('image', 'jpeg'),
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        final responseBytes = await response.stream.toBytes();

        if (contentType != null && contentType.startsWith('image/')) {
          return responseBytes;
        } else {
          print("Respuesta no es imagen. Content-Type: $contentType");
          return null;
        }
      } else {
        print("Error al procesar imagen: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error procesando imagen: $e");
      return null;
    }
  }
}
