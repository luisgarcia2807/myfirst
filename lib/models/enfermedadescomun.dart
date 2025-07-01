class EnfermedadComun {
  final int id;
  final String nombre;
  final String tipo;

  EnfermedadComun({required this.id, required this.nombre, required this.tipo});

  factory EnfermedadComun.fromJson(Map<String, dynamic> json) {
    return EnfermedadComun(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
    );
  }
}