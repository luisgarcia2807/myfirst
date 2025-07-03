import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';
import 'package:mifirst/screens/pantalla_doctor_paciente2.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mifirst/screens/pantallapaciente.dart'; // Asegúrate de importar la pantalla a la que quieres ir
import 'olvido_contrasena.dart';
import 'registrarse.dart';
import 'package:mifirst/widgets/custom_scaffold.dart';
import '../theme/theme.dart';
import '../constans.dart';

class SingInScreen extends StatefulWidget {
  const SingInScreen ({super.key});

  @override
  State<SingInScreen> createState()=> _SingInScreenState();
}

class _SingInScreenState extends State<SingInScreen>{
  final _formSignInKey= GlobalKey<FormState>();
  bool rememberPassword=true;
  // Controladores para email y contraseña
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Función para hacer la solicitud POST y obtener el token
  // Función para hacer la solicitud POST y obtener el token
  Future<void> loginUser() async {
    if (!_formSignInKey.currentState!.validate()) {
      return;
    }

    final url = Uri.parse('$baseUrl/api/token/');  // Reemplaza la IP si es necesario

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Si el login es exitoso, obtener el token, id y nombre
      final Map<String, dynamic> data = jsonDecode(response.body);
      String token = data['access'];
      String nombre = data['nombre'] ?? 'Desconocido'; // Si no tiene nombre, asigna 'Desconocido'
      int id = data['id_usuario'];
      int idrol = data['id_rol'];

      // Guardar en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', token);
      prefs.setString('nombre_usuario', nombre);
      prefs.setInt('user_id', id);
      prefs.setInt('user_role', idrol); // También guardar el rol
      print('\n\n\nhola is $id');

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de sesión exitoso')),
      );

      // Redirigir según el rol del usuario
      if (idrol == 1) {
        // Rol 1 = Paciente
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PacienteScreen(idusuario: id)),
        );
      } else if (idrol == 2) {
        // Rol 2 = Doctor
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PacienteScreen2(idusuario: id)), // Asegúrate de tener esta pantalla
        );
      } else {
        // En caso de que haya otros roles o un rol no reconocido
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rol de usuario no reconocido')),
        );
      }

    } else {
      // Si ocurre un error, muestra el mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${response.body}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con degradado multicolor
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
                      key: _formSignInKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'INICIO DE SESION',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900,
                              color: lightColorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          // Email
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
                          const SizedBox(height: 20.0),
                          // Contraseña
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
                          const SizedBox(height: 20.0),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberPassword,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        rememberPassword = value!;
                                      });
                                    },
                                    activeColor: lightColorScheme.primary,
                                  ),
                                  const Text(
                                    'Recordar Contraseña',
                                    style: TextStyle(
                                      color: Colors.black45,
                                    ),
                                  )
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (e) => const ForgetPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Olvido su contraseña',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: lightColorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          // Botón de inicio de sesión
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loginUser, // Llamar a la función de login
                              style: ElevatedButton.styleFrom(
                                backgroundColor: lightColorScheme.primary,
                              ),
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
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
                                  'Iniciar Sesion con',
                                  style: TextStyle(
                                    color: Colors.black45,
                                  ),
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
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No tienes cuenta?',
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (e) => const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: const Text('     Registrarse'),
                              )
                            ],
                          )
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