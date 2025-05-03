class Especialidad {
  final int idEspecialidad;
  final String nombreEspecialidad;

  Especialidad({required this.idEspecialidad, required this.nombreEspecialidad});

  factory Especialidad.fromJson(Map<String, dynamic> json) {
    return Especialidad(
      idEspecialidad: json['id_especialidad'],
      nombreEspecialidad: json['nombre_especialidad'],
    );
  }
}
