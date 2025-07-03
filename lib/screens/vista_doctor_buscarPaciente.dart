import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/screens/fotoPerfil.dart';
import 'package:mifirst/screens/pantalla_doctor_mobile.dart';
import 'package:mifirst/screens/pantallapaciente.dart';
import 'package:mifirst/screens/vista_doctor_informacionpaciente.dart';
import 'package:mifirst/screens/vista_doctor_scanear_qr.dart';
import '../constans.dart';
import '../models/solicitudes.dart';

class buscarPaciente extends StatefulWidget {
  final int idusuario;
  const buscarPaciente({super.key, required this.idusuario, });

  @override
  State<buscarPaciente> createState() => _buscarPaciente();
}

class _buscarPaciente extends State<buscarPaciente> {
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
  int idDoctor = 0;
  int idSangre = 0;
  String tipoSangre = '';
  final TextEditingController _descripcionAlergiaController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();


  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _datosPaciente; // para guardar todos los datos
  bool _pacienteSeleccionado = false;

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
  Future<void> obtenerDatosDoctor(int idUsuario) async {
    final url = Uri.parse('$baseUrl/usuarios/api/doctores/por-usuario/$idUsuario/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final datos = jsonDecode(utf8.decode(response.bodyBytes));

        // Ejemplo: acceso a los campos
        idDoctor = datos['id_doctor'];


        print('ID Doctor: $idDoctor');


        // Aquí podrías actualizar el estado con setState o similar
      } else {
        print('Error al obtener doctor: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener doctor: $e');
    }
  }

  TextEditingController _comentarioController = TextEditingController();

