import 'package:consultorio_medico/models/seleccionable.dart';

class Sede implements Seleccionable {
  final String id;
  @override
  final String nombre;
  final String direccion;
  final String coordenadas;
  @override
  late String foto = "";

  Sede(this.id, this.nombre, this.direccion, this.coordenadas);

  factory Sede.fromJson(Map<String, dynamic> data, String id) {
    final Sede sede = Sede(id, data["nombre"] as String,
        data["direccion"], data["coordenadas"]);
    sede.foto = data["foto"] as String;
    return sede;
  }

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "direccion": direccion,
      "coordenadas": coordenadas,
      "foto": foto
    };
  }

  @override
  String get titulo => direccion;
}
