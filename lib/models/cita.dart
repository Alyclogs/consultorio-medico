import 'package:cloud_firestore/cloud_firestore.dart';

class Cita {
  String id;
  DateTime fecha;
  String dniUsuario;
  String nomPaciente;
  String dniPaciente;
  int edadPaciente;
  String idMedico;
  String nomMedico;
  String idSede;
  String nomSede;
  String motivo;
  double costo;
  String estado;

  Cita({
    required this.id,
    required this.fecha,
    required this.dniUsuario,
    required this.nomPaciente,
    required this.dniPaciente,
    required this.idMedico,
    required this.nomMedico,
    required this.idSede,
    required this.nomSede,
    required this.edadPaciente,
    required this.motivo,
    required this.costo,
    required this.estado,
  });

  factory Cita.fromJson(Map<String, dynamic> json, String id) {
    return Cita(
      id: id,
      fecha: (json['fecha'] as Timestamp).toDate(),
      dniUsuario: json['nomPaciente'] as String,
      nomPaciente: json['nomPaciente'] as String,
      dniPaciente: json['dniPaciente'] as String,
      edadPaciente: json['edadPaciente'] as int,
      idMedico: json['idMedico'] as String,
      nomMedico: json['nomMedico'] as String,
      idSede: json['idSede'] as String,
      nomSede: json['nomSede'] as String,
      motivo: json['motivo'] as String,
      costo: (json['costo'] as num).toDouble(),
      estado: json['estado'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': Timestamp.fromDate(fecha),
      'dniUsuario': dniUsuario,
      'nomPaciente': nomPaciente,
      'dniPaciente': dniPaciente,
      'edadPaciente': edadPaciente,
      'idMedico': idMedico,
      'nomMedico': nomMedico,
      'idSede': idSede,
      'nomSede': nomSede,
      'motivo': motivo,
      'costo': costo,
      'estado': estado,
    };
  }
}
