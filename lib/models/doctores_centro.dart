class Doctor {
  final int idDoctor;
  final int id_usuario;
  final String nombre;
  final String apellido;
  final String cedula;
  final String numeroLicencia;
   bool activo;

  Doctor({
    required this.idDoctor,
    required this.id_usuario,
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.numeroLicencia,
    required this.activo,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      idDoctor: json['id_doctor'],
      id_usuario: json['id_usuario']['id_usuario'],
      nombre: json['id_usuario']['nombre'],
      apellido: json['id_usuario']['apellido'],
      cedula: json['id_usuario']['cedula'],
      numeroLicencia: json['numero_licencia'],
      activo: json['activo'],
    );
  }
}
