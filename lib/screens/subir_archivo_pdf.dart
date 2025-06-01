import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../constans.dart';

class SubirPDFPage extends StatefulWidget {
  final int idPaciente;
  const SubirPDFPage({super.key, required this.idPaciente});
  @override
  _SubirPDFPageState createState() => _SubirPDFPageState();
}

class _SubirPDFPageState extends State<SubirPDFPage> {
  File? archivoPDF;
  final Map<String, Map<String, List<Map<String, String>>>> tiposCategoriasExamenes = {
    'laboratorio': {
      'hematologia': [
        {'value': 'hemograma_completo', 'label': 'Hemograma Completo'},
        {'value': 'recuento_plaquetas', 'label': 'Recuento de Plaquetas'},
        {'value': 'velocidad_sedimentacion', 'label': 'Velocidad de Sedimentación'},
        {'value': 'grupo_sanguineo', 'label': 'Grupo Sanguíneo y Rh'},
      ],
      'bioquimica': [
        {'value': 'glucosa', 'label': 'Glucosa'},
        {'value': 'urea', 'label': 'Urea'},
        {'value': 'creatinina', 'label': 'Creatinina'},
        {'value': 'colesterol_total', 'label': 'Colesterol Total'},
        {'value': 'hdl', 'label': 'HDL'},
        {'value': 'ldl', 'label': 'LDL'},
        {'value': 'trigliceridos', 'label': 'Triglicéridos'},
        {'value': 'acido_urico', 'label': 'Ácido Úrico'},
        {'value': 'tgo', 'label': 'TGO (AST)'},
        {'value': 'tgp', 'label': 'TGP (ALT)'},
        {'value': 'bilirrubina_total', 'label': 'Bilirrubina Total'},
        {'value': 'bilirrubina_directa', 'label': 'Bilirrubina Directa'},
        {'value': 'bilirrubina_indirecta', 'label': 'Bilirrubina Indirecta'},
        {'value': 'fosfatasa_alcalina', 'label': 'Fosfatasa Alcalina'},
        {'value': 'ggt', 'label': 'GGT'},
        {'value': 'amilasa', 'label': 'Amilasa'},
        {'value': 'lipasa', 'label': 'Lipasa'},
        {'value': 'electrolitos', 'label': 'Electrolitos (Na, K, Cl)'},
        {'value': 'calcio', 'label': 'Calcio'},
        {'value': 'magnesio', 'label': 'Magnesio'},
        {'value': 'perfil_renal', 'label': 'Perfil Renal'},
        {'value': 'perfil_hepatico', 'label': 'Perfil Hepático'},
        {'value': 'perfil_lipidico', 'label': 'Perfil Lipídico'},
        {'value': 'perfil_20', 'label': 'Perfil 20'},
        {'value': 'perfil_21', 'label': 'Perfil 21'},
      ],
      'orina_y_heces': [
        {'value': 'orina_rutina', 'label': 'Orina (Examen de Rutina)'},
        {'value': 'urocultivo', 'label': 'Urocultivo'},
        {'value': 'coprologico', 'label': 'Coprológico'},
        {'value': 'parasitologico', 'label': 'Parasitológico'},
        {'value': 'sangre_oculta', 'label': 'Sangre Oculta en Heces'},
      ],
      'inmunologia': [
        {'value': 'vih', 'label': 'Prueba de VIH'},
        {'value': 'vdrl', 'label': 'VDRL'},
        {'value': 'hbsag', 'label': 'HBsAg (Hepatitis B)'},
        {'value': 'anticore', 'label': 'Anti-HBc'},
        {'value': 'anti_hcv', 'label': 'Anti-HCV'},
        {'value': 'toxoplasmosis', 'label': 'Toxoplasmosis (IgG, IgM)'},
        {'value': 'rubeola', 'label': 'Rubéola (IgG, IgM)'},
        {'value': 'citomegalovirus', 'label': 'Citomegalovirus (IgG, IgM)'},
        {'value': 'fiebre_tifoidea', 'label': 'Prueba de Widal'},
      ],
    },
    'pruebas_funcionales': {
      'espirometria': [
        {'value': 'espirometria_simple', 'label': 'Espirometría Simple'},
        {'value': 'espirometria_con_broncodilatador', 'label': 'Espirometría con Broncodilatador'},
      ],
      'prueba_esfuerzo': [
        {'value': 'prueba_esfuerzo_estandar', 'label': 'Prueba de Esfuerzo Estándar'},
      ],
    },
    'cardiologia': {
      'electrocardiograma': [
        {'value': 'ecg_reposo', 'label': 'Electrocardiograma en Reposo'},
      ],
      'ecocardiograma': [
        {'value': 'eco_transtoracico', 'label': 'Ecocardiograma Transtorácico'},
        {'value': 'eco_doppler', 'label': 'Ecocardiograma Doppler'},
      ],
      'holter': [
        {'value': 'holter_24h', 'label': 'Holter 24h'},
        {'value': 'holter_48h', 'label': 'Holter 48h'},
      ],
    },
    'neurologia': {
      'encefalograma': [
        {'value': 'eeg', 'label': 'Electroencefalograma'},
      ],
      'potenciales_evocados': [
        {'value': 'potenciales_auditivos', 'label': 'Potenciales Auditivos'},
        {'value': 'potenciales_visuales', 'label': 'Potenciales Visuales'},
      ],
    },
    'informes_medicos': {
      'interconsultas': [
        {'value': 'interconsulta_cardiologia', 'label': 'Interconsulta de Cardiología'},
        {'value': 'interconsulta_neurologia', 'label': 'Interconsulta de Neurología'},
      ],
      'resumenes_clinicos': [
        {'value': 'epicrisis', 'label': 'Epicrisis'},
        {'value': 'informe_alta', 'label': 'Informe de Alta'},
      ],
      'referencias': [
        {'value': 'referencia_hospitalaria', 'label': 'Referencia Hospitalaria'},
      ],
    },
    'otros_documentos': {
      'otros': [
        {'value': 'consentimiento_informado', 'label': 'Consentimiento Informado'},
        {'value': 'historia_medica', 'label': 'Historia Médica'},
      ],
      'sin_categoria': [
        {'value': 'no_clasificado', 'label': 'Documento No Clasificado'},
      ],
    },
  };
  String? _tipoSeleccionado;
  String? _categoriaSeleccionada;
  List<String> _categoriasFiltradas = [];

