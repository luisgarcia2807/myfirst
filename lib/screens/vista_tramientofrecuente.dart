import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tratamientoFrecuente.dart';
import '../constans.dart';

class VistaTratamientofrecuente extends StatefulWidget {
  final int id_paciente;
  const VistaTratamientofrecuente({super.key, required this.id_paciente});

  @override
  State<VistaTratamientofrecuente> createState() => _VistaTratamientofrecuente();
}

class _VistaTratamientofrecuente extends State<VistaTratamientofrecuente> {
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
  String sexo = '';
  String tipoUsuario='';
  int idtipoUsuario=0;
  String? nivelSeleccionado;
  String? tipoSeleccionado= 'Losartan';
  int? selectedAlergiaId;
  List<dynamic> Tratamientofrecuente = [];  // Lista para almacenar las alergias


  Future<void> obtenerIdUsuarioDesdePaciente() async {
    final url = Uri.parse('$baseUrl/usuarios/api/usuario-desde-paciente/${widget.id_paciente}/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var datos = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          idPaciente= datos['id_paciente'];
          idSangre=datos['id_sangre'];
          tipoSangre=datos['tipo_sangre'];
          tipoUsuario=datos['tipo'];
          idtipoUsuario=datos['id_u'];
          print(tipoUsuario);
          isLoading = false; // Terminamos la carga
        });
      } else {
        print('Error al obtener el id del usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> obtenerDatos(id) async {
    final url = Uri.parse('$baseUrl/usuarios/api/usuario/$id/');

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
  Future<void> obtenerDatosBebes(id) async {
    // La URL de tu API (reemplázala por la URL correcta)
    final url = Uri.parse('$baseUrl/usuarios/api/bebes/$id/'); // Asegúrate de cambiar esto

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // La respuesta fue exitosa, imprimimos los datos en la consola
        var datos = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          nombreUsuario = datos['nombre'];
          apellidoUsuario = datos['apellido'];
          fechaNacimientoUsuario = datos['fecha_nacimiento'];
          sexo= datos['sexo'];

        });

      } else {
        // Si el servidor no responde con un código 200
        print('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      // Si ocurre un error durante la petición
      print('Error: $e');
    }
  }
  void _mostrarDialogoTratamientoFrecuente() {
    DateTime? fechaSeleccionada;
    int? selectedTratamientofrecuenteid;

    final TextEditingController _fechaController = TextEditingController();
    final TextEditingController _dosisController = TextEditingController();
    final TextEditingController _frecuenciaController = TextEditingController();
    final TextEditingController _observacionesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Registrar Tratamiento Frecuente"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Medicamento Crónico
                    FutureBuilder<List<TratamientoFrecuente>>(
                      future: fetchTratamientofrecuente(), // Debes implementar esta función
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('No hay medicamentos disponibles');
                        } else {
                          List<TratamientoFrecuente> Tratamientofrecuente = snapshot.data!;
                          return DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Losartan',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedTratamientofrecuenteid,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedTratamientofrecuenteid = newValue;
                              });
                            },
                            items: Tratamientofrecuente.map((tf) {
                              return DropdownMenuItem<int>(
                                value: tf.id,
                                child: Text('${tf.nombre}'),
                              );
                            }).toList(),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 10),

                    // Fecha de inicio
                    TextField(
                      controller: _fechaController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha de inicio',
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

                    // Dosis
                    TextField(
                      controller: _dosisController,
                      decoration: InputDecoration(
                        labelText: 'Dosis',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Frecuencia
                    TextField(
                      controller: _frecuenciaController,
                      decoration: InputDecoration(
                        labelText: 'Frecuencia',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Observaciones
                    TextField(
                      controller: _observacionesController,
                      decoration: InputDecoration(
                        labelText: 'Observaciones',
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
                    if (selectedTratamientofrecuenteid != null &&
                        _fechaController.text.isNotEmpty &&
                        _dosisController.text.isNotEmpty &&
                        _frecuenciaController.text.isNotEmpty) {

                      final url = Uri.parse('$baseUrl/usuarios/api/paciente_medicamento_cronico/');
                      final Map<String, dynamic> data = {
                        'id_paciente': idPaciente,
                        'id_medicamento_cronico': selectedTratamientofrecuenteid,
                        'fecha_inicio': _fechaController.text,
                        'dosis': _dosisController.text,
                        'frecuencia': _frecuenciaController.text,
                        'observaciones': _observacionesController.text,
                        'aprobado': false,
                        'doctor_aprobador': null,
                      };

                      try {
                        final response = await http.post(
                          url,
                          headers: {"Content-Type": "application/json"},
                          body: json.encode(data),
                        );

                        if (response.statusCode == 201) {
                          // LIMPIAR VARIABLES ANTES DE CERRAR EL DIÁLOGO
                          setState(() {
                            selectedTratamientofrecuenteid = null;
                          });

                          // Limpiar controladores
                          _fechaController.clear();
                          _dosisController.clear();
                          _frecuenciaController.clear();
                          _observacionesController.clear();

                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Tratamiento registrado correctamente")),
                          );
                          await _fetchTratamientofrecuente();
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
                  child: Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }



  //mostrar Tratamiento
  Future<void> _fetchTratamientofrecuente() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/api/tratamientos-cronicos/$idPaciente/'),
    );

    if (response.statusCode == 200) {
      setState(() {
        Tratamientofrecuente = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Error al cargar vacunas');
    }
  }

  Future<void> eliminarTratamientofrecuente(int idAlergiaPaciente) async {
    final url = Uri.parse('$baseUrl/usuarios/api/paciente_medicamento_cronico/$idAlergiaPaciente/');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tratamiento eliminada correctamente")),
        );
        await _fetchTratamientofrecuente(); // Actualizar la lista después de eliminar
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
  Future<void> editarTratamientofrecuente({required int id, required String dosis, required String frecuencia, required String observacion,}) async {

    final url = Uri.parse('$baseUrl//usuarios/api/paciente_medicamento_cronico/$id/');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'dosis':dosis,
          'frecuencia': frecuencia,
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
    await obtenerIdUsuarioDesdePaciente();
    if (tipoUsuario == "bebe") {
      await obtenerDatosBebes(idtipoUsuario);
    } else {
      await obtenerDatos(idtipoUsuario);
    }
    await _fetchTratamientofrecuente(); // Llamar después de que idPaciente esté disponible
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
                      'Tratamientos Frecuentes',
                      style: TextStyle(color: Colors.white,fontSize: 22),
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
                      // Botón "Añadir Tratamiento"
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: _mostrarDialogoTratamientoFrecuente, // Define tu función aquí
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
                                  "Añadir Tratamiento Frecuente",
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

                      // Lista de Tratamiento
                      Expanded(
                        child: Tratamientofrecuente.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                          itemCount: Tratamientofrecuente.length,
                          itemBuilder: (context, index) {
                            final item = Tratamientofrecuente[index];
                            final doctor = item['doctor'] == null;
                            final aprobado = item['aprobado'] == true;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.white,
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    // Título + Check
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['nombre_medicamento'],
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
                                          ),],
                                    ),
                                    const SizedBox(height: 10),

                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.blueAccent,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Center(
                                              child: FaIcon(
                                                FontAwesomeIcons.pills, // Ícono de jeringa 💉
                                                color: Colors.white,
                                                size: 35,
                                              ),
                                            ),
                                          )

                                        ),
                                        const SizedBox(width: 15),

                                        // Información con íconos
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                                                  const SizedBox(width: 4),
                                                  Text('Inicio: ${item['fecha_inicio']}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.local_hospital, size: 18, color: Colors.black54),
                                                  const SizedBox(width: 4),
                                                  Text('Dosis: ${item['dosis']}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                                ],
                                              ),
                                              if (item['frecuencia'] != null && item['frecuencia'].toString().isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.schedule, size: 18, color: Colors.black54),
                                                    const SizedBox(width: 4),
                                                    Text('Frecuencia: ${item['frecuencia']}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                                  ],
                                                ),
                                              ],
                                              if (item['observaciones'] != null && item['observaciones'].toString().isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Icon(Icons.note_alt, size: 18, color: Colors.black54),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text('Observaciones: ${item['observaciones']}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                              if (item['doctor_aprobador'] != null && item['doctor_aprobador'].toString().isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.medical_services, size: 18, color: Colors.black87),
                                                    const SizedBox(width: 4),
                                                    Text('Doctor: ${item['doctor_aprobador']}', style: const TextStyle(color: Colors.black87, fontSize: 12)),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),




                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (item['aprobado'] != true) // Solo mostrar si NO está aprobado
                                  IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.black54),
                              tooltip: 'Editar',
                              onPressed: () {
                                final dosisController = TextEditingController(text: item['dosis']);
                                final frecuenciaController = TextEditingController(text: item['frecuencia']);
                                final observacionController = TextEditingController(text: item['observaciones']);

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Editar Tratamiento Frecuente'),
                                    content: SingleChildScrollView(
                                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 10),
                                          TextField(
                                            controller: dosisController,
                                            decoration: const InputDecoration(labelText: 'Dosis'),
                                            maxLines: 2,
                                          ),
                                          TextField(
                                            controller: frecuenciaController,
                                            decoration: const InputDecoration(labelText: 'Frecuencia'),
                                            maxLines: 2,
                                          ),
                                          TextField(
                                            controller: observacionController,
                                            decoration: const InputDecoration(labelText: 'Observación'),
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          await editarTratamientofrecuente(
                                            id: item['id'],
                                            dosis: dosisController.text,
                                            frecuencia: frecuenciaController.text,
                                            observacion: observacionController.text,
                                          );
                                          setState(() {
                                            item['dosis'] = dosisController.text;
                                            item['frecuencia'] = frecuenciaController.text;
                                            item['observaciones'] = observacionController.text;
                                          });
                                        },
                                        child: const Text('Guardar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            if (item['aprobado'] != true) // Solo mostrar si NO está aprobado
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            tooltip: 'Eliminar',
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Confirmar eliminación'),
                                                  content: const Text('¿Estás seguro de que deseas eliminar este Tratamiento Frecuente?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: const Text('Cancelar'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context).pop();
                                                        await eliminarTratamientofrecuente(item['id']);
                                                      },
                                                      child: const Text('Eliminar'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    )

                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )



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

Future<List<TratamientoFrecuente>> fetchTratamientofrecuente() async {
  final url = Uri.parse('$baseUrl/usuarios/api/medicamentos/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => TratamientoFrecuente.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las vacunas');
  }
}

