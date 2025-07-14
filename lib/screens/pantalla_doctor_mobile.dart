import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mifirst/constans.dart';
import 'package:mifirst/screens/fotoPerfil.dart';
import 'package:mifirst/screens/pantalla_doctor_paciente2.dart';
import 'package:mifirst/screens/vista_doctor_buscarPaciente.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import 'bienvenido.dart';

class DoctorMobileScreen extends StatefulWidget {
  final int idusuario;
  const DoctorMobileScreen({super.key, required this.idusuario});

  @override
  State<DoctorMobileScreen> createState() => _DoctorMobileScreenState();
}

class _DoctorMobileScreenState extends State<DoctorMobileScreen> {
  String selectedOption = "Home";
  String nombreUsuario = '';
  String apellidoUsuario = '';
  String cedulaUsuario = '';
  String emailUsuario = '';
  String telefonoUsuario = '';
  String fechaNacimientoUsuario = '';
  bool estadoUsuario = false;
  int idRolUsuario = 0;
  String? foto = '';
  int idDoctor=0;

  // Variables para las estadísticas
  Map<String, dynamic>? estadisticas;
  bool isLoadingEstadisticas = false;

  // Método para obtener los datos del usuario
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
          foto = datos['foto_perfil'];

          if (foto != null && foto!.isNotEmpty) {
            String nuevaFotoUrl = foto!.replaceFirst('http://localhost:8000', baseUrl);
            print('URL final de la imagen: $nuevaFotoUrl');
          } else {
            print('La foto no está disponible');
          }
        });
      } else {
        print('Error al obtener los datos: ${response.statusCode}');
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




        // Aquí podrías actualizar el estado con setState o similar
      } else {
        print('Error al obtener doctor: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener doctor: $e');
    }
  }


  // Método para obtener estadísticas
  Future<void> obtenerEstadisticas() async {
    setState(() {
      isLoadingEstadisticas = true;
    });

    // Primero obtener el idDoctor
    await obtenerDatosDoctor(widget.idusuario);

    final url = Uri.parse('$baseUrl/usuarios/api/estadisticas-doctor/$idDoctor/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var datos = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          estadisticas = datos;
          isLoadingEstadisticas = false;
        });
      } else {
        print('Error al obtener estadísticas: ${response.statusCode}');
        setState(() {
          isLoadingEstadisticas = false;
          estadisticas = {}; // Establecer objeto vacío en lugar de null
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoadingEstadisticas = false;
        estadisticas = {}; // Establecer objeto vacío en lugar de null
      });
    }
  }

  int _selectedIndex = 0;
  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return;

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => buscarPaciente(idusuario: widget.idusuario),
        ),
      );
    }if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PacienteScreen2(idusuario: widget.idusuario),
        ),
      );
    }
    if (index == 3) {
      // Opción de cerrar sesión
      _mostrarDialogoCerrarSesion().then((shouldLogout) {
        if (shouldLogout) {
          _cerrarSesion();
        }
      });
    }
    else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  Future<bool> _mostrarDialogoCerrarSesion() async {
    return await showDialog(
      context: context,
      barrierDismissible: false, // No permite cerrar tocando fuera del diálogo
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.red,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 60,
              ),
              SizedBox(height: 20),
              Text(
                '¿Estás seguro que quieres cerrar sesión?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Se perderá la sesión actual y tendrás que iniciar sesión nuevamente.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Retorna false (no cerrar)
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Retorna true (cerrar sesión)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false; // Retorna false si se cierra el diálogo sin seleccionar
  }

  // Método para cerrar sesión
  void _cerrarSesion() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => WelcomeScreen()),
          (Route<dynamic> route) => false,
    );
  }
  @override
  void initState() {
    super.initState();
    _initializeLocalization();
    obtenerDatos();
    obtenerEstadisticas();
  }

  Future<void> _initializeLocalization() async {
    await initializeDateFormatting('es_ES', null);
  }

  @override
  Widget build(BuildContext context) {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return WillPopScope(
        onWillPop: () async {
      // Intercepta el botón de retroceso
      bool shouldLogout = await _mostrarDialogoCerrarSesion();
      if (shouldLogout) {
        _cerrarSesion();
      }
      return false; // Siempre retorna false para evitar el comportamiento por defecto
    },
    child: Scaffold(
      backgroundColor: Colors.blue.shade900,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
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
              label: 'Perfil Pc',
            ),
            NavigationDestination(
              icon: Icon(Icons.logout),
              selectedIcon: Icon(Icons.logout),
              label: 'Salir',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(fechaHoy),
            SizedBox(height: 20),
            // Content Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: isLoadingEstadisticas
                    ? Center(child: CircularProgressIndicator())
                    : estadisticas != null
                    ? _buildEstadisticasContent()
                    : Center(child: Text('Error al cargar estadísticas')),
              ),
            ),
          ],
        ),
      ),)
    );
  }

  Widget _buildHeader(String fechaHoy) {
    return Padding(
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
                    MaterialPageRoute(
                        builder: (context) => CambiarFotoScreen(idusuario: widget.idusuario)),
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
              SizedBox(width: 15.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hola Dr. $nombreUsuario $apellidoUsuario",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.0),
                    Text(
                      fechaHoy,
                      style: TextStyle(color: Colors.grey[300]),
                      overflow: TextOverflow.ellipsis, // opcional
                    ),

                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          // Stats Cards Row
          if (estadisticas != null) _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    if (estadisticas == null) return SizedBox.shrink();

    // Obtener valores con validación de nulos
    int totalPacientes = estadisticas!['pacientes']?['total'] ?? 0;
    int consultasMes = estadisticas!['consultas']?['mes_actual'] ?? 0;
    int totalTratamientos = estadisticas!['tratamientos']?['total'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            title: 'Pacientes',
            value: totalPacientes.toString(),
            color: Colors.green,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            title: 'Consultas',
            value: consultasMes.toString(),
            subtitle: 'Este mes',
            color: Colors.orange,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.medication,
            title: 'Tratamientos',
            value: totalTratamientos.toString(),
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasContent() {
    if (estadisticas == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay estadísticas disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Aún no tienes pacientes registrados',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Verificar si hay datos reales
    bool tienesDatos = (estadisticas!['pacientes']?['total'] ?? 0) > 0 ||
        (estadisticas!['consultas']?['total'] ?? 0) > 0 ||
        (estadisticas!['tratamientos']?['total'] ?? 0) > 0;

    if (!tienesDatos) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 50),
            Icon(Icons.analytics_outlined, size: 80, color: Colors.blue.shade300),
            SizedBox(height: 20),
            Text(
              '¡Bienvenido Dr. $nombreUsuario!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Aún no tienes estadísticas para mostrar.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Comienza registrando tus primeros pacientes y consultas.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => buscarPaciente(idusuario: widget.idusuario),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Buscar Paciente',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    // Si hay datos, mostrar dashboard normal
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de estadísticas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          SizedBox(height: 20),

          // Solo mostrar gráficos si hay datos
          if ((estadisticas!['pacientes']?['nuevos_por_mes'] as List?)?.isNotEmpty == true)
            _buildChartSection(
              title: '📊 Pacientes Nuevos por Mes',
              child: _buildPacientesPorMesChart(),
            ),

          // Gráficos de Distribución
          Row(
            children: [
              if ((estadisticas!['pacientes']?['distribucion_edad'] as Map?)?.values.any((v) => v > 0) == true)
                Expanded(
                  child: _buildChartSection(
                    title: '👥 Distribución por Edad',
                    child: _buildDistribucionEdadChart(),
                  ),
                ),
              if ((estadisticas!['pacientes']?['distribucion_edad'] as Map?)?.values.any((v) => v > 0) == true &&
                  (estadisticas!['pacientes']?['distribucion_sexo'] as List?)?.any((s) => s['total'] > 0) == true)
                SizedBox(width: 15),
              if ((estadisticas!['pacientes']?['distribucion_sexo'] as List?)?.any((s) => s['total'] > 0) == true)
                Expanded(
                  child: _buildChartSection(
                    title: '⚥ Distribución por Sexo',
                    child: _buildDistribucionSexoChart(),
                  ),
                ),
            ],
          ),

          // Resto de gráficos con validaciones similares
          if ((estadisticas!['consultas']?['por_dia_semana'] as List?)?.isNotEmpty == true)
            _buildChartSection(
              title: '📈 Consultas por Día de la Semana',
              child: _buildConsultasPorDiaChart(),
            ),

          if (_tieneEstadisticasEdad())
            _buildChartSection(
              title: '📏 Estadísticas de Edad',
              child: _buildEstadisticasEdadCards(),
            ),

          if ((estadisticas!['diagnosticos']?['top_comunes'] as List?)?.isNotEmpty == true)
            _buildChartSection(
              title: '🩺 Diagnósticos más Comunes',
              child: _buildDiagnosticosChart(),
            ),

          if ((estadisticas!['tratamientos']?['top_medicamentos'] as List?)?.isNotEmpty == true)
            _buildChartSection(
              title: '💊 Medicamentos más Utilizados',
              child: _buildMedicamentosChart(),
            ),
        ],
      ),
    );
  }
  bool _tieneEstadisticasEdad() {
    Map<String, dynamic>? estadisticasEdad = estadisticas!['pacientes']?['estadisticas_edad'];
    if (estadisticasEdad == null) return false;

    double promedio = (estadisticasEdad['promedio'] ?? 0).toDouble();
    int minima = estadisticasEdad['minima'] ?? 0;
    int maxima = estadisticasEdad['maxima'] ?? 0;

    return promedio > 0 || minima > 0 || maxima > 0;
  }


  Widget _buildChartSection({required String title, required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildPacientesPorMesChart() {
    List<dynamic> nuevosPorMes = estadisticas!['pacientes']?['nuevos_por_mes'] ?? [];

    if (nuevosPorMes.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'No hay pacientes nuevos registrados',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Text(
                'Los datos aparecerán cuando registres pacientes',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    // Resto del código del gráfico permanece igual...
    List<BarChartGroupData> barGroups = [];
    List<String> meses = [];

    Map<int, String> mesesEspanol = {
      1: 'Ene', 2: 'Feb', 3: 'Mar', 4: 'Abr',
      5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Ago',
      9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dic'
    };

    for (int i = 0; i < nuevosPorMes.length; i++) {
      var mes = nuevosPorMes[i];
      DateTime fecha = DateTime.parse(mes['mes']);
      String mesFormateado = '${mesesEspanol[fecha.month]} ${fecha.year}';
      meses.add(mesFormateado);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (mes['total'] ?? 0).toDouble(),
              color: Colors.blue.shade600,
              width: 30,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      );
    }

    double maxY = nuevosPorMes
        .map((e) => e['total'] ?? 0)
        .reduce((a, b) => a > b ? a : b)
        .toDouble() + 1;

    return Container(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < meses.length) {
                    return Text(
                      meses[value.toInt()],
                      style: TextStyle(fontSize: 12),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildDistribucionEdadChart() {
    Map<String, dynamic> distribucionEdad = estadisticas!['pacientes']?['distribucion_edad'] ?? {};

    if (distribucionEdad.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Sin datos de edad'),
            ],
          ),
        ),
      );
    }

    List<PieChartSectionData> sections = [];
    List<Color> colors = [Colors.green, Colors.blue, Colors.orange, Colors.red];
    int index = 0;

    distribucionEdad.forEach((key, value) {
      if (value != null && value > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[index % colors.length],
            value: value.toDouble(),
            title: '$key\n$value',
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        index++;
      }
    });

    if (sections.isEmpty) {
      return Container(
        height: 200,
        child: Center(child: Text('No hay datos de distribución por edad')),
      );
    }

    return Container(
      height: 180,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 15,
            sectionsSpace: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildDistribucionSexoChart() {
    List<dynamic> distribucionSexo = estadisticas!['pacientes']?['distribucion_sexo'] ?? [];

    if (distribucionSexo.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Sin datos de sexo'),
            ],
          ),
        ),
      );
    }

    List<PieChartSectionData> sections = [];
    List<Color> colors = [Colors.blue, Colors.pink, Colors.purple];

    for (int i = 0; i < distribucionSexo.length; i++) {
      var sexo = distribucionSexo[i];
      if (sexo['total'] != null && sexo['total'] > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[i % colors.length],
            value: sexo['total'].toDouble(),
            title: '${sexo['sexo']}\n${sexo['total']}',
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    }

    if (sections.isEmpty) {
      return Container(
        height: 200,
        child: Center(child: Text('No hay datos de distribución por sexo')),
      );
    }

    return Container(
      height: 180,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 15,
            sectionsSpace: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildConsultasPorDiaChart() {
    List<dynamic> consultasPorDia = estadisticas!['consultas']?['por_dia_semana'] ?? [];

    if (consultasPorDia.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No hay datos de consultas por día'),
            ],
          ),
        ),
      );
    }

    Map<int, String> nombresDias = {
      1: 'Lun', 2: 'Mar', 3: 'Mié', 4: 'Jue',
      5: 'Vie', 6: 'Sáb', 7: 'Dom',
    };

    List<BarChartGroupData> barGroups = [];

    for (var consulta in consultasPorDia) {
      barGroups.add(
        BarChartGroupData(
          x: consulta['dia'] ?? 0,
          barRods: [
            BarChartRodData(
              toY: (consulta['total'] ?? 0).toDouble(),
              color: Colors.green.shade600,
              width: 25,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
    }

    double maxY = consultasPorDia
        .map((e) => e['total'] ?? 0)
        .reduce((a, b) => a > b ? a : b)
        .toDouble() + 2;

    return Container(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    nombresDias[value.toInt()] ?? '',
                    style: TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildEstadisticasEdadCards() {
    Map<String, dynamic> estadisticasEdad = estadisticas!['pacientes']?['estadisticas_edad'] ?? {};

    if (estadisticasEdad.isEmpty) {
      return Container(
        height: 100,
        child: Center(child: Text('No hay estadísticas de edad disponibles')),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            'Promedio',
            '${(estadisticasEdad['promedio'] ?? 0).toStringAsFixed(1)} años',
            Icons.trending_up,
            Colors.blue,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _buildInfoCard(
            'Mínima',
            '${estadisticasEdad['minima'] ?? 0} años',
            Icons.keyboard_arrow_down,
            Colors.green,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _buildInfoCard(
            'Máxima',
            '${estadisticasEdad['maxima'] ?? 0} años',
            Icons.keyboard_arrow_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticosChart() {
    List<dynamic> diagnosticosComunes = estadisticas!['diagnosticos']['top_comunes'] ?? [];

    if (diagnosticosComunes.isEmpty) {
      return Container(
        height: 100,
        child: Center(child: Text('No hay datos de diagnósticos')),
      );
    }

    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < diagnosticosComunes.length; i++) {
      var diagnostico = diagnosticosComunes[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: diagnostico['total'].toDouble(),
              color: Colors.red.shade400,
              width: 40,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: diagnosticosComunes.map((e) => e['total']).reduce((a, b) => a > b ? a : b).toDouble() + 1,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < diagnosticosComunes.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        diagnosticosComunes[value.toInt()]['enfermedad__tipo'],
                        style: TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildMedicamentosChart() {
    List<dynamic> topMedicamentos = estadisticas!['tratamientos']['top_medicamentos'] ?? [];

    if (topMedicamentos.isEmpty) {
      return Container(
        height: 100,
        child: Center(child: Text('No hay datos de medicamentos')),
      );
    }

    // Tomar solo los primeros 5 medicamentos
    List<dynamic> medicamentosLimitados = topMedicamentos.take(5).toList();

    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < medicamentosLimitados.length; i++) {
      var medicamento = medicamentosLimitados[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: medicamento['total'].toDouble(),
              color: Colors.purple.shade400,
              width: 35,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: medicamentosLimitados.map((e) => e['total']).reduce((a, b) => a > b ? a : b).toDouble() + 1,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < medicamentosLimitados.length) {
                    String nombre = medicamentosLimitados[value.toInt()]['medicamento__nombre_comercial'];
                    // Truncar nombre si es muy largo
                    if (nombre.length > 8) {
                      nombre = nombre.substring(0, 8) + '...';
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        nombre,
                        style: TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}