import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/screens/fotoPerfil.dart';
import '../models/alergias.dart';
import '../constans.dart';

class VistaSignoVitales extends StatefulWidget {
  final int idusuario;

  const VistaSignoVitales( {super.key, required this.idusuario});

  @override
  State<VistaSignoVitales> createState() => _VistaSignoVitales();
}

class _VistaSignoVitales extends State<VistaSignoVitales> {
  String nombreUsuario = '';
  String apellidoUsuario = '';
  String cedulaUsuario = '';
  String emailUsuario = '';
  String telefonoUsuario = '';
  String fechaNacimientoUsuario = '';
  bool estadoUsuario = false;
  int idRolUsuario = 0;
  String? foto='';
  bool isLoading = true;
  int idPaciente = 0;
  int idSangre = 0;
  String tipoSangre = '';
  String? filtroActivo;
  List<dynamic> signovitales = [];
  String tipoGraficoSeleccionado = 'Ver registros';

  final List<String> opcionesGraficas = [
    'Ver registros',
    'Peso',
    'IMC',
    'Glucosa',
    'Temperatura',
    'Frecuencia cardíaca',
    'Frecuencia respiratoria',
    'Presión arterial'
  ];

  final TextEditingController _descripcionAlergiaController = TextEditingController();
  bool isLoadingSignos = false;
  bool hasErrorSignos = false;
  final TextEditingController _pesoController = TextEditingController();                   // Obligatorio
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



