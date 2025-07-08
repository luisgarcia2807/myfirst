import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alergias.dart';
import '../constans.dart';

class VistaAlergia extends StatefulWidget {
  final int id_paciente;


  const VistaAlergia( {super.key, required this.id_paciente});

  @override
  State<VistaAlergia> createState() => _VistaAlergia();
}

class _VistaAlergia extends State<VistaAlergia> {
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
  String sexo = '';
  String? nivelSeleccionado;
  String? tipoSeleccionado= 'medicamento';
  int? selectedAlergiaId;
  String? filtroActivo;
  String tipoUsuario='';
  int idtipoUsuario=0;
  List<dynamic> alergias = [];  // Lista para almacenar las alergias
  final TextEditingController _descripcionAlergiaController = TextEditingController();
  bool isLoadingalergia = false;
  bool hasError = false;


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


  void _mostrarDialogoAlergia() {
    Future<List<Alergia>> futureAlergias = fetchAlergias(tipoSeleccionado!);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true, // Para evitar overflow vertical
              title: Text("Añadir Alergia"),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85, // Ajustar el ancho máximo
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tipo de alergia
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: tipoSeleccionado,
                          onChanged: (String? newValue) {
                            setState(() {
                              tipoSeleccionado = newValue;
                              futureAlergias = fetchAlergias(newValue!);
                              selectedAlergiaId = null;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Tipo de alergia",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                            ),
                          ),
                          items: ['medicamento', 'alimento', 'ambiental', 'otro']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

                      // Lista de alergias según tipo
                      FutureBuilder<List<Alergia>>(
                        future: futureAlergias,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No hay alergias disponibles');
                          } else {
                            List<Alergia> alergias = snapshot.data!;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: SizedBox(
                                width: 300, // O usa MediaQuery para adaptarlo a pantalla
                                child: DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'Alergia',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  value: selectedAlergiaId,
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      selectedAlergiaId = newValue;
                                    });
                                  },
                                  selectedItemBuilder: (BuildContext context) {
                                    return alergias.map((alergia) {
                                      return Text(
                                        alergia.nombre,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                      );
                                    }).toList();
                                  },
                                  items: alergias.map((alergia) {
                                    return DropdownMenuItem<int>(
                                      value: alergia.id,
                                      child: Text(alergia.nombre), // se muestra completo en el menú
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }
                        },
                      ),


                      // Nivel de alergia
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: nivelSeleccionado,
                          onChanged: (String? newValue) {
                            setState(() {
                              nivelSeleccionado = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Nivel de alergia',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          items: ['leve', 'moderada', 'severo'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

                      // Descripción
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _descripcionAlergiaController,
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
                    if (selectedAlergiaId != null && nivelSeleccionado != null) {
                      final url = Uri.parse('$baseUrl/usuarios/api/pacientes-alergias/');
                      final Map<String, dynamic> data = {
                        'paciente': idPaciente,
                        'alergia': selectedAlergiaId,
                        'gravedad': nivelSeleccionado,
                        'observacion': _descripcionAlergiaController.text,
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
                            tipoSeleccionado = 'medicamento'; // Regresa al valor inicial
                            selectedAlergiaId = null;
                            nivelSeleccionado = null;
                          });

                          // Limpiar controlador
                          _descripcionAlergiaController.clear();

                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Alergia guardada correctamente")),
                          );

                          await _fetchAlergias();
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

  Future<void> _fetchAlergias({String? tipo}) async {
    setState(() {
      isLoadingalergia = true;
      hasError = false;
    });

    try {
      final url = (tipo == null || tipo.isEmpty)
          ? '$baseUrl/usuarios/api/pacientes/$idPaciente/alergias/'
          : '$baseUrl/usuarios/api/pacientes/$idPaciente/alergias/?tipo=$tipo';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          alergias = jsonDecode(utf8.decode(response.bodyBytes));
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
        isLoadingalergia = false;
      });
    }
  }

  IconData _getIcon(String tipo) {
    switch (tipo) {
      case 'Medicamento':
        return Icons.local_hospital;  // Ícono para medicamentos
      case 'Ambiental':
        return Icons.ac_unit;  // Ícono para alergias ambientales
      case 'Alimento':
        return Icons.restaurant_menu;  // Ícono más sano que simboliza comida 🍏
      default:
        return Icons.precision_manufacturing
    ;  // Ícono genérico para otros tipos
    }
  }
  Color _getColor(String tipo) {
    switch (tipo) {
      case 'Medicamento':
        return Colors.blue;  // Color azul para alergias a medicamentos
      case 'Ambiental':
        return Colors.green;  // Color verde para alergias ambientales
      case 'Alimento':
        return Colors.red;  // Ícono más sano que simboliza comida 🍏
      default:
        return Colors.grey;  // Color gris para otros tipos
    }
  }

  Future<void> eliminarAlergia(int idAlergiaPaciente) async {
    final url = Uri.parse('$baseUrl/usuarios/api/pacientes-alergias/$idAlergiaPaciente/');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Alergia eliminada correctamente")),
        );
        await _fetchAlergias(); // Actualizar la lista después de eliminar
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

  Future<void> editarAlergia({required int id, required String gravedad, required String observacion,}) async {

    final url = Uri.parse('$baseUrl/usuarios/api/pacientes-alergias/$id/');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'gravedad': gravedad,
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
  Color _colorSegunGravedad(String? gravedad) {
    switch (gravedad?.toLowerCase()) {
      case 'leve':
        return Colors.green;
      case 'moderada':
        return Colors.orange;
      case 'grave':
      case 'severa':
      case 'severo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _colorSuaveSegunGravedad(String? gravedad) {
    switch (gravedad?.toLowerCase()) {
      case 'leve':
        return Colors.green.shade700;
      case 'moderada':
        return Colors.orange.shade700;
      case 'grave':
      case 'severa':
      case 'severo':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
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
    await _fetchAlergias(); // Llamar después de que idPaciente esté disponible
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
                      'Alergias Registradas',
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Botón de "Añadir alergias" en la parte superior derecha
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón "Añadir alergias" centrado
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.add_circle, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        "Añadir alergias",
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
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
                            child: PopupMenuButton<String>(
                              color: Colors.white,
                              icon: const Icon(Icons.filter_list, color: Colors.white),
                              tooltip: "Filtrar por tipo",
                              onSelected: (tipoSeleccionado) {
                                setState(() {
                                  filtroActivo = tipoSeleccionado == '' ? null : tipoSeleccionado;
                                });

                                if (tipoSeleccionado == '') {
                                  _fetchAlergias(); // sin filtro
                                } else {
                                  _fetchAlergias(tipo: tipoSeleccionado);
                                }
                              },


                              itemBuilder: (context) => [
                                PopupMenuItem(value: '', child: Text('Mostrar todas')),
                                const PopupMenuItem(value: 'medicamento', child: Text('Medicamento')),
                                const PopupMenuItem(value: 'alimento', child: Text('Alimento')),
                                const PopupMenuItem(value: 'ambiental', child: Text('Ambiental')),
                                const PopupMenuItem(value: 'otro', child: Text('Otro')),

                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),
                      // Lista de alergias
                      Expanded(
                        child: isLoading
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
                                onPressed: () => _fetchAlergias(tipo: filtroActivo),
                              ),
                            ],
                          ),
                        )
                            : alergias.isEmpty
                            ? Center(
                          child: Text(
                            filtroActivo == null || filtroActivo == ''
                                ? 'No hay alergias registradas.'
                                : 'No se encontraron alergias de tipo "$filtroActivo".',
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                            : ListView.builder(
                          itemCount: alergias.length,
                          itemBuilder: (context, index) {
                            final item = alergias[index];
                            final tipo = item['tipo_alergia'];
                            final aprobado = item['aprobado'] == true;

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Título y estado de aprobación
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['nombre_alergia'],
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

                                    /// Contenido principal con ícono e info
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
                                              Row(
                                                children: [
                                                  const Icon(Icons.category, size: 18, color: Colors.black54),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Tipo: ${item['tipo_alergia']}',
                                                    style: const TextStyle(color: Colors.black87,fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.warning,
                                                    size: 18,
                                                    color: _colorSegunGravedad(item['gravedad']),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Text(
                                                    'Gravedad: ',
                                                    style: TextStyle(color: Colors.black54,fontSize: 12),
                                                  ),
                                                  Text(
                                                    '${item['gravedad']}',
                                                    style: TextStyle(
                                                      color: _colorSuaveSegunGravedad(item['gravedad']),
                                                      fontWeight: FontWeight.w600,fontSize: 12
                                                    ),
                                                  ),
                                                ],
                                              ),


                                              if (item['observacion'] != null && item['observacion'].toString().isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Icon(Icons.note_alt, size: 18, color: Colors.black45),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          'Observación: ${item['observacion']}',
                                                          style: const TextStyle(color: Colors.black54,fontSize: 12),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (item['doctor_aprobador'] != null && item['doctor_aprobador'].toString().isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.medical_services, size: 18, color: Colors.black54),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Doctor: ${item['doctor_aprobador']}',
                                                        style: const TextStyle(color: Colors.black87,fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    /// Botones (solo si no está aprobado)
                                    if (!aprobado)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                            onPressed: () {
                                              final observacionController = TextEditingController(text: item['observacion']);
                                              String gravedadSeleccionada = item['gravedad'].toString().toLowerCase();

                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Editar alergia'),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      DropdownButtonFormField<String>(
                                                        value: gravedadSeleccionada,
                                                        decoration: const InputDecoration(labelText: 'Gravedad'),
                                                        items: ['leve', 'moderada', 'grave'].map((valor) {
                                                          return DropdownMenuItem(
                                                            value: valor,
                                                            child: Text(valor),
                                                          );
                                                        }).toList(),
                                                        onChanged: (valor) {
                                                          if (valor != null) gravedadSeleccionada = valor;
                                                        },
                                                      ),
                                                      const SizedBox(height: 10),
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
                                                        await editarAlergia(
                                                          id: item['id'],
                                                          gravedad: gravedadSeleccionada,
                                                          observacion: observacionController.text,
                                                        );
                                                        setState(() {
                                                          item['gravedad'] = gravedadSeleccionada;
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
                                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Confirmar eliminación'),
                                                  content: const Text('¿Estás seguro de que deseas eliminar esta alergia?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: const Text('Cancelar'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context).pop();
                                                        await eliminarAlergia(item['id']);
                                                        setState(() {
                                                          alergias.removeAt(index);
                                                        });
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

Future<List<Alergia>> fetchAlergias(String tipo) async {
  final url = Uri.parse('$baseUrl/usuarios/api/alergias/?tipo=$tipo');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final utf8DecodedBody = utf8.decode(response.bodyBytes);
    // Si la solicitud es exitosa, parsea los datos
    List<dynamic> data = json.decode(utf8DecodedBody);
    return data.map((json) => Alergia.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las alergias');
  }
}
