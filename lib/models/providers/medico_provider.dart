import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consultorio_medico/models/medico.dart';

class MedicoProvider{
  static final MedicoProvider instance = MedicoProvider._init();
  final CollectionReference bd = FirebaseFirestore.instance.collection('medicos');

  MedicoProvider._init();

  Future<List<Medico>> getRegistros() async {
    QuerySnapshot querySnapshot = await bd.get();
    return querySnapshot.docs.map((doc) => Medico.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<Medico?> getRegistro(String id) async {
    final doc = await bd.doc(id).get();
    return Medico.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> addRegistro(Medico usuario) async {
    String id = await obtenerNuevoId();
    await bd.doc(id).set(usuario.toJson());
  }

  Future<void> updateRegistro(Medico usuario, String id) async {
    await bd.doc(id).update(usuario.toJson());
  }

  Future<void> deleteRegistro(String id) async {
    await bd.doc(id).delete();
  }

  Future<String> obtenerNuevoId() async {
    QuerySnapshot snapshot = await bd.get();
    List<QueryDocumentSnapshot> docs = snapshot.docs;

    if (docs.isEmpty) {
      return 'Med-1001';
    }

    String ultimoId = docs.last.id;
    int numeroUltimo = int.parse(ultimoId.split('-')[1]);
    int nuevoNumero = numeroUltimo + 1;

    return 'Med-$nuevoNumero';
  }
}