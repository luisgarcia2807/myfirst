class CentroMedico {
  final int idcentromedico;
  final String nombre;

  CentroMedico({
    required this.idcentromedico,
    required this.nombre,
  });

  // Método para crear un objeto CentroMedico desde un JSON
  factory CentroMedico.fromJson(Map<String, dynamic> json) {
    return CentroMedico(
      idcentromedico: json['idcentromedico'],
      nombre: json['nombre'],
    );
  }
}
