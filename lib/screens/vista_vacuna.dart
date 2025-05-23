import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vacuna.dart';
import '../constans.dart';

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
  String? foto='';
  String? nivelSeleccionado;
  String? tipoSeleccionado= 'medicamento';
  int? selectedAlergiaId;
  List<dynamic> vacunas = [];
  DateTime? fechaSeleccionada;
  int? selectedVacunaId;
  int maxdosis = 1; // Mostrar al menos 1 opción por defecto
  int? selectedDosis;
  int? siguienteDosis;// Lista para almacenar las alergias
  bool verUltimasDosis = true;

  final TextEditingController _descripcionAlergiaController = TextEditingController();

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
  Future<void> cargarSiguienteDosis(int vacunaId) async {
    final response = await http.get(Uri.parse(
      '$baseUrl/usuarios/api/proxima-dosis/$idPaciente/$vacunaId/',
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        siguienteDosis = data['proxima_dosis'];
        selectedDosis = siguienteDosis;
      });
    } else {
      setState(() {
        siguienteDosis = null;
        selectedDosis = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No puedes registrar más dosis para esta vacuna.')),
      );
    }
  }
  void _mostrarDialogoVacuna() {



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
                          return SizedBox(
                            width: 300, // puedes usar MediaQuery si quieres hacerlo adaptable
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
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
                                  siguienteDosis = null;
                                  selectedDosis = null;
                                });
                                if (newValue != null) {
                                  cargarSiguienteDosis(newValue);
                                }
                              },

                              selectedItemBuilder: (BuildContext context) {
                                return vacunas.map((vacuna) {
                                  return Text(
                                    vacuna.nombre,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  );
                                }).toList();
                              },
                              items: vacunas.map((vacuna) {
                                return DropdownMenuItem<int>(
                                  value: vacuna.id,
                                  child: Text(vacuna.nombre), // se muestra completo en la lista
                                );
                              }).toList(),
                            ),
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
                      items: (siguienteDosis != null)
                          ? [
                        DropdownMenuItem<int>(
                          value: siguienteDosis,
                          child: Text('Dosis $siguienteDosis'),
                        )
                      ]
                          : [],
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
                      final url = Uri.parse('$baseUrl/usuarios/api/vacunas-pacientes/');
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
  //mostrar Vacuna
  Future<void> _fetchVacunas() async {
    final endpoint = verUltimasDosis
        ? '/usuarios/api/paciente/$idPaciente/ultimas-vacunas/'
        : '/usuarios/api/pacientes/$idPaciente/vacunas/';

    final response = await http.get(Uri.parse('$baseUrl$endpoint'));




    if (response.statusCode == 200) {
      setState(() {
        vacunas = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Error al cargar vacunas');
    }
  }

  Future<void> eliminarVacuna(int idvacunaPaciente) async {
    final url = Uri.parse('$baseUrl/usuarios/api/vacunas-pacientes/$idvacunaPaciente/');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Alergia eliminada correctamente")),
        );
        await _fetchVacunas(); // Actualizar la lista después de eliminar
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


  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  Future<void> _inicializarDatos() async {
    await obtenerDatos(); // no es necesario await si no depende de datos
    await obtenerDatosPacienteSangre(widget.idusuario);
    await _fetchVacunas(); // Llamar después de que idPaciente esté disponible
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
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          padding: EdgeInsets.all(3), // Reducido
                          child: foto == null || foto!.isEmpty
                              ? Icon(
                            Icons.person_pin,
                            color: Colors.white,
                            size: 100, // Reducido
                          )
                              : ClipOval(
                            child: Image.network(
                              '$baseUrl$foto',
                              width: 100, // Reducido
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 12),
                            Text(
                              "GESTOR DE VACUNA",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              nombreUsuario,
                              style: TextStyle(color: Colors.white.withOpacity(0.7),fontSize: 30),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),

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
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Botón "Añadir vacuna"
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: _mostrarDialogoVacuna, // Define tu función aquí
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF0D47A1),
                                  Color(0xFF1976D2),
                                  Color(0xFF42A5F5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.add_circle_outline_sharp,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Añadir vacuna",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Ver todas'),
                          Switch(
                            value: !verUltimasDosis,
                            onChanged: (value) {
                              setState(() {
                                verUltimasDosis = !value;
                                _fetchVacunas(); // recargar con nueva URL
                              });
                            },
                          ),
                        ],
                      ),


                      // Lista de vacunas
                      Expanded(
                        child: vacunas.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                          itemCount: vacunas.length,
                          itemBuilder: (context, index) {
                            final item = vacunas[index];
                            final aprobado = item['aprobado'] == true;
                            final doctor = item['doctor_aprobador'];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white,
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Título + check de aprobado
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(width: 75),
                                        Expanded(
                                          child: Text(
                                            item['nombre_vacuna'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        if (aprobado)
                                          const Icon(Icons.verified, color: Colors.blue, size: 26),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Ícono vacuna
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Center(
                                              child: Text('💉', style: TextStyle(fontSize: 30)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),

                                        // Información
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Dosis: ${item['dosis']} / ${item['max_dosis']}', style: const TextStyle(color: Colors.black54)),
                                              Text('Fecha: ${item['fecha_aplicacion']}', style: const TextStyle(color: Colors.black54)),

                                              if (item['observacion'] != null && item['observacion'].toString().isNotEmpty)
                                                Text('Observación: ${item['observacion']}', style: const TextStyle(color: Colors.black54)),

                                              if (aprobado && doctor != null && doctor.toString().isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text('Doctor: $doctor', style: const TextStyle(color: Colors.black87)),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Botones si NO está aprobado
                                    if (!aprobado)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.black54),
                                            onPressed: () {
                                              final observacionController = TextEditingController(text: item['observacion']);
                                              String dosisSeleccionada = item['dosis'].toString();

                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Editar vacuna'),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        controller: observacionController,
                                                        decoration: const InputDecoration(labelText: 'Observación'),
                                                        maxLines: 2,
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: const Text('Cancelar'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {

                                                      },
                                                      child: const Text('Guardar'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Confirmar eliminación'),
                                                  content: const Text('¿Estás seguro de que deseas eliminar esta vacuna?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: const Text('Cancelar'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context).pop();
                                                        await eliminarVacuna(item['id']);
                                                      },
                                                      child: const Text('Eliminar'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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

Future<List<Vacuna>> fetchVacunas() async {
  final url = Uri.parse('$baseUrl/usuarios/api/vacunas/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => Vacuna.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las vacunas');
  }
}




