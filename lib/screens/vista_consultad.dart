import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mifirst/screens/Vista_diagnostico.dart';
import 'package:mifirst/screens/Vista_examen_funcional.dart';
import '../constans.dart';
import '../models/tratamientoActual.dart';
import 'Vista_examen_fisico.dart';

class VistaGestionConsulta extends StatefulWidget {
  final int idConsulta;
  final int idPaciente;
  final int idDoctor;
  final String nombre;
  final String apellido;

  const VistaGestionConsulta({
    Key? key,
    required this.idConsulta,
    required this.idPaciente,
    required this.idDoctor,
    required this.nombre,
    required this.apellido,
  }) : super(key: key);

  @override
  State<VistaGestionConsulta> createState() => _VistaGestionConsultaState();
}

class _VistaGestionConsultaState extends State<VistaGestionConsulta> {
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _sintomasController = TextEditingController();
  final TextEditingController _observacionController = TextEditingController();
  bool _examenFuncionalHecho = false;
  bool _examenFisicoHecho = false;
  bool _diagnostico = false;
  bool _signosVitalesHechos = false;
  bool _TratamientoHechos=false;
  String? tipoSeleccionado;
  int? selectedAlergiaId;
  List<dynamic> Tratamientofrecuente = [];// Lista para almacenar las alergias
  List<String> tiposMedicamentos = [
    'Analgésico',
    'Antiinflamatorio',
    'Antibiótico',
    'Hormonal',
    'Broncodilatador',
    'IBP',
    'Antihistamínico',
    'Antibacteriano',
    'Corticoide',
    'Analgésico combinado',
  ];
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _presionSistolicaController = TextEditingController();
  final TextEditingController _presionDiastolicaController = TextEditingController();
  final TextEditingController _frecuenciaCardiacaController = TextEditingController();
  final TextEditingController _frecuenciaRespiratoriaController = TextEditingController();
  final TextEditingController _temperaturaController = TextEditingController();
  final TextEditingController _spo2Controller = TextEditingController();
  final TextEditingController _glucosaController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  @override
  void dispose() {
    _motivoController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _presionSistolicaController.dispose();
    _presionDiastolicaController.dispose();
    _frecuenciaCardiacaController.dispose();
    _frecuenciaRespiratoriaController.dispose();
    _temperaturaController.dispose();
    _spo2Controller.dispose();
    _glucosaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _limpiarCampos() {
    _pesoController.clear();
    _alturaController.clear();
    _presionSistolicaController.clear();
    _presionDiastolicaController.clear();
    _frecuenciaCardiacaController.clear();
    _frecuenciaRespiratoriaController.clear();
    _temperaturaController.clear();
    _spo2Controller.clear();
    _glucosaController.clear();
    _observacionesController.clear();
  }

  String generarResumenVital({
    required double peso,
    required double altura,
    int? sistolica,
    int? diastolica,
    int? fc,
    int? fr,
    double? temperatura,
    int? spo2,
    int? glucosa,
  }) {
    List<String> resultado = [];
    List<String> recomendaciones = [];

    double imc = peso / (altura * altura);
    String clasificacionIMC = '';
    if (imc < 18.5) {
      clasificacionIMC = 'Bajo peso';
      recomendaciones.add("Mejorar la alimentación con comidas más nutritivas.");
    } else if (imc < 25) {
      clasificacionIMC = 'Normal';
    } else if (imc < 30) {
      clasificacionIMC = 'Sobrepeso';
      recomendaciones.add("Reducir el consumo de azúcares y grasas.");
    } else {
      clasificacionIMC = 'Obesidad';
      recomendaciones.add("Consultar a un nutricionista para controlar el peso.");
    }

    if (sistolica != null && diastolica != null) {
      if (sistolica > 140 || diastolica > 90) {
        resultado.add("Presión arterial alta");
        recomendaciones.add("Reducir consumo de sal y controlar el estrés.");
      } else if (sistolica < 90 || diastolica < 60) {
        resultado.add("Presión arterial baja");
        recomendaciones.add("Hidratarse y evitar cambios bruscos de postura.");
      } else {
        resultado.add("Presión arterial normal");
      }
    }

    if (fc != null) {
      if (fc > 100) {
        resultado.add("Frecuencia cardíaca elevada");
        recomendaciones.add("Evitar cafeína y descansar adecuadamente.");
      } else if (fc < 60) {
        resultado.add("Frecuencia cardíaca baja");
        recomendaciones.add("Consultar si hay mareos o fatiga.");
      } else {
        resultado.add("Frecuencia cardíaca normal");
      }
    }

    if (fr != null) {
      if (fr < 12 || fr > 20) {
        resultado.add("Frecuencia respiratoria anormal");
        recomendaciones.add("Evaluar si hay infecciones o ansiedad.");
      } else {
        resultado.add("Frecuencia respiratoria normal");
      }
    }

    if (temperatura != null) {
      if (temperatura > 37.5) {
        resultado.add("Temperatura elevada");
        recomendaciones.add("Controlar fiebre y tomar líquidos.");
      } else if (temperatura < 35.5) {
        resultado.add("Temperatura baja");
        recomendaciones.add("Abrigarse y observar si hay temblores.");
      } else {
        resultado.add("Temperatura normal");
      }
    }

    if (spo2 != null && spo2 < 95) {
      resultado.add("Oxigenación baja (SpO2)");
      recomendaciones.add("Consultar si hay dificultad para respirar.");
    }

    if (glucosa != null) {
      if (glucosa > 140) {
        resultado.add("Glucosa elevada");
        recomendaciones.add("Evitar azúcar y consultar a un médico.");
      } else if (glucosa < 70) {
        resultado.add("Glucosa baja");
        recomendaciones.add("Comer algo dulce si hay síntomas.");
      } else {
        resultado.add("Glucosa en rango normal");
      }
    }

    return '''
🩺 Resultado: ${resultado.join('. ')}. IMC: ${imc.toStringAsFixed(2)} ($clasificacionIMC).

💡 Recomendación: ${recomendaciones.join(' ')}
''';
  }

  Future<void> _mostrarDialogoSignoVitales() async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              scrollable: true, // Para evitar overflow vertical
              title: Text("Añadir Toma de Signos Vitales"),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85, // Ajustar el ancho máximo
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Peso (obligatorio)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _pesoController,
                          decoration: InputDecoration(
                            labelText: "Peso (kg)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Campo obligatorio';
                            final number = double.tryParse(value);
                            if (number == null || number <= 0) return 'Valor inválido';
                            return null;
                          },
                        ),
                      ),

