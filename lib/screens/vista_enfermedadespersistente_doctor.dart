import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/screens/fotoPerfil.dart';
import '../constans.dart';
import '../models/enfermedadespersistente.dart';

class VistaEnfermedadPersistentedoctor extends StatefulWidget {
  final int id_paciente;
  final String nombre;
  final String apellido;
  final int idusuariodoc;

  const VistaEnfermedadPersistentedoctor({super.key, required this.id_paciente,required this.nombre, required this.apellido, required this.idusuariodoc});

  @override
  State<VistaEnfermedadPersistentedoctor> createState() => _VistaEnfermedadPersistentedoctor();
}

class _VistaEnfermedadPersistentedoctor extends State<VistaEnfermedadPersistentedoctor> {
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
  String? nivelSeleccionado;
  String? tipoSeleccionado= 'Endocrina';
  int? selectedEnfermedadesPersistenteId;
  String? filtroActivoEnfermedad;
  List<dynamic> EnfermedadesPersistente = [];  // Lista para almacenar las alergias
  bool isLoadingEnfermedades = false;
  bool hasError = false;
  String sexo = '';
  String tipoUsuario='';
  int idtipoUsuario=0;

  final TextEditingController _descripcionEnfermdadController = TextEditingController();

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

  void _mostrarDialogoEnfermedades() {
    Future<List<EnfermedadPersistente>> futureEnfermedadesPersistente = fetchEnfermedadesPersistente(tipoSeleccionado!);
    final TextEditingController _fechaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true, // Para evitar overflow vertical
              title: Text("Añadir Enfermedad persistente"),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85, // Ajustar el ancho máximo
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
                              selectedEnfermedadesPersistenteId= null;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Tipo de alergia",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                            ),
                          ),
                          items: ['Endocrina', 'Cardiovascular', 'Respiratoria', 'Neurologica','Psiquiatrica','Gastrointestinal','Reumatologica','Renal','Hematologica','Infectologia']


                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

