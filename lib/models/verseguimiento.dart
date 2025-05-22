class Seguimiento {
  final int id;
  final String fecha;
  final String comentario;
  final String archivo;

  Seguimiento({
    required this.id,
    required this.fecha,
    required this.comentario,
    required this.archivo,
  });

  factory Seguimiento.fromJson(Map<String, dynamic> json) {
    return Seguimiento(
      id: json['id'],
      fecha: json['fecha'],
      comentario: json['comentario'],
      archivo: json['archivo'],
    );
  }
}
