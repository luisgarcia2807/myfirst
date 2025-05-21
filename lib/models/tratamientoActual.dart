class TratamientoFrecuente1{
  final int id;
  final String nombre;
  final String principioActivo;
  final String concentracion;
  final String via_administracion;


  TratamientoFrecuente1( {
    required this.id,
    required this.nombre,
    required this.principioActivo,
    required this.concentracion,
    required this.via_administracion

  });

  factory TratamientoFrecuente1.fromJson(Map<String, dynamic> json) {
    return TratamientoFrecuente1(
      id: json['id'],
      nombre: json['nombre_comercial'],
      principioActivo: json["principio_activo"],
      concentracion: json["concentracion"],
      via_administracion: json["via_administracion"]

    );
  }
}