                      // Lista de alergias según tipo
                      FutureBuilder<List<EnfermedadPersistente>>(
                        future: futureEnfermedadesPersistente,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No hay Enfermedad Persistente disponibles');
                          } else {
                            List<EnfermedadPersistente> enfermedades = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: DropdownButtonFormField<int>(
                                isExpanded: true, // ← necesario para permitir texto largo
                                decoration: InputDecoration(
                                  labelText: 'Enfermedad Persistente',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                value: selectedEnfermedadesPersistenteId,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedEnfermedadesPersistenteId = newValue;
                                  });
                                },
                                selectedItemBuilder: (BuildContext context) {
                                  return enfermedades.map((e) {
                                    return Text(
                                      e.nombre,
                                      overflow: TextOverflow.ellipsis, // ← recorta si es muy largo
                                      softWrap: false,
                                    );
                                  }).toList();
                                },
                                items: enfermedades.map((e) {
                                  return DropdownMenuItem<int>(
                                    value: e.id,
                                    child: Text(e.nombre), // ← aquí se muestra completo en el menú
                                  );
                                }).toList(),
                              ),
                            );
                          }
                        },
                      ),
                      TextField(
                        controller: _fechaController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Fecha de diagnostico',
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



                      // Descripción
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _descripcionEnfermdadController,
                          decoration: InputDecoration(
                            labelText: "Descripción",
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
                TextButton(
                  onPressed: () async {
                    if (selectedEnfermedadesPersistenteId != null ) {
                      final url = Uri.parse('$baseUrl/usuarios/api/pacientes_enfermedades/');
                      final Map<String, dynamic> data = {
                        'paciente': idPaciente,
                        'enfermedad': selectedEnfermedadesPersistenteId,
                        'fecha_diagnostico': _fechaController.text,
                        'observacion': _descripcionEnfermdadController.text,
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
                            SnackBar(content: Text("Enfermedad persistente guardada correctamente")),
                          );
                          await _fetchEnfermedadesPersistente();
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



  Future<void> _fetchEnfermedadesPersistente({String? tipo}) async {
    setState(() {
      isLoadingEnfermedades = true;
      hasError = false;
    });

    try {
      final url = (tipo == null || tipo.isEmpty)
          ? '$baseUrl/usuarios/api/enfermedades/$idPaciente/paciente/'
          : '$baseUrl/usuarios/api/enfermedades/$idPaciente/paciente/?tipo=$tipo';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          EnfermedadesPersistente = jsonDecode(utf8.decode(response.bodyBytes));
        });
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoadingEnfermedades = false;
      });
    }
  }

  IconData _getIcon(String tipo) {
    switch (tipo) {
      case 'Endocrina':
        return Icons.water_drop;
      case 'Cardiovascular':
        return Icons.favorite;
      case 'Respiratoria':
        return Icons.air;
      case 'Neurológica':
        return Icons.memory;
      case 'Psiquiátrica':
        return Icons.psychology;
      case 'Gastrointestinal':
        return Icons.lunch_dining;
      case 'Reumatológica':
        return Icons.accessibility_new;
      case 'Renal':
        return Icons.opacity;
      case 'Hematológica':
        return Icons.bloodtype;
      case 'Infecciosa':
        return Icons.sick;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getColor(String tipo) {
    switch (tipo) {
      case 'Endocrina':
        return Colors.purple;
      case 'Cardiovascular':
        return Colors.red;
      case 'Respiratoria':
        return Colors.lightBlue;
      case 'Neurológica':
        return Colors.indigo;
      case 'Psiquiátrica':
        return Colors.deepOrange;
      case 'Gastrointestinal':
        return Colors.brown;
      case 'Reumatológica':
        return Colors.teal;
      case 'Renal':
        return Colors.blueGrey;
      case 'Hematológica':
        return Colors.pink;
      case 'Infecciosa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> eliminarEnfermedadesPersistente(int idAlergiaPaciente) async {
    final url = Uri.parse('$baseUrl/usuarios/api/pacientes_enfermedades/$idAlergiaPaciente/');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Alergia eliminada correctamente")),
        );
        await _fetchEnfermedadesPersistente(); // Actualizar la lista después de eliminar
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
  Future<void> editarEnfermedadesPersistente({required int id, required String observacion,}) async {

    final url = Uri.parse('$baseUrl/usuarios/api/pacientes_enfermedades/$id/');

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
        print('Enfermedad actualizada exitosamente');
      } else {
        print('Error al editar Enfermedad: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Excepción al editar Enfermedad: $e');
    }
  }
  Future<void> aprobarEnfermedad(int idAlergia, bool aprobado) async {
    final url = Uri.parse('$baseUrl/usuarios/api/pacientes_enfermedades/$idAlergia/');

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
        print('Enfermedad actualizada correctamente.');
      } else {
        print('Error al actualizar la Enfermedad: ${response.statusCode}');
        print('Cuerpo: ${response.body}');
      }
    } catch (e) {
      print('Excepción al actualizar la Enfermedad: $e');
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
    await _fetchEnfermedadesPersistente(); // Llamar después de que idPaciente esté disponible
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
                Color(0xFF0D47A1),
                Color(0xFF1976D2), // Turquesa,
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
                      'Enfermedades Persistentes',
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
                      // Botón de "Añadir enfermedad"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón "Añadir enfermedad" centrado
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: _mostrarDialogoEnfermedades,
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
                                        "Añadir enfermedad",
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

                          // Botón "Filtrar por tipo" a la derecha
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
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
                            child: PopupMenuButton<String>(
                              color: Colors.white,
                              icon: const Icon(Icons.filter_list, color: Colors.white),
                              tooltip: "Filtrar por tipo",
                              onSelected: (tipoSeleccionado) {
                                setState(() {
                                  filtroActivoEnfermedad = tipoSeleccionado == '' ? null : tipoSeleccionado;
                                });

                                if (tipoSeleccionado == '') {
                                  _fetchEnfermedadesPersistente(); // sin filtro
                                } else {
                                  _fetchEnfermedadesPersistente(tipo: tipoSeleccionado);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: '', child: Text('Mostrar todas')),
                                const PopupMenuItem(value: 'Endocrina', child: Text('Endocrina')),
                                const PopupMenuItem(value: 'Cardiovascular', child: Text('Cardiovascular')),
                                const PopupMenuItem(value: 'Respiratoria', child: Text('Respiratoria')),
                                const PopupMenuItem(value: 'Neurologica', child: Text('Neurológica')),
                                const PopupMenuItem(value: 'Psiquiatrica', child: Text('Psiquiátrica')),
                                const PopupMenuItem(value: 'Gastrointestinal', child: Text('Gastrointestinal')),
                                const PopupMenuItem(value: 'Reumatologica', child: Text('Reumatológica')),
                                const PopupMenuItem(value: 'Renal', child: Text('Renal')),
                                const PopupMenuItem(value: 'Hematologica', child: Text('Hematológica')),
                                const PopupMenuItem(value: 'Infectologia', child: Text('Infectología')),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      // Lista de enfermedades persistentes
                      Expanded(child: isLoading
                          ? const Center(
                        child: CircularProgressIndicator(),
                      )
                          : hasError
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            const Text(
                              'No se pudo conectar con el servidor.',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text("Reintentar"),
                              onPressed: () => _fetchEnfermedadesPersistente(tipo: filtroActivoEnfermedad),
                            ),
                          ],
                        ),
                      )
                          : EnfermedadesPersistente.isEmpty
                          ? Center(
                        child: Text(
                          filtroActivoEnfermedad == null || filtroActivoEnfermedad == ''
                              ? 'No hay Enfermedades registradas.'
                              : 'No se encontraron Enfermedades de tipo "$filtroActivoEnfermedad".',
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                          : ListView.builder(
                        itemCount: EnfermedadesPersistente.length,
                        itemBuilder: (context, index) {
                          final item = EnfermedadesPersistente[index];
                          String tipo = EnfermedadesPersistente[index]['Tipo_enfermedad'];
                          final aprobado = EnfermedadesPersistente[index]['aprobado'] == true;
                          final doctor = EnfermedadesPersistente[index]['doctor_aprobador'];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.white,
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          EnfermedadesPersistente[index]['nombre_enfermedad'] ?? '',
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

                                  /// Contenido principal con ícono e información
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: _getColor(tipo),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getIcon(tipo),
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            /// Tipo de enfermedad
                                            Row(
                                              children: [
                                                const Icon(Icons.category, size: 18, color: Colors.black54),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Tipo: ${EnfermedadesPersistente[index]['Tipo_enfermedad'] ?? 'N/A'}',
                                                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Diagnóstico: ${EnfermedadesPersistente[index]['fecha_diagnostico'] ?? 'N/A'}',
                                                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),



                                            /// Observación (si hay)
                                            if (EnfermedadesPersistente[index]['observacion'] != null &&
                                                EnfermedadesPersistente[index]['observacion'].toString().isNotEmpty)
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons.note_alt, size: 18, color: Colors.black45),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      'Observación: ${EnfermedadesPersistente[index]['observacion']}',
                                                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            const SizedBox(height: 4),

                                            /// Doctor aprobador (si hay)
                                            if (aprobado && doctor != null && doctor.toString().isNotEmpty)
                                              Row(
                                                children: [
                                                  const Icon(Icons.medical_services, size: 18, color: Colors.black54),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Doctor: $doctor',
                                                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Botones abajo si NO está aprobado
                                  if (!aprobado)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
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
                                                  content: const Text('¿Estás seguro de que deseas aprobar esta Enfermedad?'),
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
                                                await aprobarEnfermedad(item['id'],true);
                                                setState(() {
                                                  item['aprobado'] = true;
                                                });
                                              }
                                            },
                                          ),
                                          TextButton.icon(
                                            icon: const Icon(Icons.edit, color: Colors.black54),
                                            label: const Text(''),
                                            onPressed: () {
                                              final TextEditingController observacionController = TextEditingController(
                                                text: EnfermedadesPersistente[index]['observacion'],
                                              );

                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Editar enfermedad'),
                                                  content: TextField(
                                                    controller: observacionController,
                                                    decoration: const InputDecoration(labelText: 'Observación'),
                                                    maxLines: 2,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: const Text('Cancelar'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context).pop();
                                                        await editarEnfermedadesPersistente(
                                                          id: EnfermedadesPersistente[index]['id'],
                                                          observacion: observacionController.text,
                                                        );
                                                        setState(() {
                                                          EnfermedadesPersistente[index]['observacion'] = observacionController.text;
                                                        });
                                                      },
                                                      child: const Text('Guardar'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          TextButton.icon(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            label: const Text(''),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Confirmar eliminación'),
                                                  content: const Text('¿Estás seguro de que deseas eliminar esta enfermedad?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: const Text('Cancelar'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context).pop();
                                                        await eliminarEnfermedadesPersistente(
                                                          EnfermedadesPersistente[index]['id'],
                                                        );
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

Future<List<EnfermedadPersistente>> fetchEnfermedadesPersistente(String tipo) async {
  final url = Uri.parse('$baseUrl/usuarios/api/enfermedades-persistentes/?tipo=$tipo');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    // Si la solicitud es exitosa, parsea los datos
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => EnfermedadPersistente.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las enfermedades');
  }
}
