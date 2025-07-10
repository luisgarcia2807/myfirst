import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mifirst/screens/iniciar_sesion.dart';
import 'package:mifirst/screens/pantalla_doctor_paciente2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/Centro_medico.dart';
import '../models/especialidades_doctor.dart';
import '../models/grupoSanguineo.dart';
import '../theme/theme.dart';
import '../constans.dart';

class SignUpScreendoctor extends StatefulWidget {
  const SignUpScreendoctor({super.key});

  @override
  State<SignUpScreendoctor> createState() => _SignUpScreenStatedoctor();
}

class _SignUpScreenStatedoctor extends State<SignUpScreendoctor> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  int? selectedCentroMedico;
  int? selectedEspecialidad;
  int? selectedGrupoSanguineo;
  final List<Map<String, String>> sexos = [
    {'codigo': 'M', 'descripcion': 'Masculino'},
    {'codigo': 'F', 'descripcion': 'Femenino'},
    {'codigo': 'O', 'descripcion': 'Otro'},
  ];
  String? selectedSexo = 'M';

  // Futures para evitar recargas innecesarias
  late Future<List<GrupoSanguineo>> _gruposSanguineosFuture;
  late Future<List<CentroMedico>> _centrosMedicosFuture;
  late Future<List<Especialidad>> _especialidadesFuture;

  // Controladores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _numeroLicencia = TextEditingController();

  // Lista de prefijos disponibles en Venezuela
  final List<String> prefijosCedula = ["V", "E"];
  String? prefijoce = "V";
  final TextEditingController _numeroCedulaController = TextEditingController();

  // Lista de prefijos disponibles en Venezuela
  final List<String> prefijosVenezuela = ["0412", "0414", "0416", "0424", "0426"];
  String? prefijoSeleccionado = "0414";
  final TextEditingController _numeroController = TextEditingController();

  // Variables para la fecha de nacimiento
  DateTime? fechaNacimiento;
  final TextEditingController fechaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializar los futures una sola vez
    _gruposSanguineosFuture = fetchGruposSanguineos();
    _centrosMedicosFuture = fetchCentrosMedicos();
    _especialidadesFuture = fetchEspecialidades();
  }

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
    return '$year-${mes.padLeft(2, '0')}-${dia.padLeft(2, '0')}';
  }

  Future<void> registrarUsuario() async {
    String nombre = _nameController.text;
    String apellido = _lastNameController.text;
    String email = _emailController.text;
    String contrasena = _passwordController.text;
    String cedula = _numeroCedulaController.text;
    String licencia = _numeroLicencia.text;

    if (!_formSignupKey.currentState!.validate()) {
      return;
    }

    if (!agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe aceptar los términos y condiciones')),
      );
      return;
    }

    String fechaFormateada = convertirFecha(fechaController.text);
    final url = Uri.parse('$baseUrl/usuarios/api/usuarios/');
    String telefonoCompleto = "$prefijoSeleccionado${_numeroController.text}";

    final Map<String, dynamic> data = {
      'nombre': nombre,
      'apellido': apellido,
      'cedula': cedula,
      'nacionalidad': prefijoce,
      'email': email,
      'telefono': telefonoCompleto,
      'fecha_nacimiento': fechaFormateada,
      'password': contrasena,
      "numero_licencia": licencia,
      "id_rol": 2,
      'sexo': selectedSexo,
      "id_especialidad": selectedEspecialidad,
      "id_sangre": selectedGrupoSanguineo,
      "id_centromedico": selectedCentroMedico,
      "foto_perfil": null,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final int idUsuarioCreado = responseData['id_usuario'];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso')),
        );

        // Limpiar los campos después del registro
        _nameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _numeroCedulaController.clear();
        fechaController.clear();
        _numeroController.clear();
        _numeroLicencia.clear();

        setState(() {
          fechaNacimiento = null;
          prefijoSeleccionado = "0414";
          prefijoce = "V";
          selectedSexo= 'M';
          selectedCentroMedico = null;
          selectedEspecialidad = null;
          selectedGrupoSanguineo = null;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (e) => PacienteScreen2(idusuario: idUsuarioCreado)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en el registro: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            // Fondo con degradado multicolor (igual al login)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D47A1), // Azul oscuro
                    Color(0xFF1976D2), // Azul medio
                    Color(0xFF42A5F5), // Azul claro
                    Color(0xFF7E57C2), // Morado
                    Color(0xFF26C6DA), // Turquesa
                  ],
                ),
              ),
            ),

            // Contenido de la pantalla
            Column(
              children: [
                const Expanded(
                  flex: 1,
                  child: SizedBox(height: 10),
                ),
                Expanded(
                  flex: 7,
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
                            // Título
                            Text(
                              'REGISTRARSE',
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900,
                                color: lightColorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              'COMO DOCTOR',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: lightColorScheme.primary.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 30.0),

                            // Nombre y apellido
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
                                      label: const Text('Nombre'),
                                      hintText: 'Inserte su Nombre',
                                      hintStyle: const TextStyle(color: Colors.black26),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.black12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.black12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
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
                                      hintStyle: const TextStyle(color: Colors.black26),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.black12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.black12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Cédula
                            const SizedBox(height: 20.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: DropdownButtonFormField<String>(
                                    value: prefijoce,
                                    decoration: InputDecoration(
                                      labelText: 'Prefijo',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 10,
                                      ),
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
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _numeroCedulaController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 8,
                                    decoration: InputDecoration(
                                      labelText: 'Cédula',
                                      hintText: 'Inserte su número de cédula',
                                      counterText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 10,
                                      ),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Inserte su Email, por favor';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Email'),
                                hintText: 'Inserte Email',
                                hintStyle: const TextStyle(color: Colors.black26),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            // Contraseña
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              obscuringCharacter: '*',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Inserte contraseña, por favor';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Contraseña'),
                                hintText: 'Inserte contraseña',
                                hintStyle: const TextStyle(color: Colors.black26),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            // Teléfono
                            const SizedBox(height: 20.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 60,
                                    child: DropdownButtonFormField<String>(
                                      value: prefijoSeleccionado,
                                      decoration: InputDecoration(
                                        labelText: 'Prefijo',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                          horizontal: 10,
                                        ),
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
                                Expanded(
                                  flex: 4,
                                  child: SizedBox(
                                    height: 60,
                                    child: TextFormField(
                                      controller: _numeroController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 7,
                                      decoration: InputDecoration(
                                        labelText: 'Teléfono',
                                        hintText: '1234567',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                          horizontal: 10,
                                        ),
                                        counterText: "",
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

                            // Fecha de Nacimiento
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: fechaController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Fecha de Nacimiento',
                                hintText: 'Selecciona tu fecha',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: const Icon(Icons.calendar_today),
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
                                    fechaController.text = "${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}";
                                  });
                                }
                              },
                            ),

                            // Número de licencia
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: _numeroLicencia,
                              keyboardType: TextInputType.number,
                              maxLength: 8,
                              decoration: InputDecoration(
                                labelText: 'Número de Licencia',
                                hintText: 'Inserte su número de Licencia',
                                counterText: "",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 10,
                                ),
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

                            //sexo
                            const SizedBox(height: 20.0),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Sexo',
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              value: selectedSexo,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedSexo = newValue;
                                });
                              },
                              items: sexos.map((sexo) {
                                return DropdownMenuItem<String>(
                                  value: sexo['codigo'],
                                  child: Text(sexo['descripcion']!),
                                );
                              }).toList(),
                            ),


                            // Grupo Sanguíneo - Optimizado
                            const SizedBox(height: 20.0),
                            FutureBuilder<List<GrupoSanguineo>>(
                              future: _gruposSanguineosFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Text('No hay grupos sanguíneos disponibles');
                                } else {
                                  List<GrupoSanguineo> gruposSanguineos = snapshot.data!;
                                  return DropdownButtonFormField<int>(
                                    decoration: InputDecoration(
                                      labelText: 'Grupo Sanguíneo',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                    ),
                                    value: selectedGrupoSanguineo,
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        selectedGrupoSanguineo = newValue;
                                      });
                                    },
                                    items: gruposSanguineos.map((GrupoSanguineo grupo) {
                                      return DropdownMenuItem<int>(
                                        value: grupo.idSangre,
                                        child: Text(grupo.tipoSangre),
                                      );
                                    }).toList(),
                                  );
                                }
                              },
                            ),

                            // Centro Médico - Optimizado
                            const SizedBox(height: 20.0),
                            FutureBuilder<List<CentroMedico>>(
                              future: _centrosMedicosFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Text('No hay centros médicos disponibles');
                                } else {
                                  List<CentroMedico> centros = snapshot.data!;
                                  return DropdownButtonFormField<int>(
                                    decoration: InputDecoration(
                                      labelText: 'Centro Médico',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                    ),
                                    value: selectedCentroMedico,
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        selectedCentroMedico = newValue;
                                      });
                                    },
                                    items: centros.map((CentroMedico centro) {
                                      return DropdownMenuItem<int>(
                                        value: centro.idcentromedico,
                                        child: Text(centro.nombre),
                                      );
                                    }).toList(),
                                  );
                                }
                              },
                            ),

                            // Especialidad - Optimizado
                            const SizedBox(height: 20.0),
                            FutureBuilder<List<Especialidad>>(
                              future: _especialidadesFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(child: Text('No hay especialidades disponibles'));
                                } else {
                                  List<Especialidad> especialidades = snapshot.data!;
                                  return DropdownButtonFormField<int>(
                                    decoration: InputDecoration(
                                      labelText: 'Especialidad',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                    ),
                                    value: selectedEspecialidad,
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        selectedEspecialidad = newValue;
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
                                        value: especialidad.idEspecialidad,
                                        child: Text(especialidad.nombreEspecialidad),
                                      );
                                    }).toList(),
                                  );
                                }
                              },
                            ),

                            // Checkbox términos y condiciones
                            const SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: agreePersonalData,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      agreePersonalData = value!;
                                    });
                                  },
                                  activeColor: lightColorScheme.primary,
                                ),
                                const Text(
                                  'Aceptar las condiciones',
                                  style: TextStyle(color: Colors.black45),
                                ),
                              ],
                            ),

                            // Botón de registro
                            const SizedBox(height: 20.0),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: registrarUsuario,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: lightColorScheme.primary,
                                ),
                                child: const Text(
                                  'Registrarse como doctor',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),

                            // Divisor
                            const SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Divider(
                                    thickness: 0.7,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    'Registrarse con ',
                                    style: TextStyle(color: Colors.black45),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    thickness: 0.7,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),

                            // Logos redes sociales
                            const SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Logo(Logos.facebook_f),
                                Logo(Logos.google),
                                Logo(Logos.twitter),
                                Logo(Logos.apple),
                              ],
                            ),

                            // Link para iniciar sesión
                            const SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Ya tiene cuenta?',
                                  style: TextStyle(color: Colors.black45),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (e) => const SingInScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('   Iniciar sesion'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]
      ),
    );
  }
}

// Funciones optimizadas para evitar recargas
Future<List<CentroMedico>> fetchCentrosMedicos() async {
  final response = await http.get(Uri.parse('$baseUrl/usuarios/api/centros_medicos/'));

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => CentroMedico.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load centros médicos');
  }
}

Future<List<Especialidad>> fetchEspecialidades() async {
  final response = await http.get(Uri.parse('$baseUrl/usuarios/api/especialidades/'));

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => Especialidad.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las especialidades');
  }
}

Future<List<GrupoSanguineo>> fetchGruposSanguineos() async {
  final response = await http.get(Uri.parse('$baseUrl/usuarios/api/grupos-sanguineos/'));

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => GrupoSanguineo.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar los grupos sanguíneos');
  }
}