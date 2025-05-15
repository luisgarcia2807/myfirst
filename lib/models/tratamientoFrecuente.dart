class TratamientoFrecuente {
  final int id;
  final String nombre;


  TratamientoFrecuente({
    required this.id,
    required this.nombre,

  });

  factory TratamientoFrecuente.fromJson(Map<String, dynamic> json) {
    return TratamientoFrecuente(
      id: json['id'],
      nombre: json['nombre'],

    );
  }
}
