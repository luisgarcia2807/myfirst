import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mifirst/screens/iniciar_sesion.dart';
import 'package:mifirst/screens/pantallapaciente.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constans.dart';
import '../models/grupoSanguineo.dart';
import '../theme/theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen ({super.key});

  @override
  State<SignUpScreen> createState()=> _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>{
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData=true;
  int? selectedGrupoSanguineo;
  final List<Map<String, String>> sexos = [
    {'codigo': 'M', 'descripcion': 'Masculino'},
    {'codigo': 'F', 'descripcion': 'Femenino'},
    {'codigo': 'O', 'descripcion': 'Otro'},
  ];
  String? selectedSexo = 'M';

  // Controladores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();

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
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cedulaController.dispose();
    fechaController.dispose();
    _numeroController.dispose();
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
      'id_rol': 1,
      "id_sangre":selectedGrupoSanguineo,
      'sexo': selectedSexo,
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
          SnackBar(content: Text('Registro exitoso')),
        );

        // Limpiar los campos después del registro
        _nameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _numeroCedulaController.clear();
        fechaController.clear();
        _numeroController.clear();
        setState(() {
          fechaNacimiento = null;
          prefijoSeleccionado = "0414";
          prefijoce = "V";
          selectedSexo= 'M';
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (e) => PacienteScreen(idusuario: idUsuarioCreado)),
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
                            'COMO PACIENTE',
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
                                      return 'Inserte su Nombre';
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
                              const SizedBox(width: 15),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Inserte su Apellido';
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
                            children: [
                              SizedBox(
                                width: 80,
                                child: DropdownButtonFormField<String>(
                                  value: prefijoce,
                                  decoration: InputDecoration(
                                    labelText: 'Prefijo',
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                              const SizedBox(width: 15),
                              Expanded(
                                child: TextFormField(
                                  controller: _numeroCedulaController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 8,
                                  decoration: InputDecoration(
                                    labelText: 'Cédula',
                                    hintText: 'Número de cédula',
                                    hintStyle: const TextStyle(color: Colors.black26),
                                    counterText: "",
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese su cédula';
                                    } else if (value.length != 8) {
                                      return 'Debe tener 8 dígitos';
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
                            children: [
                              SizedBox(
                                width: 100,
                                child: DropdownButtonFormField<String>(
                                  value: prefijoSeleccionado,
                                  decoration: InputDecoration(
                                    labelText: 'Prefijo',
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                              const SizedBox(width: 15),
                              Expanded(
                                child: TextFormField(
                                  controller: _numeroController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 7,
                                  decoration: InputDecoration(
                                    labelText: 'Teléfono',
                                    hintText: '1234567',
                                    hintStyle: const TextStyle(color: Colors.black26),
                                    counterText: "",
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
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
                              hintStyle: const TextStyle(color: Colors.black26),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black12),
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

                          // Grupo Sanguíneo
                          const SizedBox(height: 20.0),
                          FutureBuilder<List<GrupoSanguineo>>(
                            future: fetchGruposSanguineos(),
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
                                      borderSide: const BorderSide(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10),
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

                          // Sexo
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

                          // Checkbox términos y condiciones
                          const SizedBox(height: 20.0),
                          Row(
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
                              const Expanded(
                                child: Text(
                                  'Acepto los términos y condiciones',
                                  style: TextStyle(color: Colors.black45),
                                ),
                              ),
                            ],
                          ),

                          // Botón de registro
                          const SizedBox(height: 25.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: registrarUsuario,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: lightColorScheme.primary,
                              ),
                              child: const Text(
                                'Registrarse como Paciente',
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
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'Registrarse con',
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
                                '¿Ya tienes cuenta?',
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
                                child: Text(
                                  '  Iniciar sesión',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: lightColorScheme.primary,
                                  ),
                                ),
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
        ],
      ),
    );
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