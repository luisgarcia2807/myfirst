import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mifirst/screens/iniciar_sesion.dart';
import 'package:mifirst/screens/pantallapaciente.dart';
import 'package:mifirst/widgets/custom_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/Centro_medico.dart';
import '../models/especialidades_doctor.dart';
import '../models/grupoSanguineo.dart';
import '../theme/theme.dart';

class SignUpScreendoctor extends StatefulWidget {
  const SignUpScreendoctor ({super.key});

  @override
  State<SignUpScreendoctor> createState()=> _SignUpScreenStatedoctor();
}


class _SignUpScreenStatedoctor extends State<SignUpScreendoctor>{
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData=true;
  int? selectedCentroMedico;
  int? selectedEspecialidad;
  int? selectedGrupoSanguineo;



  // para guardar nombre, apellido, email, cedula y contrasena
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _numeroLicencia = TextEditingController();// Controlador para la cédula

  // Lista de prefijos disponibles en Venezuela
  final List<String> prefijosCedula = ["V", "E"];  // Prefijos "V" para venezolanos y "E" para extranjeros
  String? prefijoce = "V"; // Valor predeterminado
  final TextEditingController _numeroCedulaController = TextEditingController(); // Controlador para el número de cédula

  // Lista de prefijos disponibles en Venezuela
  final List<String> prefijosVenezuela = ["0412", "0414", "0416", "0424", "0426"];

// Variables para almacenar la selección
  String? prefijoSeleccionado = "0414"; // Valor predeterminado
  final TextEditingController _numeroController = TextEditingController();


  // Variables para la fecha de nacimiento
  DateTime? fechaNacimiento;
  final TextEditingController fechaController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cedulaController.dispose();
    fechaController.dispose();
    _numeroController.dispose();
    _numeroLicencia.dispose();

    super.dispose();
  }
  String convertirFecha(String fecha) {
    List<String> partesFecha = fecha.split('/');
    String dia = partesFecha[0];
    String mes = partesFecha[1];
    String year = partesFecha[2];

    return '$year-${mes.padLeft(2, '0')}-${dia.padLeft(2, '0')}'; // Formato 'YYYY-MM-DD'
  }
  Future<void> registrarUsuario() async {
    String nombre = _nameController.text;       // Extraemos el texto del controlador
    String apellido = _lastNameController.text; // Extraemos el texto del controlador
    String email = _emailController.text;       // Extraemos el texto del controlador
    String contrasena = _passwordController.text; // Extraemos el texto del controlador
    String cedula = _cedulaController.text;     // Extraemos el texto del controlador
    String licencia = _numeroLicencia.text;     // Extraemos el texto del controlador
    if (!_formSignupKey.currentState!.validate()) {
      return;
    }

    if (!agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe aceptar los términos y condiciones')),
      );
      return;
    }
    // Convertir la fecha seleccionada en formato 'DD/MM/YYYY' a 'YYYY-MM-DD'
    String fechaFormateada = convertirFecha(fechaController.text);

    // La URL de tu API Django para registrar el usuario
    final url = Uri.parse('http://192.168.0.100:8000/usuarios/api/usuarios/'); // Cambia la IP si es necesario
