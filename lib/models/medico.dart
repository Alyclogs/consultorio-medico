import 'package:consultorio_medico/models/seleccionable.dart';

class Medico implements Seleccionable {
  final String id;
  @override
  final String nombre;
  @override
  final String titulo;
  final String idSede;
  final String descripcion;
  final double costoCita;
  @override
  late String foto = "";
  final String cmp;
  final Map<String, String> disponibilidad;

  Medico(
      {required this.id,
      required this.nombre,
      required this.titulo,
        required this.idSede,
      required this.descripcion,
      required this.costoCita,
      required this.cmp,
      required this.disponibilidad});

  factory Medico.fromJson(Map<String, dynamic> data, String id) {
    final Medico medico = Medico(
        id: id,
        nombre: data["nombre"] as String,
        titulo: data["titulo"] as String,
        idSede: data["idSede"] as String,
        descripcion: data["descripcion"] as String,
        costoCita: (data['costoCita'] as num).toDouble(),
        cmp: data["cmp"] as String,
        disponibilidad: Map<String, String>.from(
            data["disponibilidad"] as Map<String, dynamic>));
    medico.foto = data["foto"] as String ?? "";
    return medico;
  }

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "titulo": titulo,
      "idSede": idSede,
      "descripcion": descripcion,
      "costoCita": costoCita,
      "foto": foto,
      "cmp": cmp,
      "disponibilidad": disponibilidad
    };
  }
}
