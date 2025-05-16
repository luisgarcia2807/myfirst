class Examen {
  final int id;
  final String nombreExamen;
  final String descripcion;
  final String fechaRealizacion;
  final String archivo;

  Examen({
    required this.id,
    required this.nombreExamen,
    required this.descripcion,
    required this.fechaRealizacion,
    required this.archivo,
  });

  factory Examen.fromJson(Map<String, dynamic> json) {
    return Examen(
      id: json['id'],
      nombreExamen: json['nombre_examen'],
      descripcion: json['descripcion'],
      fechaRealizacion: json['fecha_realizacion'],
      archivo: json['archivo'],
    );
  }
}