// Altura (opcional)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _alturaController,
                          decoration: InputDecoration(
                            labelText: "Altura (m)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TextInputFormatter.withFunction((oldValue, newValue) {
                              final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
                              if (digitsOnly.isEmpty) {
                                return newValue.copyWith(text: '0.00', selection: const TextSelection.collapsed(offset: 4));
                              }

                              final doubleValue = double.parse(digitsOnly) / 100;
                              final newText = doubleValue.toStringAsFixed(2);

                              return TextEditingValue(
                                text: newText,
                                selection: TextSelection.collapsed(offset: newText.length),
                              );
                            }),
                          ],
                        ),
                      ),


// Presión Sistólica (opcional)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _presionSistolicaController,
                          decoration: InputDecoration(
                            labelText: "Presión Sistólica (mmHg)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),

// Presión Diastólica (opcional)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _presionDiastolicaController,
                          decoration: InputDecoration(
                            labelText: "Presión Diastólica (mmHg)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),

// Frecuencia Cardíaca (opcional)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _frecuenciaCardiacaController,
                          decoration: InputDecoration(
                            labelText: "Frecuencia Cardíaca (bpm)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),

// Frecuencia Respiratoria (opcional)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _frecuenciaRespiratoriaController,
                          decoration: InputDecoration(
                            labelText: "Frecuencia Respiratoria (rpm)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),

// Temperatura (opcional)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _temperaturaController,
                          decoration: InputDecoration(
                            labelText: "Temperatura (°C)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),

// Saturación de Oxígeno (opcional)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _spo2Controller,
                          decoration: InputDecoration(
                            labelText: "Saturación O2 (%)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),

// Glucosa (opcional)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _glucosaController,
                          decoration: InputDecoration(
                            labelText: "Glucosa (mg/dL)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),

// Observaciones (opcional)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _observacionesController,
                          decoration: InputDecoration(
                            labelText: "Observaciones",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
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
                TextButton(
                  onPressed: () async {
                    final url = Uri.parse('$baseUrl/usuarios/api/signos_vitales/');

                    // Validación básica: peso y altura obligatorios
                    if (_pesoController.text.isEmpty || _alturaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Peso y altura son obligatorios")),
                      );
                      return;
                    }

                    final peso = double.tryParse(_pesoController.text) ?? 0;
                    final altura = double.tryParse(_alturaController.text) ?? 1;
                    final sistolica = _presionSistolicaController.text.isNotEmpty ? int.tryParse(_presionSistolicaController.text) : null;
                    final diastolica = _presionDiastolicaController.text.isNotEmpty ? int.tryParse(_presionDiastolicaController.text) : null;
                    final fc = _frecuenciaCardiacaController.text.isNotEmpty ? int.tryParse(_frecuenciaCardiacaController.text) : null;
                    final fr = _frecuenciaRespiratoriaController.text.isNotEmpty ? int.tryParse(_frecuenciaRespiratoriaController.text) : null;
                    final temperatura = _temperaturaController.text.isNotEmpty ? double.tryParse(_temperaturaController.text) : null;
                    final spo2 = _spo2Controller.text.isNotEmpty ? int.tryParse(_spo2Controller.text) : null;
                    final glucosa = _glucosaController.text.isNotEmpty ? int.tryParse(_glucosaController.text) : null;

// Observación manual del usuario
                    final textoUsuario = _observacionesController.text.trim();

// Generar resumen automático
                    final resumenGenerado = generarResumenVital(
                      peso: peso,
                      altura: altura,
                      sistolica: sistolica,
                      diastolica: diastolica,
                      fc: fc,
                      fr: fr,
                      temperatura: temperatura,
                      spo2: spo2,
                      glucosa: glucosa,
                    );

// Combinar
                    final observacionFinal = textoUsuario.isNotEmpty
                        ? '$textoUsuario\n\n$resumenGenerado'
                        : resumenGenerado;

                    final contieneAdvertencia = resumenGenerado.contains('alta') ||
                        resumenGenerado.contains('baja') ||
                        resumenGenerado.contains('elevada') ||
                        resumenGenerado.contains('anormal') ||
                        resumenGenerado.contains('Oxigenación') ||
                        resumenGenerado.contains('Glucosa');

                    if (contieneAdvertencia) {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Advertencia de signos vitales'),
                            content: Text(resumenGenerado),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    }


                    final Map<String, dynamic> data = {
                      'paciente': widget.idPaciente,
                      'peso': double.tryParse(_pesoController.text),
                      'altura': double.tryParse(_alturaController.text),
                      'presion_sistolica': _presionSistolicaController.text.isNotEmpty
                          ? int.tryParse(_presionSistolicaController.text)
                          : null,
                      'presion_diastolica': _presionDiastolicaController.text.isNotEmpty
                          ? int.tryParse(_presionDiastolicaController.text)
                          : null,
                      'frecuencia_cardiaca': _frecuenciaCardiacaController.text.isNotEmpty
                          ? int.tryParse(_frecuenciaCardiacaController.text)
                          : null,
                      'frecuencia_respiratoria': _frecuenciaRespiratoriaController.text.isNotEmpty
                          ? int.tryParse(_frecuenciaRespiratoriaController.text)
                          : null,
                      'temperatura': _temperaturaController.text.isNotEmpty
                          ? double.tryParse(_temperaturaController.text)
                          : null,
                      'spo2': _spo2Controller.text.isNotEmpty
                          ? int.tryParse(_spo2Controller.text)
                          : null,
                      'glucosa': _glucosaController.text.isNotEmpty
                          ? int.tryParse(_glucosaController.text)
                          : null,
                      'observaciones': observacionFinal,
                    };

                    try {
                      final response = await http.post(
                        url,
                        headers: {"Content-Type": "application/json"},
                        body: json.encode(data),
                      );

                      if (response.statusCode == 201) {
                        _limpiarCampos();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Signos vitales guardados correctamente")),
                        );

                        Navigator.of(context).pop(true); // Solo esta línea
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${response.statusCode}")),
                        );
                        print("Respuesta del servidor: ${response.body}");
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error al conectar con el servidor")),
                      );
                      print('Error: $e');
                    }
                  },
                  child: Text("Guardar"),
                ),


              ],
            );
          },
        );
      },
    );

    if (resultado == true) {
      setState(() {
        _signosVitalesHechos = true;
      });
    }
  }
  Future<void> _mostrarDialogoTratamientoFrecuente() async {
    int? selectedTratamientofrecuenteid;
    final TextEditingController _fechaController = TextEditingController();
    final TextEditingController _fechafinController = TextEditingController();
    final TextEditingController _frecuenciaController = TextEditingController();
    final TextEditingController _observacionesController = TextEditingController();

    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              scrollable: true, // Para evitar overflow vertical
              title: Text("Registrar Tratamiento Frecuente"),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85, // Ajustar el ancho máximo
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tipo de medicamento
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: tipoSeleccionado,
                          hint: Text('Tipo de medicamento'),
                          onChanged: (String? newTipo) {
                            setDialogState(() {
                              tipoSeleccionado = newTipo;
                              selectedTratamientofrecuenteid = null; // Reiniciar selección
                            });
                          },
                          items: tiposMedicamentos.map((tipo) {
                            return DropdownMenuItem<String>(
                              value: tipo,
                              child: Text(tipo),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Tipo de medicamento',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                        ),
                      ),

                      // Medicamento
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: FutureBuilder<List<TratamientoFrecuente1>>(
                          future: tipoSeleccionado != null
                              ? fetchTratamientofrecuente(tipoSeleccionado!)
                              : Future.value([]),
                          builder: (context, snapshot) {
                            List<TratamientoFrecuente1> tratamientofrecuente = snapshot.data ?? [];

                            return DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                labelText: 'Medicamento',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                              isExpanded: true,
                              value: selectedTratamientofrecuenteid,
                              onChanged: snapshot.hasData && tratamientofrecuente.isNotEmpty
                                  ? (int? newValue) {
                                setDialogState(() {
                                  selectedTratamientofrecuenteid = newValue;
                                });
                              }
                                  : null,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              selectedItemBuilder: (BuildContext context) {
                                return tratamientofrecuente.map((tf) {
                                  String texto =
                                      '${tf.nombre} ${tf.concentracion} - ${tf.principioActivo} ${tf.via_administracion}';
                                  return Text(
                                    texto,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 16, color: Colors.black),
                                  );
                                }).toList();
                              },
                              items: tratamientofrecuente.map((tf) {
                                String texto =
                                    '${tf.nombre} ${tf.concentracion} \n${tf.principioActivo} ${tf.via_administracion}\n';
                                return DropdownMenuItem<int>(
                                  value: tf.id,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width - 100),
                                    child: Text(
                                      texto,
                                      softWrap: true,
                                      style: TextStyle(fontSize: 16, color: Colors.black),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),

                      // Fecha de inicio
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _fechaController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Fecha de inicio',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setDialogState(() {
                                _fechaController.text = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                        ),
                      ),

                      // Fecha de finalización
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _fechafinController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Fecha de Finalización',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setDialogState(() {
                                _fechafinController.text = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                        ),
                      ),

                      // Frecuencia
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _frecuenciaController,
                          decoration: InputDecoration(
                            labelText: 'Frecuencia',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),

                      // Observaciones
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _observacionesController,
                          decoration: InputDecoration(
                            labelText: 'Observaciones',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
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
                TextButton(
                  onPressed: () async {
                    if (selectedTratamientofrecuenteid != null &&
                        _fechaController.text.isNotEmpty &&
                        _frecuenciaController.text.isNotEmpty) {

                      final url = Uri.parse('$baseUrl/usuarios/api/tratamiento/nuevo/');
                      final Map<String, dynamic> data = {
                        'paciente': widget.idPaciente,
                        'medicamento': selectedTratamientofrecuenteid,
                        'fecha_inicio': _fechaController.text,
                        'fecha_fin': _fechafinController.text,
                        'frecuencia': _frecuenciaController.text,
                        'descripcion': _observacionesController.text,
                        'doctor': widget.idDoctor,
                        "consulta": widget.idConsulta,
                      };

                      try {
                        final response = await http.post(
                          url,
                          headers: {"Content-Type": "application/json"},
                          body: json.encode(data),
                        );

                        if (response.statusCode == 201) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Tratamiento registrado correctamente")),
                          );

                          Navigator.of(context).pop(true); // Solo esta línea
                        } else {
                          String errorMsg = "Error al guardar";

                          try {
                            final body = json.decode(response.body);
                            if (body is Map && body.containsKey('error')) {
                              errorMsg = body['error'];
                            }
                          } catch (e) {
                            print("Error al leer la respuesta del servidor: $e");
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMsg)),
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
                  child: Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
    if (resultado == true) {
      setState(() {
        _TratamientoHechos= true;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Consulta #${widget.idConsulta}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de información del paciente
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.indigo[700]!, Colors.indigo[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Información del Paciente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      '${widget.nombre} ${widget.apellido}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip('ID Consulta: ${widget.idConsulta}'),
                        SizedBox(width: 8),
                        _buildInfoChip('ID Paciente: ${widget.idPaciente}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    _buildInfoChip('ID Doctor: ${widget.idDoctor}'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Card de motivo de consulta
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, color: Colors.indigo[600], size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Motivo de la consulta",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _motivoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Describa el motivo principal de la consulta...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
                        ),
                        contentPadding: EdgeInsets.all(16),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height:16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, color: Colors.blueAccent, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Sintomas",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _sintomasController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Describa los sintomas del paciente",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
                        ),
                        contentPadding: EdgeInsets.all(16),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height:16),


            // Botones de acciones
            Text(
              "Acciones de la Consulta",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 16),
            _buildActionButton(
              onPressed: _mostrarDialogoSignoVitales,
              icon: Icons.favorite,
              label: 'Signos Vitales',
              isCompleted: _signosVitalesHechos,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            _buildActionButton(
              onPressed: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CuerpoInteractivoPage(
                      idConsulta: widget.idConsulta,
                      nombre: widget.nombre,
                      apellido: widget.apellido,
                    ),
                  ),
                );

                if (resultado == true) {
                  setState(() {
                    _examenFuncionalHecho = true;
                  });
                }
              },
              icon: Icons.medical_services_outlined,
              label: 'Examen Funcional',
              isCompleted: _examenFuncionalHecho,
              color: Colors.teal,
            ),
            SizedBox(height: 16),
            _buildActionButton(
              onPressed: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CuerpoInteractivoFisicoPage(
                      idConsulta: widget.idConsulta,
                      nombre: widget.nombre,
                      apellido: widget.apellido,
                    ),
                  ),
                );

                if (resultado == true) {
                  setState(() {
                    _examenFisicoHecho = true;
                  });
                }
              },
              icon: Icons.medical_services_outlined,
              label: 'Examen Fisico',
              isCompleted: _examenFisicoHecho,
              color: Colors.teal,
            ),

            SizedBox(height: 16),
            _buildActionButton(
              onPressed: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiagnosticoView(
                      idConsulta: widget.idConsulta,
                      nombre: widget.nombre,
                      apellido: widget.apellido,
                      idPaciente: widget.idPaciente,
                      idusuariodoc: widget.idDoctor,
                    ),
                  ),
                );

                if (resultado == true) {
                  setState(() {
                    _diagnostico = true;
                  });
                }
              },
              icon: Icons.medical_services_outlined,
              label: 'Diagnostico',
              isCompleted: _diagnostico,
              color: Colors.teal,
            ),
            SizedBox(height: 16),
            _buildActionButton(
              onPressed: _mostrarDialogoTratamientoFrecuente,
              icon: Icons.medical_information,
              label: 'Tratamiento',
              isCompleted: _TratamientoHechos,
              color: Colors.deepOrange,
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye, color: Colors.blueAccent, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Observaciones",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _observacionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Escriba las observaciones que tiene",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
                        ),
                        contentPadding: EdgeInsets.all(16),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),

            // Botón de volver
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_motivoController.text.isNotEmpty &&
                      _sintomasController.text.isNotEmpty &&
                      _observacionController.text.isNotEmpty) {

                    final url = Uri.parse('$baseUrl/usuarios/api/consultas/${widget.idConsulta}/');

                    final Map<String, dynamic> data = {
                      "paciente": widget.idPaciente,
                      "doctor": widget.idDoctor,
                      "motivo": _motivoController.text,
                      "sintomas": _sintomasController.text,
                      "observaciones": _observacionController.text,
                    };

                    try {
                      final response = await http.put(
                        url,
                        headers: {"Content-Type": "application/json"},
                        body: json.encode(data),
                      );

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Consulta actualizada correctamente")),
                        );
                        Navigator.pop(context); // Vuelve a la pantalla anterior
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error al actualizar la consulta")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error de conexión con el servidor")),
                      );
                      print("Error: $e");
                    }

                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Completa todos los campos")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check),
                    SizedBox(width: 8),
                    Text(
                      "Terminar Consulta",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isCompleted,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isCompleted) ...[
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<List<TratamientoFrecuente1>> fetchTratamientofrecuente(String tipo) async {
  final url = Uri.parse('$baseUrl/usuarios/api/medicamentosfrecuente/?tipo=$tipo');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => TratamientoFrecuente1.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las vacunas');
  }
}