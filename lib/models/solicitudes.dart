class SolicitudDoctorPaciente {
  final int id;
  final String comentario;
  final String estado;
  final String creadoEn;
  final String? aprobadoEn;
  final int doctor;
  final int paciente;
  final String pacienteNombre;
  final String pacienteApellido;
  final String pacienteCedula;

  SolicitudDoctorPaciente({
    required this.id,
    required this.comentario,
    required this.estado,
    required this.creadoEn,
    this.aprobadoEn,
    required this.doctor,
    required this.paciente,
    required this.pacienteNombre,
    required this.pacienteApellido,
    required this.pacienteCedula,
  });

  factory SolicitudDoctorPaciente.fromJson(Map<String, dynamic> json) {
    return SolicitudDoctorPaciente(
      id: json['id'],
      comentario: json['comentario'],
      estado: json['estado'],
      creadoEn: json['creado_en'],
      aprobadoEn: json['aprobado_en'],
      doctor: json['doctor'],
      paciente: json['paciente'],
      pacienteNombre: json['paciente_nombre'],
      pacienteApellido: json['paciente_apellido'],
      pacienteCedula: json['paciente_cedula'],
    );
  }
}
