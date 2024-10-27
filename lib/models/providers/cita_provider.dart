import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consultorio_medico/models/cita.dart';
import 'package:consultorio_medico/models/pago.dart';
import 'package:intl/intl.dart';

class CitaProvider {
  static final CitaProvider instance = CitaProvider._init();
  final CollectionReference bd = FirebaseFirestore.instance.collection('citas');

  CitaProvider._init();

  Future<List<Cita>> getRegistros(String id, [String estado = ""]) async {
    QuerySnapshot querySnapshot = await bd.get();
    final docs = querySnapshot.docs
        .map((doc) => Cita.fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .where((cita) => cita.id.startsWith('Cita_${id}'));
    if (estado.isEmpty) {
      return docs.toList();
    } else {
      return docs.where((cita) => cita.estado == estado).toList();
    }
  }

  Future<Cita?> getRegistro(String id) async {
    final doc = await bd.doc(id).get();
    return Cita.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<Pago> getPago(String idCita) async {
    final snapshot = await FirebaseFirestore.instance.collection('pagos').where('idCita', isEqualTo: idCita).limit(1).get();
    return snapshot.docs.map((e) => Pago.fromJson(e.data(), e.id)).toList()[0];
  }

  Future<void> addRegistro(Cita cita) async {
    final Map<String, dynamic> pagoData = {
      "idCita": cita.id,
      "fecha": DateTime.now().toLocal(),
      "monto": cita.costo,
      "motivo": "Pago cita MedicArt"
    };
    await bd.add(cita.toJson());
    await FirebaseFirestore.instance.collection('pagos').add(pagoData);
  }

  Future<void> updateRegistro(Cita cita, String id) async {
    await bd.doc(id).update(cita.toJson());
  }

  Future<void> deleteRegistro(String id) async {
    await bd.doc(id).delete();
  }

  Future<String> generarNuevoId(DateTime fecha) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('citas')
        .where('fecha',
        isGreaterThanOrEqualTo: DateTime(fecha.year, fecha.month, fecha.day))
        .where('fecha',
        isLessThanOrEqualTo: DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59))
        .get();

    Set<String> idsExistentes = snapshot.docs.map((doc) => doc['id'] as String).toSet();

    String nuevoId;
    Random random = Random();
    do {
      String letra = String.fromCharCode(random.nextInt(26) + 65);
      String numeros = (1000 + random.nextInt(9000)).toString();

      nuevoId = '$letra$numeros';
    } while (idsExistentes.contains(nuevoId));

    return nuevoId;
  }
}
