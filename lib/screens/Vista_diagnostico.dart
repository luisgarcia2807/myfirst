import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constans.dart';
import '../models/enfermedadescomun.dart';
import '../models/enfermedadespersistente.dart';

class DiagnosticoView extends StatefulWidget {
  final String nombre;
  final String apellido;
  final int idPaciente;
  final int idusuariodoc;
  final int idConsulta;

  const DiagnosticoView({
    Key? key,
    required this.nombre,
    required this.apellido,
    required this.idPaciente,
    required this.idusuariodoc,
    required this.idConsulta,
  }) : super(key: key);

  @override
  _DiagnosticoViewState createState() => _DiagnosticoViewState();
}

class _DiagnosticoViewState extends State<DiagnosticoView> {
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _descripcionEnfermedadController = TextEditingController();
  final TextEditingController _descripcionEnfermdadcomunController = TextEditingController();
  List<String> enfermedadesDiagnosticadas = [];
  String? tipoSeleccionado= 'Endocrina';
  int? selectedEnfermedadPersistenteId;
  int? selectedEnfermedadescomunId;
  String? nombreEnfermedadSeleccionada;
  String? tipoSeleccionadocomun='respiratoria';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Diagnóstico Médico',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF1565C0),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Información del paciente
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0).withOpacity(0.1), Color(0xFF3F51B5).withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF1565C0).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: Color(0xFF1565C0),
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Paciente: ${widget.nombre} ${widget.apellido}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Sección principal de diagnóstico
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la sección
                    Row(
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          color: Color(0xFF1565C0),
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Diagnóstico Médico',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Campo de diagnóstico
                    TextField(
                      controller: _diagnosticoController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: 'Escriba el diagnóstico',
                        hintText: 'Describa los hallazgos y conclusiones del examen médico...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF1565C0), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Botón para agregar enfermedad
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _mostrarDialogoEnfermedades,
                        icon: Icon(Icons.add_circle_outline, color: Colors.white),
                        label: Text(
                          'Agregar Enfermedad Diagnosticada',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Botón para agregar enfermedad comun
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _mostrarDialogoEnfermedadescomun,
                        icon: Icon(Icons.add_circle_outline, color: Colors.white),
                        label: Text(
                          'Agregar Enfermedad diaria',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7E57C2),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Lista de enfermedades diagnosticadas
              if (enfermedadesDiagnosticadas.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.list_alt,
                            color: Color(0xFF4CAF50),
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Enfermedades Diagnosticadas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      ...enfermedadesDiagnosticadas.map((enfermedad) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  enfermedad,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              SizedBox(height: 30),

              // Botón de guardar diagnóstico
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardarDiagnostico,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1565C0),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Guardar Diagnóstico',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoEnfermedades() {
    Future<List<EnfermedadPersistente>> futureEnfermedadesPersistente = fetchEnfermedadesPersistente(tipoSeleccionado ?? 'Endocrina');
    final TextEditingController _fechaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Row(
                children: [
                  Icon(Icons.medical_information, color: Color(0xFF1565C0)),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      "Diagnosticar Enfermedad",
                      overflow: TextOverflow.ellipsis, // para cortar si es necesario
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tipo de enfermedad
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: tipoSeleccionado,
                          onChanged: (String? newValue) {
                            setState(() {
                              tipoSeleccionado = newValue;
                              futureEnfermedadesPersistente = fetchEnfermedadesPersistente(newValue!);
                              selectedEnfermedadPersistenteId = null;
                              nombreEnfermedadSeleccionada = null;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Tipo de enfermedad",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          items: ['Endocrina', 'Cardiovascular', 'Respiratoria', 'Neurologica', 'Psiquiatrica', 'Gastrointestinal', 'Reumatologica', 'Renal', 'Hematologica', 'Infectologia']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

                      // Lista de enfermedades según tipo
                      FutureBuilder<List<EnfermedadPersistente>>(
                        future: futureEnfermedadesPersistente,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No hay enfermedades disponibles');
                          } else {
                            List<EnfermedadPersistente> enfermedades = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: DropdownButtonFormField<int>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Enfermedad a diagnosticar',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                value: selectedEnfermedadPersistenteId,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedEnfermedadPersistenteId = newValue;
                                    // Obtener el nombre de la enfermedad seleccionada
                                    if (newValue != null) {
                                      nombreEnfermedadSeleccionada = enfermedades
                                          .firstWhere((e) => e.id == newValue)
                                          .nombre;
                                    } else {
                                      nombreEnfermedadSeleccionada = null;
                                    }
                                  });
                                },
                                selectedItemBuilder: (BuildContext context) {
                                  return enfermedades.map((e) {
                                    return Text(
                                      e.nombre,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    );
                                  }).toList();
                                },
                                items: enfermedades.map((e) {
                                  return DropdownMenuItem<int>(
                                    value: e.id,
                                    child: Text(e.nombre),
                                  );
                                }).toList(),
                              ),
                            );
                          }
                        },
                      ),

                      // Fecha de diagnóstico
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _fechaController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Fecha de diagnóstico',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _fechaController.text = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                        ),
                      ),

                      // Descripción/Observaciones
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _descripcionEnfermedadController,
                          decoration: InputDecoration(
                            labelText: "Observaciones del diagnóstico",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedEnfermedadPersistenteId != null && _fechaController.text.isNotEmpty) {
                      await _guardarEnfermedadDiagnosticada(_fechaController.text);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Completa todos los campos obligatorios")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                  child: Text("Diagnosticar", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _mostrarDialogoEnfermedadescomun() {
    Future<List<EnfermedadComun>> futureEnfermedadComun = fetchEnfermedadComun(tipoSeleccionadocomun ?? 'respiratoria');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Row(
                children: [
                  Icon(Icons.medical_information, color: Color(0xFF1565C0)),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      "Añadir Enfermedad Común",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tipo de enfermedad
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: tipoSeleccionadocomun,
                          onChanged: (String? newValue) {
                            setState(() {
                              tipoSeleccionadocomun = newValue;
                              futureEnfermedadComun = fetchEnfermedadComun(newValue!);
                              selectedEnfermedadescomunId = null;
                              nombreEnfermedadSeleccionada = null;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Tipo de Enfermedad común",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          items: ['respiratoria', 'viral', 'bacterial', 'digestiva', 'dermatológica', 'otros']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

                      // Lista de enfermedades según tipo
                      FutureBuilder<List<EnfermedadComun>>(
                        future: futureEnfermedadComun,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No hay enfermedades comunes disponibles');
                          } else {
                            List<EnfermedadComun> enfermedades = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: DropdownButtonFormField<int>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Enfermedad Común',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                value: selectedEnfermedadescomunId,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedEnfermedadescomunId = newValue;
                                    // Obtener el nombre de la enfermedad seleccionada
                                    if (newValue != null) {
                                      nombreEnfermedadSeleccionada = enfermedades
                                          .firstWhere((e) => e.id == newValue)
                                          .nombre;
                                    } else {
                                      nombreEnfermedadSeleccionada = null;
                                    }
                                  });
                                },
                                selectedItemBuilder: (BuildContext context) {
                                  return enfermedades.map((e) {
                                    return Text(
                                      e.nombre,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    );
                                  }).toList();
                                },
                                items: enfermedades.map((e) {
                                  return DropdownMenuItem<int>(
                                    value: e.id,
                                    child: Text(e.nombre),
                                  );
                                }).toList(),
                              ),
                            );
                          }
                        },
                      ),

                      // Descripción/Observaciones
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _descripcionEnfermdadcomunController,
                          decoration: InputDecoration(
                            labelText: "Observaciones",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedEnfermedadescomunId != null) {
                      final url = Uri.parse('$baseUrl/usuarios/api/paciente-enfermedad-comun/');
                      final Map<String, dynamic> data = {
                        'paciente': widget.idPaciente,
                        'enfermedad_id': selectedEnfermedadescomunId,
                        'observacion': _descripcionEnfermdadcomunController.text,
                        'aprobado': true,
                        "doctor_aprobador": widget.idusuariodoc,
                      };


                      try {
                        final response = await http.post(
                          url,
                          headers: {"Content-Type": "application/json"},
                          body: json.encode(data),
                        );

                        if (response.statusCode == 201) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Enfermedad común guardada correctamente")),
                          );
                          enfermedadesDiagnosticadas.add(nombreEnfermedadSeleccionada!);
                          // Agregar al texto del diagnóstico
                          String textoActual = _diagnosticoController.text;
                          String nuevoTexto = textoActual.isEmpty
                              ? "paciente actualmente $nombreEnfermedadSeleccionada"
                              : "$textoActual\n\nDiagnosticado con: $nombreEnfermedadSeleccionada";
                          _diagnosticoController.text = nuevoTexto;

                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error al guardar: ${response.statusCode}")),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error al conectar con el servidor")),
                        );
                        print('Error: $e');
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Completa todos los campos obligatorios")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                  child: Text("Guardar", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _guardarDiagnostico() async {
    if (_diagnosticoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El diagnóstico no puede estar vacío")),
      );
      return;
    }

    final url = Uri.parse('$baseUrl/usuarios/api/consultas/diagnostico/');
    final Map<String, dynamic> data = {
      'consulta': widget.idConsulta,  // <- Asegúrate de tener este ID en el widget
      'descripcion': _diagnosticoController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Diagnóstico guardado correctamente"),
            backgroundColor: Color(0xFF1565C0),
          ),
        );
         _diagnosticoController.clear();
        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar diagnóstico: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar con el servidor")),
      );
      print('Error: $e');
    }
  }

  Future<void> _guardarEnfermedadDiagnosticada(String fecha) async {
    final url = Uri.parse('$baseUrl/usuarios/api/pacientes_enfermedades/');
    final Map<String, dynamic> data = {
      'paciente': widget.idPaciente,
      'enfermedad': selectedEnfermedadPersistenteId,
      'fecha_diagnostico': fecha,
      'observacion': _descripcionEnfermedadController.text,
      'aprobado': true,
      "doctor_aprobador": widget.idusuariodoc,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        Navigator.of(context).pop();

        setState(() {
          // Usar el nombre que ya tenemos guardado
          enfermedadesDiagnosticadas.add(nombreEnfermedadSeleccionada!);
          // Agregar al texto del diagnóstico
          String textoActual = _diagnosticoController.text;
          String nuevoTexto = textoActual.isEmpty
              ? "Diagnosticado con: $nombreEnfermedadSeleccionada"
              : "$textoActual\n\nDiagnosticado con: $nombreEnfermedadSeleccionada";
          _diagnosticoController.text = nuevoTexto;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Enfermedad diagnosticada correctamente"),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );

        // Limpiar campos
        _descripcionEnfermedadController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar con el servidor")),
      );
      print('Error: $e');
    }
  }

  Future<List<EnfermedadPersistente>> fetchEnfermedadesPersistente(String tipo) async {
    final url = Uri.parse('$baseUrl/usuarios/api/enfermedades-persistentes/?tipo=$tipo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      // Si la solicitud es exitosa, parsea los datos
      List<dynamic> data = json.decode(utf8DecodedBody);
      return data.map((json) => EnfermedadPersistente.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las enfermedad');
    }
  }
}
Future<List<EnfermedadComun>> fetchEnfermedadComun(String tipo) async {
  final url = Uri.parse('$baseUrl/usuarios/api/enfermedad-comun/?tipo=$tipo');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    // Si la solicitud es exitosa, parsea los datos
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => EnfermedadComun.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las enfermedad');
  }
}



