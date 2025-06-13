class PerfilBebe {
  final int id;
  final String nombre;
  final String apellido;
  final DateTime fechaNacimiento;
  final String sexo;

  PerfilBebe({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.fechaNacimiento,
    required this.sexo,
  });

  factory PerfilBebe.fromJson(Map<String, dynamic> json) {
    return PerfilBebe(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento']),
      sexo: json['sexo'],
    );
  }
}
