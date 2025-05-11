class EnfermedadPersistente {
  final int id;
  final String nombre;
  final String tipo;

  EnfermedadPersistente({required this.id, required this.nombre, required this.tipo});

  factory EnfermedadPersistente.fromJson(Map<String, dynamic> json) {
    return EnfermedadPersistente(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
    );
  }
}