  void _actualizarCategorias() {
    if (_tipoSeleccionado != null) {
      final categoriasMap = tiposCategoriasExamenes[_tipoSeleccionado];
      if (categoriasMap != null) {
        _categoriasFiltradas = categoriasMap.keys.toList();
      } else {
        _categoriasFiltradas = [];
      }
    }
  }

  List<Map<String, String>> _obtenerExamenesDeCategoria() {
    if (_tipoSeleccionado != null && _categoriaSeleccionada != null) {
      final categoria = tiposCategoriasExamenes[_tipoSeleccionado]?[_categoriaSeleccionada];
      if (categoria != null) {
        return categoria;
      }
    }
    return [];
  }

  String? _nombreExamenSeleccionado;
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
    if (archivoPDF == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un archivo PDF primero')),
      );
      return;
    }

    // Verificar que sea un archivo PDF
    if (!archivoPDF!.path.toLowerCase().endsWith('.pdf')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo se permiten archivos PDF')),
      );
      return;
    }

    try {
      final uri = Uri.parse('$baseUrl/usuarios/api/examenes/');
      final request = http.MultipartRequest('POST', uri);

      // Campos del formulario
      request.fields['paciente'] = widget.idPaciente.toString();
      request.fields['tipo'] = _tipoSeleccionado!;
      request.fields['categoria'] = _categoriaSeleccionada!;
      request.fields['nombre_examen'] = _nombreExamenSeleccionado ?? 'Sin especificar';
      request.fields['descripcion'] = _descripcionController.text;
      request.fields['fecha_realizacion'] = _fechaRealizacion.toIso8601String().split('T').first;
      print('archivoPDF: ${archivoPDF?.path}');
      print('paciente: ${widget.idPaciente}');
      print('tipo: $_tipoSeleccionado');
      print('categoria: $_categoriaSeleccionada');
      print('nombre_examen: $_nombreExamenSeleccionado');
      print('descripcion: ${_descripcionController.text}');
      print('fecha_realizacion: ${_fechaRealizacion.toIso8601String().split('T').first}');
      print( archivoPDF!.path);
      // Archivo adjunto
      request.files.add(
        await http.MultipartFile.fromPath('archivo', archivoPDF!.path),
      );

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
        SnackBar(content: Text('Ocurrió un error: $e')),
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
          title: Text("Cargar Examen",style: TextStyle(color:Colors.white),)),
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
                        DropdownButtonFormField<String>(
                          value: _tipoSeleccionado,
                          decoration: InputDecoration(
                            labelText: 'Tipo de documento',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          isExpanded: true, // MUY IMPORTANTE para evitar desbordamiento horizontal
                          items: tiposCategoriasExamenes.keys.map((tipo) {
                            return DropdownMenuItem<String>(
                              value: tipo,
                              child: Text(
                                tipo.replaceAll('_', ' ').toUpperCase(),
                                overflow: TextOverflow.visible, // En el menú desplegable se ve completo
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (BuildContext context) {
                            return tiposCategoriasExamenes.keys.map((tipo) {
                              final texto = tipo.replaceAll('_', ' ').toUpperCase();
                              return Tooltip(
                                message: texto,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    texto,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (String? nuevoTipo) {
                            setState(() {
                              _tipoSeleccionado = nuevoTipo;
                              _categoriaSeleccionada = null;
                              _nombreExamenSeleccionado = null;
                              _categoriasFiltradas = tiposCategoriasExamenes[nuevoTipo]?.keys.toList() ?? [];
                            });
                          },
                          validator: (value) => value == null ? 'Selecciona un tipo' : null,
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _categoriaSeleccionada,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          isExpanded: true,
                          items: _categoriasFiltradas.map((categoria) {
                            return DropdownMenuItem<String>(
                              value: categoria,
                              child: Text(
                                categoria.replaceAll('_', ' ').toUpperCase(),
                                overflow: TextOverflow.visible,
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (BuildContext context) {
                            return _categoriasFiltradas.map((categoria) {
                              final texto = categoria.replaceAll('_', ' ').toUpperCase();
                              return Tooltip(
                                message: texto,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    texto,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (String? nuevaCategoria) {
                            setState(() {
                              _categoriaSeleccionada = nuevaCategoria;
                              _nombreExamenSeleccionado = null;
                            });
                          },
                          validator: (value) => value == null ? 'Selecciona una categoría' : null,
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _nombreExamenSeleccionado,
                          decoration: InputDecoration(
                            labelText: 'Examen',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          isExpanded: true,
                          items: _obtenerExamenesDeCategoria().map((examen) {
                            return DropdownMenuItem<String>(
                              value: examen['value'],
                              child: Text(
                                examen['label'] ?? examen['value'] ?? '',
                                overflow: TextOverflow.visible,
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (BuildContext context) {
                            return _obtenerExamenesDeCategoria().map((examen) {
                              final texto = examen['label'] ?? examen['value'] ?? '';
                              return Tooltip(
                                message: texto,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    texto,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (String? nuevoExamen) {
                            setState(() {
                              _nombreExamenSeleccionado = nuevoExamen;
                            });
                          },
                          validator: (value) => value == null ? 'Selecciona un examen' : null,
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: _descripcionController,
                          decoration: InputDecoration(
                            labelText: 'Descripción (opcional)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),

                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Fecha de realización',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today, color: Colors.blueAccent),
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
                          ),
                          child: Text(
                            _fechaRealizacion.toLocal().toString().split(' ')[0],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: seleccionarPDF,
                  icon: Icon(Icons.attach_file),
                  label: Text("Seleccionar archivo PDF"),
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
