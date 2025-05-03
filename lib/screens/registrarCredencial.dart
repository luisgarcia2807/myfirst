import 'package:flutter/material.dart';

class RegistrarCredencialScreen extends StatefulWidget {
  @override
  _RegistrarCredencialScreenState createState() =>
      _RegistrarCredencialScreenState();
}

class _RegistrarCredencialScreenState
    extends State<RegistrarCredencialScreen> {
  final TextEditingController _credencialController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _mensajeError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800], // Fondo en color similar al principal
      appBar: AppBar(
        title: Text("Registrar Credencial de Doctor"),
        backgroundColor: Colors.blue[600], // Bar color
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/ima2.jpg', // Mantén la imagen de fondo
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      SizedBox(height: 25),
                      Text(
                        "Ingresa tu número de credencial de doctor",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              'Buscar información',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _credencialController,
                              decoration: InputDecoration(
                                labelText: "Número de Credencial",
                                hintText: "Ej: D123456",
                                border: OutlineInputBorder(),
                                errorText: _mensajeError,
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu credencial.';
                                }
                                if (value.length < 6) {
                                  return 'La credencial debe tener al menos 6 caracteres.';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _registrarCredencial,
                              child: Text('Registrar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800], // Color del botón
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                textStyle: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _registrarCredencial() {
    if (_formKey.currentState!.validate()) {
      // Simulamos la validación de la credencial
      setState(() {
        _mensajeError = null;
      });
      // Aquí podrías guardar la credencial en el backend o localmente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credencial registrada correctamente.')),
      );
      print('Credencial registrada: ${_credencialController.text}');
      // Si es necesario, puedes navegar a otra pantalla o hacer algo después del registro
    } else {
      setState(() {
        _mensajeError = 'Por favor, ingresa una credencial válida.';
      });
    }
  }
}
