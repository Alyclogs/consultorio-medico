import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consultorio_medico/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioProvider {
  static final UsuarioProvider instance = UsuarioProvider._init();
  final CollectionReference bd =
      FirebaseFirestore.instance.collection('usuarios');
  late Usuario usuarioActual;

  UsuarioProvider._init();

  Future<List<Usuario>> getRegistros() async {
    QuerySnapshot querySnapshot = await bd.get();
    return querySnapshot.docs
        .map((doc) =>
            Usuario.fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<Usuario?> getRegistro(String id) async {
    final doc = await bd.doc(id).get();
    return doc.exists
        ? Usuario.fromJson(doc.data() as Map<String, dynamic>, doc.id)
        : null;
  }

  Future<Usuario?> getRegistroPorNumero(String id, String numero) async {
    final match = await bd.doc(id).get();
    return match.exists &&
            (match.data() as Map<String, dynamic>)["telefono"] == numero
        ? Usuario.fromJson(match.data() as Map<String, dynamic>, match.id)
        : null;
  }

  Future<void> addRegistro(Usuario usuario, String id) async {
    await bd.doc(id).set(usuario.toJson());
  }

  Future<void> updateRegistro(Usuario usuario) async {
    await bd.doc(usuario.id).update(usuario.toJson());
  }

  Future<void> deleteRegistro(String id) async {
    await bd.doc(id).delete();
  }

  Future<bool> validarUsuario(String id, String pass) async {
    final registro = await bd.doc(id).get();
    return registro.exists
        ? Usuario.fromJson(registro.data() as Map<String, dynamic>, registro.id)
                .contrasena ==
            pass
        : false;
  }

  Future<void> guardarSesion(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario_id', id);
  }

  Future<String?> obtenerSesionGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario_id');
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_id');
  }
}
