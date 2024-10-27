import 'package:consultorio_medico/models/seleccionable.dart';

class Medico implements Seleccionable {
  final String id;
  @override
  final String nombre;
  @override
  final String titulo;
  final String descripcion;
  @override
  late String foto = "";
  final String cmp;

  Medico(
      {required this.id,
      required this.nombre,
      required this.titulo,
      required this.descripcion,
      required this.cmp});

  factory Medico.fromJson(Map<String, dynamic> data, String id) {
    final Medico medico = Medico(
        id: id,
        nombre: data["nombre"] as String,
        titulo: data["titulo"] as String,
        descripcion: data["descripcion"] as String,
        cmp: data["cmp"] as String);
    medico.foto = data["foto"] as String ?? "";
    return medico;
  }

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "titulo": titulo,
      "descripcion": descripcion,
      "foto": foto,
      "cmp": cmp
    };
  }
}
