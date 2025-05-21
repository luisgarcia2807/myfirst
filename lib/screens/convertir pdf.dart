import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

Future<File> convertirImagenAPDF(File imagen) async {
  final pdf = pw.Document();
  final image = pw.MemoryImage(imagen.readAsBytesSync());

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(image),
        );
      },
    ),
  );

  final outputDir = await getTemporaryDirectory();
  final pdfFile = File("${outputDir.path}/temp.pdf");
  await pdfFile.writeAsBytes(await pdf.save());

  return pdfFile;
}
