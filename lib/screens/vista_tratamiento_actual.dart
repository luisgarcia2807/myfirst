import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/screens/Vista_Ver_seguimiento.dart';
import 'package:mifirst/screens/vista_seguimiento.dart';
import '../models/tratamientoActual.dart';
import '../models/tratamientoFrecuente.dart';
import '../models/tratamientoFrecuente.dart';
import '../models/vacuna.dart';
import '../constans.dart';

class VistaTratamientoActualmente extends StatefulWidget {
  final int idusuario;
  const VistaTratamientoActualmente({super.key, required this.idusuario});

  @override
  State<VistaTratamientoActualmente> createState() => _VistaTratamientoActualmente();
}

class _VistaTratamientoActualmente extends State<VistaTratamientoActualmente> {
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
  void _mostrarDialogoTratamientoFrecuente() {
    DateTime? fechaSeleccionada;
    int? selectedTratamientofrecuenteid;

    final TextEditingController _fechaController = TextEditingController();
    final TextEditingController _fechafinController = TextEditingController();
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
                    Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: tipoSeleccionado,
                          hint: Text('Tipo de medicamento'),
                          onChanged: (String? newTipo) {
                            setState(() {
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
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        FutureBuilder<List<TratamientoFrecuente1>>(
                          future: tipoSeleccionado != null
                              ? fetchTratamientofrecuente(tipoSeleccionado!)
                              : Future.value([]),
                          builder: (context, snapshot) {
                            List<TratamientoFrecuente1> tratamientofrecuente = snapshot.data ?? [];

                            return DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                labelText: 'Medicamento',
                                border: OutlineInputBorder(),
                              ),
                              isExpanded: true,
                              value: selectedTratamientofrecuenteid,
                              onChanged: snapshot.hasData && tratamientofrecuente.isNotEmpty
                                  ? (int? newValue) {
                                setState(() {
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
                      ],
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
                    TextField(
                      controller: _fechafinController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha de Finalizacion',
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
                            _fechafinController.text = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                          });
                        }
                      },
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
                        _frecuenciaController.text.isNotEmpty) {

                      final url = Uri.parse('$baseUrl/usuarios/api/tratamiento/nuevo/');
                      final Map<String, dynamic> data = {
                        'paciente': idPaciente,
                        'medicamento': selectedTratamientofrecuenteid,
                        'fecha_inicio': _fechaController.text,
                        'fecha_fin': _fechafinController.text,
                        'frecuencia': _frecuenciaController.text,
                        'descripcion': _observacionesController.text,
                        'doctor': null,
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
                            const SnackBar(content: Text("Tratamiento registrado correctamente")),
                          );
                          await _fetchTratamientofrecuente();
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
  }



  //mostrar Tratamiento
  Future<void> _fetchTratamientofrecuente() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/api/paciente/$idPaciente/tratamientos/'),
    );
    if (response.statusCode == 200) {
      setState(() {
        Tratamientofrecuente = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Error al cargar vacunas');
    }
  }

  Future<void> finalizarTratamiento(int idTratamiento) async {
    final url = Uri.parse('$baseUrl/usuarios/api/tratamiento/$idTratamiento/finalizar/');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Si deseas enviar fecha_fin explícita, descomenta esto:
          // 'fecha_fin': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tratamiento finalizado correctamente ✅")),
        );
        await _fetchTratamientofrecuente(); // Recarga la lista
      } else {
        print('Error en la respuesta: ${response.statusCode}');
        print('Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudo finalizar. Código: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print('Excepción atrapada: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión con el servidor ❌")),
      );
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
    await obtenerDatos(); // no es necesario await si no depende de datos
    await obtenerDatosPacienteSangre(widget.idusuario);
    await _fetchTratamientofrecuente(); // Llamar después de que idPaciente esté disponible
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
                              "GESTOR DE TRATAMIENTO ACTUAL",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:16,
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
                                  "Añadir Tratamiento ",
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

                                    // Título + Check
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(width: 75,),
                                        Expanded(
                                          child: Text(
                                            item['nombre_medicamento'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        if (item['finalizado'] == true)
                                          const Icon(Icons.verified, color: Colors.green, size: 26),
                                        if (item['doctor'] != null)
                                          const Icon(Icons.verified, color: Colors.blue, size: 26),

                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Ícono de jeringa más abajo
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

                                        // Información del tratamiento
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Inicio: ${item['fecha_inicio']}',
                                                  style: const TextStyle(color: Colors.black54)),
                                              Text('Finaliza: ${item['fecha_fin']}',
                                                  style: const TextStyle(color: Colors.black54)),
                                              Text('Dosis: ${item['dosis']} - ${item['via']}',
                                                  style: const TextStyle(color: Colors.black54)),
                                              if (item['frecuencia'] != null && item['frecuencia'].toString().isNotEmpty)
                                                Text('Frecuencia: ${item['frecuencia']}',
                                                  style: const TextStyle(color: Colors.black54)),
                                              if (item['observaciones'] != null && item['observaciones'].toString().isNotEmpty)
                                                Text('Observaciones: ${item['observaciones']}',
                                                    style: const TextStyle(color: Colors.black54)),
                                              if (item['doctor'] != null &&
                                                  item['doctor'].toString().isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text('Doctor: ${item['nombre_doctor']}',
                                                      style: const TextStyle(color: Colors.black87)),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),



                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (item['doctor'] == null && item['finalizado'] == false ) // Solo mostrar si NO está aprobado
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.black54),
                                            tooltip: 'Editar',
                                            onPressed: () {
                                              final dosisController = TextEditingController(text: item['dosis']);
                                              final frecuenciaController = TextEditingController(text: item['frecuencia']);
                                              final observacionController = TextEditingController(text: item['observacion']);

                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Editar Tratamiento Actual'),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(height: 10),

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
                                          icon: const Icon(Icons.visibility, color: Colors.blueGrey),
                                          tooltip: 'Ver seguimientos',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SeguimientoListPage(tratamientoId: item['id'],)
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle, color: Colors.blueGrey),
                                          tooltip: 'Añadir seguimiento',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SeguimientoPage(idPaciente: idPaciente,idtratamiento: item['id'],),
                                              ),
                                            );
                                          },
                                        ),

                                        if (item['finalizado'] == false ) // Solo mostrar si NO está aprobado
                                          IconButton(
                                            icon: const Icon(Icons.check_circle, color: Colors.grey),
                                            tooltip: 'Finalizar tratamiento',
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Confirmar finalización'),
                                                  content: const Text('¿Estás seguro de que deseas finalizar este tratamiento actual?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: const Text('Cancelar'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context).pop();
                                                        await finalizarTratamiento(item['id']);
                                                      },
                                                      child: const Text('Finalizar'),
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

