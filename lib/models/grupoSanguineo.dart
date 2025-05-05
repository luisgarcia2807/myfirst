class GrupoSanguineo {
  final int idSangre;
  final String tipoSangre;

  GrupoSanguineo({required this.idSangre, required this.tipoSangre});

  factory GrupoSanguineo.fromJson(Map<String, dynamic> json) {
    return GrupoSanguineo(
      idSangre: json['id_sangre'],
      tipoSangre: json['tipo_sangre'],
    );
  }
}
