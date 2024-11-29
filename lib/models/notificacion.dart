import 'package:cloud_firestore/cloud_firestore.dart';

class Notificacion {
  int id;
  String citaId;
  DateTime fechaCita;
  String usuarioId;
  String title;
  String body;
  DateTime? timestamp;

  Notificacion(this.id, this.citaId, this.fechaCita, this.usuarioId, this.title, this.body);

  factory Notificacion.fromJson(Map<String, dynamic> data, int id) {
    final notification = Notificacion(id, data["citaId"] as String, (data["fechaCita"] as Timestamp).toDate(), data['usuarioId'] as String, data["title"] as String,
        data["body"] as String);
    if (data["timestamp"] != null) {
      notification.timestamp = (data["timestamp"] as Timestamp).toDate();
    }
    return notification;
  }

  Map<String, dynamic> toJson() {
    return {
      "citaId": citaId,
      "fechaCita": fechaCita,
      "usuarioId": usuarioId,
      "title": title,
      "body": body,
      "timestamp": timestamp
    };
  }
}
