class Examen {
  final int id;
  final String nombreExamen;
  final String descripcion;
  final String fechaRealizacion;
  final String archivo;
  final String tipo;
  final String categoria;
  Examen({
    required this.id,
    required this.nombreExamen,
    required this.descripcion,
    required this.fechaRealizacion,
    required this.archivo,
    required this.tipo,
    required this.categoria,
  });

  factory Examen.fromJson(Map<String, dynamic> json) {
    return Examen(
      id: json['id'],
      nombreExamen: json['nombre_examen'],
      descripcion: json['descripcion'],
      fechaRealizacion: json['fecha_realizacion'],
      archivo: json['archivo'],
      tipo: json['tipo'],
      categoria: json['categoria']
    );
  }
}
