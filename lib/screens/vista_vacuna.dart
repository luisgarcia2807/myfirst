import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alergias.dart';
import '../models/vacuna.dart';

class VistaVacuna extends StatefulWidget {
  final int idusuario;
  const VistaVacuna({super.key, required this.idusuario});

  @override
  State<VistaVacuna> createState() => _VistaVacuna();
}

class _VistaVacuna extends State<VistaVacuna> {
  String nombreUsuario = '';
  String apellidoUsuario = '';
  String cedulaUsuario = '';
  String emailUsuario = '';
  String telefonoUsuario = '';
  String fechaNacimientoUsuario = '';
  bool estadoUsuario = false;
  int idRolUsuario = 0;
  bool isLoading = true;
  int idPaciente = 0;
  int idSangre = 0;
  String tipoSangre = '';
  String? nivelSeleccionado;
  String? tipoSeleccionado= 'medicamento';
  int? selectedAlergiaId;
  List<dynamic> vacunas = [];  // Lista para almacenar las alergias



  final TextEditingController _descripcionAlergiaController = TextEditingController();

  Future<void> obtenerDatos() async {
    final url = Uri.parse('http://192.168.0.105:8000/usuarios/api/usuario/${widget.idusuario}/');

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
    final url = Uri.parse('http://192.168.0.105:8000/usuarios/api/pacientes/por-usuario/$idUsuario/');

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
  void _mostrarDialogoVacuna() {
    DateTime? fechaSeleccionada;
    int? selectedVacunaId;
    int maxdosis = 1; // Mostrar al menos 1 opción por defecto
    int? selectedDosis;

    final TextEditingController _fechaController = TextEditingController();
    final TextEditingController _descripcionVacunaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Registrar Vacuna"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vacuna
                    FutureBuilder<List<Vacuna>>(
                      future: fetchVacunas(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('No hay vacunas disponibles');
                        } else {
                          List<Vacuna> vacunas = snapshot.data!;
                          return DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Vacuna',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedVacunaId,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedVacunaId = newValue;
                                Vacuna selectedVacuna = vacunas.firstWhere((v) => v.id == newValue!);
                                maxdosis = selectedVacuna.maxDosis;
                                selectedDosis = null; // Reiniciar dosis al cambiar vacuna
                              });
                            },
                            items: vacunas.map((Vacuna vacuna) {
                              return DropdownMenuItem<int>(
                                value: vacuna.id,
                                child: Text('${vacuna.nombre}'),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 10),

                    // Fecha
                    TextField(
                      controller: _fechaController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha de aplicación',
                        border: OutlineInputBorder(),
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
                    SizedBox(height: 10),

                    // Dosis (siempre visible)
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Selecciona la dosis',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedDosis,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedDosis = newValue;
                        });
                      },
                      items: List.generate(maxdosis, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text('Dosis ${index + 1}'),
                        );
                      }),
                    ),
                    SizedBox(height: 10),

                    // Descripción
                    TextField(
                      controller: _descripcionVacunaController,
                      decoration: InputDecoration(
                        labelText: "Descripción",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedVacunaId != null &&
                        _fechaController.text.isNotEmpty &&
                        selectedDosis != null) {
                      final url = Uri.parse('http://192.168.0.105:8000/usuarios/api/vacunas-pacientes/');
                      final Map<String, dynamic> data = {
                        'paciente': idPaciente,
                        'vacuna': selectedVacunaId,
                        'fecha_aplicacion': _fechaController.text,
                        'dosis': selectedDosis,
                        'observacion': _descripcionVacunaController.text,

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
                            SnackBar(content: Text("Vacuna registrada correctamente")),
                          );
                          await _fetchVacunas(); // <--- Esta línea actualiza la lista
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
                        SnackBar(content: Text("Completa todos los campos")),
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
  }




  //mostrar alergia
  Future<void> _fetchVacunas() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/usuarios/api/pacientes/2/vacunas/'),
    );

    if (response.statusCode == 200) {
      setState(() {
        vacunas = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Error al cargar vacunas');
    }
  }


  @override
  void initState() {
    super.initState();
    obtenerDatos();
    obtenerDatosPacienteSangre(widget.idusuario);
    _fetchVacunas();
  }

  @override
  Widget build(BuildContext context) {

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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.person_pin,
                            color: Colors.white,
                            size: 100,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "GESTOR DE VACUNA",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              nombreUsuario,
                              style: TextStyle(color: Colors.white.withOpacity(0.7),fontSize: 24),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: _mostrarDialogoVacuna,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.add_circle_outline_sharp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: vacunas.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    itemCount: vacunas.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.only(bottom: 10),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Row(
                            children: [
                              SizedBox(height: 2),
                              Container(
                                padding: EdgeInsets.only(left: 8),
                                width: 60,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.blue, // Color fijo azul
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '💉', // Emoji de vacuna
                                    style: TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vacunas[index]['nombre_vacuna'],
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Text(
                                      'Dosis: ${vacunas[index]['dosis']} / ${vacunas[index]['max_dosis']}',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Text(
                                      'Fecha: ${vacunas[index]['fecha_aplicacion']}',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Text(
                                      'Observación: ${vacunas[index]['observacion']}',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

Future<List<Vacuna>> fetchVacunas() async {
  final url = Uri.parse('http://localhost:8000/usuarios/api/vacunas/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => Vacuna.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las vacunas');
  }
}

