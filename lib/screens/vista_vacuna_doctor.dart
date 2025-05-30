import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/screens/fotoPerfil.dart';
import '../models/vacuna.dart';
import '../constans.dart';

class VistaVacunadoctor extends StatefulWidget {
  final int idusuario;
  final String nombre;
  final String apellido;
  final int idusuariodoc;
  const VistaVacunadoctor({super.key, required this.idusuario,required this.nombre, required this.apellido, required this.idusuariodoc});

  @override
  State<VistaVacunadoctor> createState() => _VistaVacunadoctor();
}

class _VistaVacunadoctor extends State<VistaVacunadoctor> {
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
  int? selectedAlergiaId;
  List<dynamic> vacunas = [];
  DateTime? fechaSeleccionada;
  int? selectedVacunaId;
  int maxdosis = 1; // Mostrar al menos 1 opción por defecto
  int? selectedDosis;
  int? siguienteDosis;// Lista para almacenar las alergias
  bool verUltimasDosis = true;
  bool hasError = false;


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
  Future<void> cargarSiguienteDosis(int vacunaId, void Function(void Function()) localSetState) async {
    final response = await http.get(Uri.parse(
      '$baseUrl/usuarios/api/proxima-dosis/$idPaciente/$vacunaId/',
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      localSetState(() {
        siguienteDosis = data['proxima_dosis'];
        selectedDosis = siguienteDosis;
      });
    } else {
      localSetState(() {
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
                                  cargarSiguienteDosis(newValue, setState); // pasa el setState local del StatefulBuilder
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
  Future<void> editarVacuna({required int id, required String observacion,}) async {

    final url = Uri.parse('$baseUrl/usuarios/api/vacunas-pacientes/$id/');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'observacion': observacion,
        }),
      );

      if (response.statusCode == 200) {
        print('vacuna actualizada exitosamente');
      } else {
        print('Error al editar vacuna: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Excepción al editar vacuna: $e');
    }
  }

  Future<void> aprobarAlergia(int idvacuna, bool aprobado) async {
    final url = Uri.parse('$baseUrl/usuarios/api/vacunas-pacientes/$idvacuna/');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'aprobado': aprobado,
          "doctor_aprobador":widget.idusuariodoc,

        }),
      );

      if (response.statusCode == 200) {
        print('Alergia actualizada correctamente.');
      } else {
        print('Error al actualizar la alergia: ${response.statusCode}');
        print('Cuerpo: ${response.body}');
      }
    } catch (e) {
      print('Excepción al actualizar la alergia: $e');
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
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Dr. ${widget.nombre} ${widget.apellido}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

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
                      'Vacunas Registradas',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón Añadir vacuna
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: _mostrarDialogoVacuna,
                                child: Container(
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
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.add_circle, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        "Añadir Vacuna",
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
                          ),
                          // Switch "Ver todas"
                          Container(
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
                              border: Border.all(color: Colors.blue.shade800, width:0.1),
                            ),
                            padding: const EdgeInsets.all(0.5),
                            child: Transform.scale(
                              scale: 0.8, // Reduce el tamaño del switch
                              child: Switch(
                                activeColor: Colors.white,
                                activeTrackColor: Colors.blue.shade800,
                                inactiveThumbColor: Colors.blue.shade800,
                                inactiveTrackColor: Colors.white,
                                value: !verUltimasDosis,
                                onChanged: (value) {
                                  setState(() {
                                    verUltimasDosis = !value;
                                    _fetchVacunas();
                                  });
                                },
                              ),
                            ),
                          ),


                        ],
                      ),
                      const SizedBox(height: 12),
                      // Lista de vacunas
                      Expanded(
                        child: isLoading
                            ? const Center(
                          child: CircularProgressIndicator(),
                        )
                            : vacunas.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                          itemCount: vacunas.length,
                          itemBuilder: (context, index) {
                            final item = vacunas[index];
                            final aprobado = item['aprobado'] == true;


                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Título + check de aprobado
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['nombre_vacuna'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        if (aprobado)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: const [
                                                Icon(Icons.verified, color: Colors.green, size: 18),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Aprobado",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Ícono vacuna
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.vaccines
                                            ,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),

                                        const SizedBox(width: 15),

                                        // Información
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.stacked_bar_chart, color: Colors.black54, size: 20),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Dosis: ${item['dosis']} / ${item['max_dosis']}',
                                                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Icon(Icons.event_available, size: 18, color: Colors.black54),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Fecha: ${item['fecha_aplicacion']}',
                                                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              if (item['observacion'] != null && item['observacion'].toString().isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Icon(Icons.note_alt, size: 18, color: Colors.black45),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          'Observación: ${item['observacion']}',
                                                          style: const TextStyle(color: Colors.black54,fontSize: 12),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (item['doctor_aprobador'] != null && item['doctor_aprobador'].toString().isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.medical_services, size: 18, color: Colors.black54),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Doctor: ${item['doctor_aprobador']}',
                                                        style: const TextStyle(color: Colors.black87,fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),






                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Botones si NO está aprobado
                                    if (!aprobado && verUltimasDosis == false )
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.verified_rounded, color: Colors.green, size: 28),
                                            tooltip: 'Aprobar',
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Aprobar alergia'),
                                                  content: const Text('¿Estás seguro de que deseas aprobar esta alergia?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(false),
                                                      child: const Text('Cancelar'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(true),
                                                      child: const Text('Aprobar'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                await aprobarAlergia(item['id'],true);
                                                setState(() {
                                                  item['aprobado'] = true;
                                                });
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                            onPressed: () {
                                              final observacionController = TextEditingController(text: item['observacion']);

                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Editar vacuna'),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [

                                                      const SizedBox(height: 10),
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
                                                        Navigator.of(context).pop();
                                                        await editarVacuna(
                                                          id: item['id'],
                                                          observacion: observacionController.text,
                                                        );
                                                        setState(() {
                                                          item['observacion'] = observacionController.text;
                                                        });
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