// Concatenar el prefijo seleccionado con el número de cédula ingresado
    String cedulaCompleta = "$prefijoce${_numeroCedulaController.text}";
    String telefonoCompleto = "$prefijoSeleccionado${_numeroController.text}";


    final Map<String, dynamic> data = {
      'nombre': nombre,
      'apellido':apellido,
      'cedula':cedulaCompleta,
      'email': email,
      'telefono':telefonoCompleto, // Envia 'contrasena' según la configuración en Django
      'fecha_nacimiento': fechaFormateada,
      'password': contrasena,
      "numero_licencia":licencia,
      "id_rol": 2,
      "id_especialidad": selectedEspecialidad,
      "id_sangre":selectedGrupoSanguineo,
      "id_centromedico": selectedCentroMedico

    };

    try {
      // Enviar una solicitud POST con los datos del usuario
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        // Si la solicitud fue exitosa, muestra un mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro exitoso')),
        );

        // Limpiar los campos después del registro
        _nameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _cedulaController.clear(); // Limpiar la cédula
        fechaController.clear();
        _numeroController.clear();
        setState(() {
          fechaNacimiento = null;
          prefijoSeleccionado = "0414";
          prefijoce = "V";
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (e) =>  PacienteScreen(nombre: _nameController.text),
          ),
        );
      } else {
        // Si ocurre un error, muestra el mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en el registro: ${response.body}')),
        );
      }
    } catch (e) {
      // Si hay un error de conexión, muestra el error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  CustomScaffold(

      child: Column(
        children: [
          const Expanded(
            flex:1,
            child: SizedBox(
              height: 10,),),
          Expanded(
            flex:7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                    key: _formSignupKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //titulo
                        Text('REGISTRARSE COMO DOCTOR',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme.primary
                          ),),
                        const SizedBox(height: 20.0),
                        // nombre y apellido
                        Row(
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
                        // Cédula (nuevo campo)
                        const SizedBox(height: 20.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Selector de prefijo
                            SizedBox(
                              width: 80, // Ajusta este valor para hacer el prefijo más pequeño
                              child: DropdownButtonFormField<String>(
                                value: prefijoce,
                                decoration: InputDecoration(
                                  labelText: 'Prefijo',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                ),
                                items: prefijosCedula.map((String prefijo) {
                                  return DropdownMenuItem<String>(
                                    value: prefijo,
                                    child: Text(prefijo),
                                  );
                                }).toList(),
                                onChanged: (String? nuevoPrefijo) {
                                  setState(() {
                                    prefijoce = nuevoPrefijo;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10), // Espacio entre el prefijo y el número de cédula
                            // Campo para el número de cédula
                            Expanded(
                              child: TextFormField(
                                controller: _numeroCedulaController,
                                keyboardType: TextInputType.number,
                                maxLength: 8, // Permitimos hasta 8 dígitos
                                decoration: InputDecoration(
                                  labelText: 'Cédula',
                                  hintText: 'Inserte su número de cédula',
                                  counterText: "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese su número de cédula';
                                  } else if (value.length != 8) {
                                    return 'La cédula debe tener 8 dígitos';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        // Email
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _emailController,
                          validator: (value){
                            if (value==null|| value.isEmpty){
                              return 'Inserte su Email, por favor';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              label: const Text('Email'),
                              hintText: 'Inserte Email',
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
                              )
                          ),
                        ),
                        //Contrasena
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          obscuringCharacter: '*',
                          validator: (value){
                            if (value==null|| value.isEmpty){
                              return 'Inserte contraseña, por favor';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              label: const Text('Contraseña'),
                              hintText: 'Inserte contraseña',
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
                              )
                          ),
                        ),
                        //Telefono
                        const SizedBox(height: 20.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center, // Alineación vertical correcta
                          children: [
                            // Dropdown para seleccionar el prefijo
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 60, // Altura uniforme con el TextFormField
                                child: DropdownButtonFormField<String>(
                                  value: prefijoSeleccionado,
                                  decoration: InputDecoration(
                                    labelText: 'Prefijo',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                  ),
                                  items: prefijosVenezuela.map((String prefijo) {
                                    return DropdownMenuItem<String>(
                                      value: prefijo,
                                      child: Text(prefijo),
                                    );
                                  }).toList(),
                                  onChanged: (String? nuevoPrefijo) {
                                    setState(() {
                                      prefijoSeleccionado = nuevoPrefijo;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Campo para ingresar el resto del número
                            Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: 60, // Misma altura que el Dropdown
                                child: TextFormField(
                                  controller: _numeroController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 7, // Solo los 7 dígitos restantes
                                  decoration: InputDecoration(
                                    labelText: 'Teléfono',
                                    hintText: '1234567',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                    counterText: "", // Oculta el contador de caracteres
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese su número';
                                    } else if (value.length != 7 || !RegExp(r'^\d{7}$').hasMatch(value)) {
                                      return 'Deben ser 7 dígitos';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        // Campo de Fecha de Nacimiento con Calendario
                        TextFormField(
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
                                fechaController.text =
                                "${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}";
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20.0),
                        //numero de licencia
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Campo para el número de licencia (sin prefijo)
                            Expanded(
                              child: TextFormField(
                                controller: _numeroLicencia,
                                keyboardType: TextInputType.number,
                                maxLength: 8, // Permitimos hasta 8 dígitos
                                decoration: InputDecoration(
                                  labelText: 'Número de Licencia',
                                  hintText: 'Inserte su número de Licencia',
                                  counterText: "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese su número de Licencia';
                                  } else if (value.length != 8) {
                                    return 'La licencia debe tener 8 dígitos';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        FutureBuilder<List<GrupoSanguineo>>(
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
                        const SizedBox(height: 20.0),
                        //campo de Centro medico
                        FutureBuilder<List<CentroMedico>>(
                              future: fetchCentrosMedicos(),  // Llamar a la función para obtener los datos
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Text('No hay centros médicos disponibles');
                                } else {
                                  List<CentroMedico> centros = snapshot.data!;

                                  return DropdownButtonFormField<int>(
                                    decoration: InputDecoration(
                                      labelText: 'Centro Médico',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0), // 👈 Borde redondeado
                                      ),
                                    ),
                                    value: selectedCentroMedico,
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        selectedCentroMedico = newValue;
                                        print('ID de la Centro medico seleccionada: $selectedCentroMedico');// Guarda el ID aquí
                                      });
                                    },
                                    items: centros.map((CentroMedico centro) {
                                      return DropdownMenuItem<int>(
                                        value: centro.idcentromedico, // Guarda el ID
                                        child: Text(centro.nombre),    // Muestra el nombre
                                      );
                                    }).toList(),
                                  );
                                }
                              },
                            ),
                        const SizedBox(height: 20.0),
                        //Campo de especialidad
                        FutureBuilder<List<Especialidad>>(
                          future: fetchEspecialidades(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(child: Text('No hay especialidades disponibles'));
                            } else {
                              List<Especialidad> especialidades = snapshot.data!;
                              return DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Especialidad',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0), // <<--- MÁS REDONDEADO
                                  ),
                                ),
                                value: selectedEspecialidad,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedEspecialidad = newValue; // <<--- GUARDA LA ID DEL REGISTRO
                                    print('ID de la especialidad seleccionada: $selectedEspecialidad'); // Esto es opcional solo para ver
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Por favor selecciona una especialidad';
                                  }
                                  return null;
                                },
                                items: especialidades.map((Especialidad especialidad) {
                                  return DropdownMenuItem<int>(
                                    value: especialidad.idEspecialidad, // <<--- SELECCIONA POR ID
                                    child: Text(especialidad.nombreEspecialidad),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: agreePersonalData,
                              onChanged: (bool? value){
                                setState(() {
                                  agreePersonalData= value!;
                                });
                              },
                              activeColor: lightColorScheme.primary,
                            ),
                            const Text(''
                                'Aceptar las condicciones',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        //boton de registrarse
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: registrarUsuario,  // Llamamos a la función aquí
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lightColorScheme.primary,
                            ),
                            child: const Text(
                              'Registrarse como doctor',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        //mensaje para registrarse
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Divider(
                                  thickness: 0.7,
                                  color: Colors.grey.withOpacity(0.5),
                                )),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 10,
                              ),
                              child: Text('Registrarse con ',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),),
                            ),
                            Expanded(
                                child: Divider(
                                  thickness: 0.7,
                                  color: Colors.grey.withOpacity(0.5),
                                )),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        //logos
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Logo(Logos.facebook_f),
                            Logo(Logos.google),
                            Logo(Logos.twitter),
                            Logo(Logos.apple),

                          ],
                        ),
                        const SizedBox(height: 20.0),
                        // boton para iniciar session
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                                'Ya tiene cuenta?',
                                style: TextStyle(
                                  color: Colors.black45,
                                )
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context,
                                  MaterialPageRoute(
                                    builder: (e)=>  const SingInScreen(),
                                  ),
                                );
                              },
                              child: const Text('   Iniciar sesion'),
                            )
                          ],
                        )
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );

  }
}
Future<List<CentroMedico>> fetchCentrosMedicos() async {
  final response = await http.get(Uri.parse('http://192.168.0.100:8000/usuarios/api/centros_medicos/'));

  if (response.statusCode == 200) {
    // 👇 Esto es importante: decodificar bien en UTF-8
    final utf8DecodedBody = utf8.decode(response.bodyBytes);

    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => CentroMedico.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load centros médicos');
  }
}

Future<List<Especialidad>> fetchEspecialidades() async {
  final response = await http.get(Uri.parse('http://192.168.0.100:8000/usuarios/api/especialidades/'));

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    // Si la solicitud es exitosa, parsea los datos
    List<dynamic> data =json.decode(utf8DecodedBody);
    return data.map((json) => Especialidad.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las especialidades');
  }
}

Future<List<GrupoSanguineo>> fetchGruposSanguineos() async {
  final response = await http.get(Uri.parse('http://192.168.0.100:8000/usuarios/api/grupos-sanguineos/'));

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    // Si la solicitud es exitosa, parsea los datos
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => GrupoSanguineo.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar los grupos sanguíneos');
  }
}
