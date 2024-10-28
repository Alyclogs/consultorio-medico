import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consultorio_medico/models/sede.dart';

class SedeProvider{
  static final SedeProvider instance = SedeProvider._init();
  final CollectionReference bd = FirebaseFirestore.instance.collection('sedes');
  late Sede sedeActual;

  SedeProvider._init();

  Future<List<Sede>> getRegistros() async {
    QuerySnapshot querySnapshot = await bd.get();
    return querySnapshot.docs.map((doc) => Sede.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<Sede?> getRegistro(String id) async {
    final doc = await bd.doc(id).get();
    return Sede.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<Sede?> getRegistroFromNombre(String nombre) async {
    final docs = await bd.where('nombre', isEqualTo: nombre).get();
    return docs.docs.isNotEmpty ? docs.docs.map((doc) => Sede.fromJson(doc.data() as Map<String, dynamic>, doc.id)).first : null;
  }

  Future<void> addRegistro(Sede sede, String id) async {
    await bd.doc(id).set(sede.toJson());
  }

  Future<void> updateRegistro(Sede sede, String id) async {
    await bd.doc(id).update(sede.toJson());
  }

  Future<void> deleteRegistro(String id) async {
    await bd.doc(id).delete();
  }
}