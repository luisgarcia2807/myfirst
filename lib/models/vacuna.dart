class Vacuna {
  final int id;
  final String nombre;
  final int maxDosis;

  Vacuna({
    required this.id,
    required this.nombre,
    required this.maxDosis,
  });

  factory Vacuna.fromJson(Map<String, dynamic> json) {
    return Vacuna(
      id: json['id'],
      nombre: json['nombre'],
      maxDosis: json['max_dosis'],
    );
  }
}
