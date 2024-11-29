import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consultorio_medico/models/cita.dart';
import 'package:consultorio_medico/models/pago.dart';
import 'package:flutter/material.dart';

import 'medico_provider.dart';

class CitaProvider {
  static final CitaProvider instance = CitaProvider._init();
  final CollectionReference bd = FirebaseFirestore.instance.collection('citas');

  CitaProvider._init();

  Future<List<Cita>> getRegistros(String id, [String estado = ""]) async {
    QuerySnapshot querySnapshot =
        await bd.where('dniUsuario', isEqualTo: id).get();
    final docs = querySnapshot.docs.map(
        (doc) => Cita.fromJson(doc.data() as Map<String, dynamic>, doc.id));
    if (estado.isEmpty) {
      return docs.toList();
    } else {
      return docs
          .where((cita) => estado == "PENDIENTE"
              ? cita.estado == "PENDIENTE" || cita.estado == "EN PROCESO"
              : estado == "FINALIZADO"
                  ? cita.estado == "FINALIZADO" ||
                      cita.estado == "ELIMINADO POR EL USUARIO"
                  : cita.estado == estado)
          .toList();
    }
  }

  Future<Cita?> getRegistro(String id) async {
    final doc = await bd.doc(id).get();
    return Cita.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<Pago> getPago(String idCita) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('pagos')
        .where('idCita', isEqualTo: idCita)
        .limit(1)
        .get();
    return snapshot.docs.map((e) => Pago.fromJson(e.data(), e.id)).toList()[0];
  }

  Future<void> addRegistro(Cita cita) async {
    final Map<String, dynamic> pagoData = {
      "idCita": cita.id,
      "fecha": DateTime.now().toLocal(),
      "monto": cita.costo,
      "motivo": "Pago cita MedicArt"
    };
    await bd.doc(cita.id).set(cita.toJson());
    await FirebaseFirestore.instance.collection('pagos').add(pagoData);
  }

  Future<void> updateRegistro(Cita cita) async {
    await bd.doc(cita.id).update(cita.toJson());
  }

  Future<void> deleteRegistro(String id) async {
    await bd.doc(id).delete();
  }

  Future<List<TimeOfDay?>> obtenerHorariosOcupados(
      String idSede, List<DateTime> horarioDoctor) async {
    try {
      print('Obteniendo horarios ocupados con el horario $horarioDoctor');
      final inicioDelDia = horarioDoctor[0];
      final finDelDia = horarioDoctor[1];

      final QuerySnapshot querySnapshot = await bd
          .where('idSede', isEqualTo: idSede)
          .where('fecha',
              isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDelDia))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(finDelDia))
          .get();

      List<TimeOfDay?> horariosOcupados = querySnapshot.docs
          .map((doc) {
            if (doc['estado'] == "ELIMINADO POR EL USUARIO") {
              return null;
            }
            Timestamp timestamp = doc['fecha'] as Timestamp;
            DateTime dateTime = timestamp.toDate();

            if (dateTime.isBefore(DateTime.now())) {
              return null;
            }
            return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
          })
          .where((hora) => hora != null)
          .toList();

      return horariosOcupados ?? [];
    } catch (e) {
      debugPrint('Error al obtener horarios ocupados: $e');
      return [];
    }
  }

  Future<bool> verificarCitaAgendada(
      String dniPaciente, DateTime fechaSeleccionada) async {
    try {
      final inicioDelDia = DateTime(fechaSeleccionada.year,
          fechaSeleccionada.month, fechaSeleccionada.day, 0, 0, 0);
      final finDelDia = DateTime(fechaSeleccionada.year,
          fechaSeleccionada.month, fechaSeleccionada.day, 23, 59, 59, 999);

      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('citas')
          .where('dniPaciente', isEqualTo: dniPaciente)
          .where('fecha',
              isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDelDia))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(finDelDia))
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar cita agendada: $e');
      return false;
    }
  }

  Future<String> generarNuevoId(DateTime fecha) async {
    QuerySnapshot snapshot = await bd
        .where('fecha',
            isGreaterThanOrEqualTo:
                DateTime(fecha.year, fecha.month, fecha.day))
        .where('fecha',
            isLessThanOrEqualTo:
                DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59))
        .get();

    Set<String> idsExistentes = snapshot.docs.map((doc) => doc.id).toSet();

    String nuevoId;
    Random random = Random();
    do {
      String letra = String.fromCharCode(random.nextInt(26) + 65);
      String numeros = (1000 + random.nextInt(9000)).toString();

      nuevoId = '$letra$numeros';
    } while (idsExistentes.contains(nuevoId));

    return nuevoId;
  }

  Future<void> checkAppointmentsStatus() async {
    final now = DateTime.now();

    try {
      final QuerySnapshot pendienteSnapshot =
          await bd.where('estado', isEqualTo: 'PENDIENTE').get();

      print("Verificando estado: citas pendientes");
      for (QueryDocumentSnapshot doc in pendienteSnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final DateTime fechaCita = (data['fecha'] as Timestamp).toDate();

        if (fechaCita.isAtSameMomentAs(now) ||
            now.difference(fechaCita).inMinutes <= 15) {
          await bd.doc(doc.id).update({
            'estado': 'EN PROCESO',
          });
        } else if (now.difference(fechaCita).inMinutes >= 20) {
          await bd.doc(doc.id).update({
            'estado': 'FINALIZADO',
          });
        }
      }

      print("Verificando estado: citas en proceso");
      final QuerySnapshot enProcesoSnapshot =
          await bd.where('estado', isEqualTo: 'EN PROCESO').get();

      for (QueryDocumentSnapshot doc in enProcesoSnapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final DateTime fechaCita = (data['fecha'] as Timestamp).toDate();

        if (now.difference(fechaCita).inMinutes >= 20) {
          await bd.doc(doc.id).update({
            'estado': 'FINALIZADO',
          });
        }
      }
      print('Estado de citas verificada correctamente');
    } catch (e) {
      print('Error al monitorear citas: $e');
    }
  }
}