  void _mostrarDialogoAlergia() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              scrollable: true,
              title: Text("Registrar Paciente"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Campo de cédula con lupa integrada
                  TextFormField(
                    controller: _cedulaController,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: InputDecoration(
                      labelText: "Cédula",
                      counterText: "",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          final cedula = _cedulaController.text.trim();
                          if (cedula.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Por favor ingresa una cédula')),
                            );
                            return;
                          }

                          try {
                            final url = Uri.parse('$baseUrl/usuarios/api/paciente/por-cedula/?cedula=$cedula');
                            final response = await http.get(url);
                            final data = jsonDecode(utf8.decode(response.bodyBytes));

                            if (response.statusCode == 200 && data['nombre'] != null) {
                              setStateDialog(() {
                                _datosPaciente = data;
                                _pacienteSeleccionado = false;
                              });
                            } else {
                              setStateDialog(() {
                                _datosPaciente = null;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(data['error'] ?? 'Paciente no encontrado')),
                              );
                            }
                          } catch (e) {
                            print('Error: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al buscar el paciente')),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  if (_datosPaciente != null)
                    Card(
                      elevation: 3,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${_datosPaciente!['nombre']} ${_datosPaciente!['apellido']}",
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                      ),
                                      SizedBox(height: 4),
                                      Text(" V-${_datosPaciente!['cedula']}"),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _pacienteSeleccionado,
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      _pacienteSeleccionado = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (_pacienteSeleccionado)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Paciente seleccionado',
                                  style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 12),

                  // Campo de comentario
                  TextFormField(
                    controller: _comentarioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Comentario',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: _pacienteSeleccionado
                      ? () async {
                    final comentario = _comentarioController.text.trim();
                    final pacienteId = _datosPaciente!['id_paciente'];
                    final doctorId = idDoctor;

                    final url = Uri.parse('$baseUrl/usuarios/api/doctor-paciente/');
                    final Map<String, dynamic> data = {
                      'doctor': doctorId,
                      'paciente': pacienteId,
                      'comentario': comentario,
                    };

                    try {
                      final response = await http.post(
                        url,
                        headers: {"Content-Type": "application/json"},
                        body: json.encode(data),
                      );

                      if (response.statusCode == 201) {
                        // ✅ Limpiar variables
                        setStateDialog(() {
                          _cedulaController.clear();
                          _comentarioController.clear();
                          _datosPaciente = null;
                          _pacienteSeleccionado = false;
                        });

                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Solicitud enviada correctamente")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error al guardar: ${response.statusCode}")),
                        );
                        print('Respuesta del servidor: ${response.body}');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error al conectar con el servidor")),
                      );
                      print('Error: $e');
                    }
                  }
                      : null,
                  child: Text("Guardar"),
                ),

              ],
            );
          },
        );
      },
    );
  }

  List<SolicitudDoctorPaciente> solicitudes = [];

  Future<void> _fetchSolicitudes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/api/solicitudes/doctor/$idDoctor/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        solicitudes = data.map((json) => SolicitudDoctorPaciente.fromJson(json)).toList();
      });
    } else {
      throw Exception('Error al cargar las solicitudes');
    }
  }

  int _selectedIndex = 1; // Ya estamos en la pestaña de doctores

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return; // Ya está en Doctores, no hace nada

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorMobileScreen(idusuario: widget.idusuario),
        ),
      );
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PacienteScreen(idusuario: widget.idusuario),
        ),
      );
    }else {
      setState(() {
        _selectedIndex = index;
      });
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
    await obtenerDatosDoctor(widget.idusuario);
    await _fetchSolicitudes(); // Llamar después de que idPaciente esté disponible
  }



  @override
  Widget build(BuildContext context) {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor:Colors.white,
            indicatorColor: Colors.blue.shade900,
            labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
              if (states.contains(MaterialState.selected)) {
                return TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600);
              }
              return TextStyle(color: Colors.grey);
            }),
            iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
              if (states.contains(MaterialState.selected)) {
                return IconThemeData(color: Colors.white);
              }
              return IconThemeData(color: Colors.grey);
            }),
          ),
        ),
        child: NavigationBar(
          height: 70,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_pin),
              selectedIcon: Icon(Icons.person_pin),
              label: 'Paciente',
            ),
            NavigationDestination(
              icon: Icon(Icons.switch_account_outlined),
              selectedIcon: Icon(Icons.switch_account),
              label: 'Perfil Pac',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(

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
                                "Dr.$nombreUsuario $apellidoUsuario",
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
                      'Pacientes Registrados',
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
                    color: Colors.grey[200], // Fondo gris claro
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      // Botón de "Añadir alergias" en la parte superior derecha
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            // Botón 1: Registrar un Paciente
                            Expanded(
                              child: GestureDetector(
                                onTap: _mostrarDialogoAlergia,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_circle_outline_sharp, color: Colors.white),
                                      SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          "Registrar",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12), // Espacio entre botones

                            // Botón 2: Escanear QR
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => QrScanScreen(iddoctor: idDoctor,)),
                                  );
                                },
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.qr_code_scanner, color: Colors.white),
                                      SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          "Escanear",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12,),
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
                          padding: const EdgeInsets.all(5),
                          child: solicitudes.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                            itemCount: solicitudes.length,
                            itemBuilder: (context, index) {
                              final item = solicitudes[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.white,
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Ícono alineado
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child:  Center(
                                          child: Icon(
                                            (item.pacienteCedula == 'No tiene, es hijo' || item.pacienteCedula.isEmpty)
                                                ? Icons.child_care  // 👶 Si no tiene cédula → es un bebé
                                                : Icons.person,     // 👤 Si tiene cédula → es un paciente normal
                                            size: 28,
                                            color: Colors.black,
                                          ),

                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Información del paciente
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${item.pacienteNombre.toString().toUpperCase()} ${item.pacienteApellido.toString().toUpperCase()}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text('Cédula: ${item.pacienteCedula}',
                                               style: const TextStyle(color: Colors.black54)),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Estado: ${item.estado}',
                                                  style: TextStyle(
                                                    color: item.estado == 'pendiente'
                                                        ? Colors.orange[700]
                                                        : item.estado == 'aceptado'
                                                        ? Colors.green[700]
                                                        : item.estado == 'rechazado'
                                                        ? Colors.red[700]
                                                        : Colors.black54,
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: item.estado == 'aceptado'
                                                      ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => DetallePacienteScreen(idusuariopac: item.paciente,nombre: nombreUsuario, apellido: apellidoUsuario,idusuariodoc:idDoctor ,),
                                                      ),
                                                    );
                                                  }
                                                      : null, // Deshabilitado si no está aceptado
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: item.estado == 'aceptado'
                                                        ? Colors.blue
                                                        : Colors.grey[300],
                                                    foregroundColor: item.estado == 'aceptado'
                                                        ? Colors.white
                                                        : Colors.black45,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    minimumSize: const Size(40, 30),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                  child: const Icon(
                                                    Icons.visibility,
                                                    size: 20,
                                                  ),
                                                ),

                                              ],
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
              )









            ],
          ),
        ),
      ),
    );
  }
}



