import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consultorio_medico/models/notificacion.dart';
import 'package:consultorio_medico/models/providers/cita_provider.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../views/appointment_details_screen.dart';
import '../cita.dart';

class NotificationProvider {

  static final NotificationProvider instance = NotificationProvider._init();
  NotificationProvider._init();

  Future<List<Notificacion>> getNotifications(String usuarioId) async {
    try {
      final docs = await FirebaseFirestore.instance.collection('notifications').where('usuarioId', isEqualTo: usuarioId).get();
      return docs.docs.map((d) => Notificacion.fromJson(d.data(), int.parse(d.id))).toList();

    } catch (e) {
      print('Error while getting notifications from database');
      return [];
    }
  }

  Future<void> addNotification(Notificacion registro) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').doc('${registro.id}').set(registro.toJson());
    } catch (e) {
      print("Error adding notification to database: $e");
    }
  }

  Future<void> updateNotification(Notificacion registro) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').doc('${registro.id}').update(registro.toJson());
    } catch (e) {
      print("Error updating notification from database: $e");
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').doc('$notificationId').delete();
    } catch (e) {
      print("Error updating notification from database: $e");
    }
  }

  Future<void> removeOldNotifications() async {
    try {
      final now = DateTime.now();

      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('fechaCita', isLessThanOrEqualTo: now)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print("Notificaciones de citas pasadas eliminadas correctamente.");
    } catch (e) {
      print("Error al eliminar notificaciones antiguas: $e");
    }
  }

  Future<bool> navigateToAppointmentScreen(String appointmentId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('citas')
          .doc(appointmentId)
          .get();

      if (docSnapshot.exists) {
        final cita = Cita.fromJson(
            docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
        final pago = await CitaProvider.instance.getPago(cita.id);

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) =>
                AppointmentDetailsScreen(
                  cita: cita, pago: pago,
                ),
          ),
        );
        return true;
      }
    } catch (e) {
      print('Failed to navigate to appointment details screen');
      return false;
    }
    return false;
  }
}
