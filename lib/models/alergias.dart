class Alergia {
  final int id;
  final String nombre;
  final String tipo;

  Alergia({required this.id, required this.nombre, required this.tipo});

  // Constructor de fábrica para convertir JSON en objeto Alergia
  factory Alergia.fromJson(Map<String, dynamic> json) {
    return Alergia(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
    );
  }
}