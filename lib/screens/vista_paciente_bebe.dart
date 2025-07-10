import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mifirst/screens/fotoPerfil.dart';
import 'package:mifirst/screens/pantalla_paciente_bebe.dart';
import 'package:mifirst/screens/pantallapaciente.dart';
import 'package:mifirst/screens/vista_paciente_pacientedoctor.dart';
import '../constans.dart';
import '../models/bebe.dart';
import '../models/grupoSanguineo.dart';
import '../models/solicitudes.dart';
import 'Paciente_qr.dart';

class VistaBebe extends StatefulWidget {
  final int idusuario;
  const VistaBebe({super.key, required this.idusuario, });

  @override
  State<VistaBebe> createState() => _VistaBebe();
}

class _VistaBebe extends State<VistaBebe> {
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
  List<PerfilBebe> bebes = [];


  int? selectedGrupoSanguineo; // Para almacenar la selección del dropdown

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
   DateTime? fechaNacimiento;
  final TextEditingController fechaController = TextEditingController();
  String? _sexoSeleccionado;
  final List<String> _sexos = ['M', 'F'];
  String? fechaNacimientoApi; // formato yyyy-MM-dd


  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    fechaController.dispose();
    super.dispose();
  }
  void _limpiarCampos() {
    _nameController.clear();
    _lastNameController.clear();
    fechaController.clear();
    _sexoSeleccionado = null;
    selectedGrupoSanguineo = null;
    setState(() {}); // Para actualizar los dropdowns
  }

  final _formKey = GlobalKey<FormState>();
  Future<void> _fetchBebesPorResponsable(int responsableId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/api/bebes/responsable/$responsableId/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        bebes = data.map((json) => PerfilBebe.fromJson(json)).toList();
      });
    } else {
      throw Exception('Error al cargar los perfiles de bebé');
    }
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



  void _mostrarDialogoBebes() {


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true, // Para evitar overflow vertical
              title: Text("Añadir Hijo"),
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
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Inserte su Nombre, por favor';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  label:const Text('Nombre'),
                                  hintText: ' Inserte su Nombre',
                                  hintStyle: const TextStyle(
                                    color: Colors.black26,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide:const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10), // Espacio entre los dos campos
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Inserte su Apellido, por favor';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  label: const Text('Apellido'),
                                  hintText: 'Inserte su Apellido',
                                  hintStyle: const TextStyle(
                                    color: Colors.black26,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Campo de Fecha de Nacimiento con Calendario
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: fechaController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Fecha de Nacimiento',
                            hintText: 'Selecciona tu fecha',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime? fechaSeleccionada = await showDatePicker(
                              context: context,
                              initialDate: fechaNacimiento ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );

                            if (fechaSeleccionada != null) {
                              setState(() {
                                fechaNacimiento = fechaSeleccionada;

                                // Mostrar al usuario: dd/MM/yyyy
                                fechaController.text = DateFormat('dd/MM/yyyy').format(fechaSeleccionada);

                                // Guardar para enviar al backend: yyyy-MM-dd
                                fechaNacimientoApi = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);
                              });
                            }

                          },
                        ),
                      ),
                      //sexo
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          value: _sexoSeleccionado,
                          decoration: InputDecoration(
                            labelText: 'Sexo',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _sexos.map((sexo) {
                            return DropdownMenuItem<String>(
                              value: sexo,
                              child: Text(sexo == 'M' ? 'Masculino' : 'Femenino'),
                            );
                          }).toList(),
                          onChanged: (valor) {
                            setState(() {
                              _sexoSeleccionado = valor;
                            });
                          },
                        ),
                      ),
                      // sangre
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<List<GrupoSanguineo>>(
                          future: fetchGruposSanguineos(),  // Llamar a la función para obtener los datos
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Text('No hay grupos sanguíneos disponibles');
                            } else {
                              List<GrupoSanguineo> gruposSanguineos = snapshot.data!;

                              return DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Grupo Sanguíneo',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0), // 👈 Borde redondeado
                                  ),
                                ),
                                value: selectedGrupoSanguineo, // Variable para almacenar la selección
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedGrupoSanguineo = newValue;
                                    print('ID de Grupo Sanguíneo seleccionado: $selectedGrupoSanguineo');
                                  });
                                },
                                items: gruposSanguineos.map((GrupoSanguineo grupo) {
                                  return DropdownMenuItem<int>(
                                    value: grupo.idSangre, // Guarda el ID
                                    child: Text(grupo.tipoSangre), // Muestra el tipo de sangre
                                  );
                                }).toList(),
                              );
                            }
                          },
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
                    final url = Uri.parse('$baseUrl/usuarios/api/bebes/');

                    // Validación básica: peso y altura obligatorios
                    if (_nameController.text.isEmpty ||
                        _lastNameController.text.isEmpty ||
                        fechaNacimiento == null ||
                        _sexoSeleccionado == null ||
                        selectedGrupoSanguineo == null
                        ) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Por favor completa todos los campos obligatorios"),
                        ),
                      );
                      return;
                    }



                    final Map<String, dynamic> data = {
                      "nombre": _nameController.text,
                      "apellido": _lastNameController.text,
                      "fecha_nacimiento": fechaNacimientoApi,  // debe estar en formato "YYYY-MM-DD"
                      "sexo": _sexoSeleccionado,  // por ejemplo, "M" o "F"
                      "responsable_id": widget.idusuario,  // un int, id del usuario responsable
                      "id_sangre": selectedGrupoSanguineo,  // un int, id del grupo sanguíneo seleccionado
                    };


                    try {
                      final response = await http.post(
                        url,
                        headers: {"Content-Type": "application/json"},
                        body: json.encode(data),
                      );

                      if (response.statusCode == 201) {
                        _limpiarCampos();
                        Navigator.of(context).pop(); // cerrar el diálogo
                        await _fetchBebesPorResponsable(widget.idusuario); // 🔁 recargar los signos vitales
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Signos vitales guardados correctamente")),
                        );
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
  }

  List<SolicitudDoctorPaciente> solicitudes = [];



  int _selectedIndex = 2; // Ya estamos en la pestaña de doctores

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return; // Ya está en Doctores, no hace nada

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PacienteScreen(idusuario: widget.idusuario),
        ),
      );
    }
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolititudPaciente(idusuario: widget.idusuario),
        ),
      );
    }
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PacienteScreenqr(idusuario: widget.idusuario, id_paciente: idPaciente,),
        ),
      );
    }
    else {
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
    await _fetchBebesPorResponsable(widget.idusuario);
}



  @override
  Widget build(BuildContext context) {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.indigo,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor:Colors.white,
            indicatorColor: Colors.indigo,
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
              icon: Icon(Icons.verified_user_outlined), // Nuevo ícono
              selectedIcon: Icon(Icons.verified_user), // Ícono cuando está seleccionado
              label: 'Doctores',
            ),
            NavigationDestination(
              icon: Icon(Icons.child_care_rounded),
              selectedIcon: Icon(Icons.child_care_rounded),
              label: 'Hijos',
            ),
            NavigationDestination(
              icon: Icon(Icons.qr_code),
              selectedIcon: Icon(Icons.qr_code_outlined),
              label: 'Qr',
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
                              color: Colors.indigoAccent,
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
                                "Pac. $nombreUsuario $apellidoUsuario",
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
                      'Hijos Registrados',
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
                      Align(
                        alignment: Alignment.center, // Asegura que quede arriba y a la derecha
                        child: GestureDetector(
                          onTap: _mostrarDialogoBebes,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1A237E), // Índigo oscuro
                                    Color(0xFF3F51B5), // Índigo medio
                                    Color(0xFF7986CB), // Índigo claro


                                  ]),
                              borderRadius:  BorderRadius.circular(12),

                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // Evita que ocupe todo el ancho
                              children: [
                                const Icon(
                                  Icons.add_circle_outline_sharp,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Registar un Hijo",
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
                          child: bebes.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                            itemCount: bebes.length,
                            itemBuilder: (context, index) {
                              final bebe = bebes[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white,
                                elevation: 1,
                                shadowColor: Colors.black.withOpacity(0.05),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        // Avatar elegante
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.indigo.shade400,
                                                Colors.blueAccent,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.indigo.withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.child_care_rounded,
                                              size: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 18),

                                        // Información del bebé
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${bebe.nombre} ${bebe.apellido}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 17,
                                                  color: Colors.black87,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),

                                              const SizedBox(height: 8),

                                              Text(
                                                '${bebe.fechaNacimiento.toLocal().toString().split(' ')[0]} • ${bebe.sexo == "M" ? "Masculino" : "Femenino"}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Botón minimalista
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                              width: 1,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => PacientebbScreen(idusuario: bebe.id,)),
                                              );
                                            },

                                            icon: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 16,
                                              color: Colors.indigoAccent,
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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

Future<List<GrupoSanguineo>> fetchGruposSanguineos() async {
  final response = await http.get(Uri.parse('$baseUrl/usuarios/api/grupos-sanguineos/'));

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    // Si la solicitud es exitosa, parsea los datos
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => GrupoSanguineo.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar los grupos sanguíneos');
  }
}

