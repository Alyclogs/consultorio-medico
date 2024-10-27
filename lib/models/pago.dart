import 'package:cloud_firestore/cloud_firestore.dart';

class Pago {
  final String id;
  final String idCita;
  final DateTime fecha;
  final double monto;
  final String motivo;

  Pago({
    required this.id,
    required this.idCita,
    required this.fecha,
    required this.monto,
    required this.motivo,
  });

  factory Pago.fromJson (Map<String, dynamic> data, String id) {
    return Pago(id: id, idCita: data["idCita"], fecha: (data['fecha'] as Timestamp).toDate(), monto: data["monto"] as double, motivo: data["motivo"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "idCita": idCita,
      "fecha": Timestamp.fromDate(fecha),
      "monto": monto,
      "motivo": motivo
    };
  }
}