  Future<void> obtenerDatos() async {
    final url = Uri.parse('$baseUrl/usuarios/api/usuario/${widget.idusuario}/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var datos = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          nombreUsuario = datos['nombre'];
          apellidoUsuario = datos['apellido'];
          cedulaUsuario = datos['cedula'];
          emailUsuario = datos['email'];
          telefonoUsuario = datos['telefono'];
          fechaNacimientoUsuario = datos['fecha_nacimiento'];
          estadoUsuario = datos['estado'];
          idRolUsuario = datos['id_rol'];
          foto =datos['foto_perfil'];

          if (foto != null && foto!.isNotEmpty) {
            // Reemplazamos 'localhost' por tu baseUrl
            String nuevaFotoUrl = foto!.replaceFirst('http://localhost:8000', baseUrl);
            print(nuevaFotoUrl); // Esto imprimirá la URL con tu baseUrl
          } else {
            // Si la foto es nula o vacía, puedes manejar el caso como desees
            print('La foto no está disponible');
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }
  Future<void> obtenerDatosPacienteSangre(int idUsuario) async {
    final url = Uri.parse('$baseUrl/usuarios/api/pacientes/por-usuario/$idUsuario/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var datos = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          idPaciente = datos['id_paciente']; // Asignamos el id del paciente
          idSangre = datos['id_sangre']['id_sangre']; // Asignamos el id de sangre
          tipoSangre = datos['id_sangre']['tipo_sangre']; // Asignamos el tipo de sangre
          isLoading = false; // Cambiamos el estado de carga
        });
      } else {
        print('Error al obtener el tipo de sangre: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  void _mostrarDialogoSignoVitales() {


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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

                    final Map<String, dynamic> data = {
                      'paciente': idPaciente,
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
                      'observaciones': _observacionesController.text.trim().isNotEmpty
                          ? _observacionesController.text.trim()
                          : null,
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
                          SnackBar(content: Text("Signos vitales guardados correctamente")),
                        );
                      } else {
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
  }

  Future<void> _fetchSignosVitales() async {
    setState(() {
      isLoadingSignos = true;
      hasErrorSignos = false;
    });

    try {
      final url = '$baseUrl/usuarios/api/signos_vitales/?paciente_id=$idPaciente';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          signovitales = jsonDecode(utf8.decode(response.bodyBytes));
        });
      } else {
        setState(() {
          hasErrorSignos = true;
        });
      }
    } catch (e) {
      setState(() {
        hasErrorSignos = true;
      });
    } finally {
      setState(() {
        isLoadingSignos = false;
      });
    }
  }

  List<FlSpot> _generarSpots(String tipo) {
    List<FlSpot> spots = [];

    // 1. Crear copia ordenada por fecha descendente (más reciente primero)
    final List<Map<String, dynamic>> datosOrdenados = List<Map<String, dynamic>>.from(signovitales);
    datosOrdenados.sort((a, b) => DateTime.parse(b['fecha']).compareTo(DateTime.parse(a['fecha'])));

    // 2. Generar spots en ese orden
    for (int i = 0; i < datosOrdenados.length; i++) {
      final item = datosOrdenados[i];
      double? valor;

      switch (tipo) {
        case 'Peso':
          valor = (item['peso'] as num?)?.toDouble();
          break;
        case 'IMC':
          valor = (item['imc'] as num?)?.toDouble();
          break;
        case 'Glucosa':
          valor = (item['glucosa'] as num?)?.toDouble();
          break;
        case 'Temperatura':
          valor = (item['temperatura'] as num?)?.toDouble();
          break;
        case 'Frecuencia cardíaca':
          valor = (item['frecuencia_cardiaca'] as num?)?.toDouble();
          break;
        case 'Frecuencia respiratoria':
          valor = (item['frecuencia_respiratoria'] as num?)?.toDouble();
          break;
        case 'Presión sistólica':
          valor = (item['presion_sistolica'] as num?)?.toDouble();
          break;
        case 'Presión diastólica':
          valor = (item['presion_diastolica'] as num?)?.toDouble();
          break;
      }

      if (valor != null) {
        spots.add(FlSpot(i.toDouble(), valor));
      }
    }

    return spots;
  }

  List<FlSpot> _generarSpotsPresion(String subtipo) {
    List<FlSpot> spots = [];

    for (int i = 0; i < signovitales.length; i++) {
      final item = signovitales[i];
      double? valor;

      switch (subtipo) {
        case 'sistolica':
          valor = (item['presion_sistolica'] as num?)?.toDouble();
          break;
        case 'diastolica':
          valor = (item['presion_diastolica'] as num?)?.toDouble();
          break;
      }

      if (valor != null) {
        spots.add(FlSpot(i.toDouble(), valor));
      }
    }

    return spots;
  }

  double _getValorOptimo(String tipo) {
    switch (tipo) {
      case 'Peso':
        double altura = _obtenerAlturaDelPaciente(); // función que extrae la última altura registrada
        return _getPesoIdeal(altura);
      case 'IMC':
        return 22.0;
      case 'Glucosa':
        return 90.0;
      case 'Temperatura':
        return 36.5;
      case 'Frecuencia cardíaca':
        return 72.0;
      case 'Frecuencia respiratoria':
        return 18.0;
      case 'Presión sistólica':
        return 120.0;
      case 'Presión diastólica':
        return 80.0;
      default:
        return 0.0;
    }
  }


  double _getMinY(String tipo) {
    if (tipo == 'Peso') {
      final altura = _obtenerAlturaDelPaciente();
      final pesoMinimo = 18.5 * altura * altura;
      return pesoMinimo - 8; // margen visual
    }
    // otros tipos normales
    switch (tipo) {
      case 'IMC':
        return 15;
      case 'Glucosa':
        return 70;
      case 'Temperatura':
        return 35;
      case 'Frecuencia cardíaca':
        return 50;
      case 'Frecuencia respiratoria':
        return 10;
      case 'Presión arterial':
        return 60;
      default:
        return 0;
    }
  }

  double _getMaxY(String tipo) {
    if (tipo == 'Peso') {
      final altura = _obtenerAlturaDelPaciente();
      final pesoMaximo = 24.9 * altura * altura;
      return pesoMaximo + 10; // margen visual
    }
    switch (tipo) {
      case 'IMC':
        return 30;
      case 'Glucosa':
        return 130;
      case 'Temperatura':
        return 39;
      case 'Frecuencia cardíaca':
        return 120;
      case 'Frecuencia respiratoria':
        return 30;
      case 'Presión arterial':
        return 140;
      default:
        return 100;
    }
  }


  double _getPesoIdeal(double altura) {
    const double imcIdeal = 22.0; // IMC promedio saludable
    return imcIdeal * altura * altura;
  }

  double _obtenerAlturaDelPaciente() {
    if (signovitales.isEmpty) return 1.70; // valor por defecto

    signovitales.sort((a, b) => DateTime.parse(b['fecha']).compareTo(DateTime.parse(a['fecha'])));

    final altura = signovitales.first['altura'];
    return (altura != null) ? (altura as num).toDouble() : 1.70;
  }

  Widget _buildListaRegistros() {
    return isLoadingSignos
        ? const Center(child: CircularProgressIndicator())
        : hasErrorSignos
        ? Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off, size: 48, color: Colors.red.shade300),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin conexión al servidor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Verifica tu conexión a internet e intenta nuevamente.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _fetchSignosVitales(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.refresh, size: 18),
                  SizedBox(width: 8),
                  Text("Reintentar"),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        : signovitales.isEmpty
        ? Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.monitor_heart_outlined, size: 48, color: Colors.blue.shade300),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin signos vitales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega el primer registro de signos vitales.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        : ListView.builder(
      itemCount: signovitales.length,
      itemBuilder: (context, index) {
        final item = signovitales[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header de la card
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.monitor_heart, size: 24, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Signos Vitales",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        item['fecha'].toString().substring(0, 10),
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Grid de signos vitales
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildSignoVitalItem(Icons.monitor_weight, "Peso", "${item['peso']} kg", Colors.blue),
                    _buildSignoVitalItem(Icons.height, "Altura", "${item['altura']} m", Colors.green),
                    _buildSignoVitalItem(Icons.favorite, "Presión", "${item['presion_sistolica']}/${item['presion_diastolica']}", Colors.red),
                    _buildSignoVitalItem(Icons.heart_broken, "FC", "${item['frecuencia_cardiaca']} lpm", Colors.pink),
                    _buildSignoVitalItem(Icons.air, "FR", "${item['frecuencia_respiratoria']} rpm", Colors.cyan),
                    _buildSignoVitalItem(Icons.thermostat, "Temp", "${item['temperatura']} °C", Colors.orange),
                    _buildSignoVitalItem(Icons.opacity, "SpO₂", "${item['spo2']}%", Colors.indigo),
                    _buildSignoVitalItem(Icons.water_drop, "Glucosa", "${item['glucosa']} mg/dL", Colors.purple),
                  ],
                )
                ,

                // Información adicional
                if (item['observaciones'] != null && item['observaciones'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note_alt, size: 20, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Observaciones: ${item['observaciones']}',
                            style: TextStyle(
                              color: Colors.amber.shade800,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (item['doctor_nombre'] != null && item['doctor_nombre'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.medical_services, size: 18, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Doctor: ${item['doctor_nombre']}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

// Método para construir la vista de gráfica
  Widget _buildVistaGrafica() {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.show_chart, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tendencia',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tipoGraficoSeleccionado,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: signovitales.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade100, Colors.grey.shade50],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.timeline_outlined,
                      size: 56,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sin datos para mostrar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Agrega algunos registros para ver la gráfica.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: LineChart(
                LineChartData(
                  minY: _getMinY(tipoGraficoSeleccionado),
                  maxY: _getMaxY(tipoGraficoSeleccionado),
                  titlesData: FlTitlesData(
                    // Títulos del eje Y (izquierdo) - Menos números
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getIntervalY(tipoGraficoSeleccionado), // Función para calcular intervalo apropiado
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Títulos del eje X (inferior) - Solo algunas fechas
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _getIntervalX(), // Mostrar menos fechas
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < signovitales.length) {
                            String fecha = signovitales[index]['fecha'];
                            DateTime date = DateTime.parse(fecha);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300, width: 1),
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: _getIntervalY(tipoGraficoSeleccionado),
                    verticalInterval: _getIntervalX(),
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  lineBarsData: tipoGraficoSeleccionado == 'Presión arterial'
                      ? [
                    // Línea para presión sistólica
                    LineChartBarData(
                      spots: _generarSpotsPresion('sistolica'),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      barWidth: 3.5,
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade600],
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: Colors.red.shade600,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.red.withOpacity(0.1),
                            Colors.red.withOpacity(0.02),
                          ],
                        ),
                      ),
                    ),
                    // Línea para presión diastólica
                    LineChartBarData(
                      spots: _generarSpotsPresion('diastolica'),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      barWidth: 3.5,
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: Colors.orange.shade600,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.orange.withOpacity(0.1),
                            Colors.orange.withOpacity(0.02),
                          ],
                        ),
                      ),
                    ),
                  ]
                      : [
                    // Línea principal
                    LineChartBarData(
                      spots: _generarSpots(tipoGraficoSeleccionado),
                      isCurved: true,
                      curveSmoothness: 0.35,
                      barWidth: 4,
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 5,
                              color: Colors.blue.shade600,
                              strokeWidth: 2.5,
                              strokeColor: Colors.white,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.withOpacity(0.15),
                            Colors.blue.withOpacity(0.02),
                          ],
                        ),
                      ),
                    ),
                    // Línea de valor óptimo (si aplica)
                    if (_getValorOptimo(tipoGraficoSeleccionado) > 0 &&
                        _generarSpots(tipoGraficoSeleccionado).isNotEmpty)
                      LineChartBarData(
                        spots: [
                          FlSpot(
                            0,
                            _getValorOptimo(tipoGraficoSeleccionado),
                          ),
                          FlSpot(
                            (_generarSpots(tipoGraficoSeleccionado).length - 1).toDouble(),
                            _getValorOptimo(tipoGraficoSeleccionado),
                          ),
                        ],
                        isCurved: false,
                        barWidth: 2.5,
                        color: Colors.green.shade500,
                        dashArray: [8, 4],
                        dotData: FlDotData(show: false),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función auxiliar para calcular el intervalo apropiado del eje Y
  double _getIntervalY(String tipo) {
    double min = _getMinY(tipo);
    double max = _getMaxY(tipo);
    double range = max - min;

    if (range <= 10) return 2;
    if (range <= 30) return 5;
    if (range <= 60) return 10;
    if (range <= 150) return 20;
    return 50;
  }

  // Función auxiliar para calcular el intervalo apropiado del eje X
  double _getIntervalX() {
    if (signovitales.length <= 5) return 1;
    if (signovitales.length <= 10) return 2;
    if (signovitales.length <= 20) return 3;
    return (signovitales.length / 5).ceil().toDouble();
  }

  Future<void> eliminarAlergia(int idAlergiaPaciente) async {
    final url = Uri.parse('$baseUrl/usuarios/api/pacientes-alergias/$idAlergiaPaciente/');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Alergia eliminada correctamente")),
        );
       // await _fetchAlergias(); // Actualizar la lista después de eliminar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar con el servidor")),
      );
      print('Error: $e');
    }
  }

  Future<void> editarAlergia({required int id, required String gravedad, required String observacion,}) async {

    final url = Uri.parse('$baseUrl/usuarios/api/pacientes-alergias/$id/');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'gravedad': gravedad,
          'observacion': observacion,
        }),
      );

      if (response.statusCode == 200) {
        print('Alergia actualizada exitosamente');
      } else {
        print('Error al editar alergia: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Excepción al editar alergia: $e');
    }
  }






  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }
  Future<void> _inicializarDatos() async {
    await obtenerDatos(); // no es necesario await si no depende de datos
    await obtenerDatosPacienteSangre(widget.idusuario);
    await _fetchSignosVitales(); // Llamar después de que idPaciente esté disponible
  }



  @override
  Widget build(BuildContext context) {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D47A1), // Azul oscuro
                Color(0xFF1976D2), // Azul medio
                Color(0xFF42A5F5), // Azul claro
                Color(0xFF7E57C2), // Morado
                Color(0xFF26C6DA), // Turquesa,
              ]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    SizedBox(height: 25),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CambiarFotoScreen(idusuario: widget.idusuario,)), // Reemplaza con tu widget de destino
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            padding: EdgeInsets.all(3),
                            child: foto == null || foto!.isEmpty
                                ? Icon(
                              Icons.person_pin,
                              color: Colors.white,
                              size: 70,
                            )
                                : ClipOval(
                              child: Image.network(
                                '$baseUrl$foto',
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded( // <- ¡Esta línea soluciona el overflow!
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4.0),
                              Text(
                                "Pc.$nombreUsuario $apellidoUsuario",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis, // <-- por si aún se desborda
                              ),
                              SizedBox(height: 1.0),
                              Text(
                                fechaHoy,
                                style: TextStyle(color: Colors.grey[300],fontSize: 12),
                                overflow: TextOverflow.ellipsis, // opcional
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Signos Registrados',
                      style: TextStyle(color: Colors.white,fontSize: 25),
                      overflow: TextOverflow.ellipsis, // opcional
                    ),
                    SizedBox(height: 25),

                  ],
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100], // Un gris más suave
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Header mejorado con botones estilizados
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: GestureDetector(
                                onTap: _mostrarDialogoSignoVitales,
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF0D47A1),
                                        Color(0xFF1976D2),
                                        Color(0xFF42A5F5),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF1976D2).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          "Añadir Signos",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              flex: 1,
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF0D47A1),
                                      Color(0xFF1976D2),
                                      Color(0xFF42A5F5),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color:  Color(0xFF0D47A1).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      tipoGraficoSeleccionado == 'Ver registros'
                                          ? Icons.list_alt
                                          : Icons.analytics_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: tipoGraficoSeleccionado,
                                        isExpanded: true,
                                        underline: Container(),
                                        dropdownColor: Color(0xFF0D47A1),
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                        items: opcionesGraficas.map((String tipo) {
                                          return DropdownMenuItem<String>(
                                            value: tipo,
                                            child: Row(
                                              children: [

                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    tipo,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? nuevoTipo) {
                                          if (nuevoTipo != null) {
                                            setState(() {
                                              tipoGraficoSeleccionado = nuevoTipo;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )

                      ),

                      const SizedBox(height: 16),

                      // Contenido condicional basado en la selección
                      Expanded(
                        child: tipoGraficoSeleccionado == 'Ver registros'
                            ? _buildListaRegistros() // Mostrar solo la lista de registros
                            : _buildVistaGrafica(),  // Mostrar solo la gráfica
                      ),
                    ],
                  ),
                ),
              )









            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildSignoVitalItem(IconData icon, String titulo, String valor, Color color) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
