import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class Usuario {
  final String id;
  final String nombre;
  final String telefono;
  late String contrasena = "";
  final DateTime fecha_nac;
  final String genero;
  late String foto = "";

  Usuario({required this.id, required this.nombre, required this.telefono, required this.fecha_nac, required this.genero});

  factory Usuario.fromJson (Map<String, dynamic> data, String id) {
    Usuario usuario = Usuario(id: id, nombre: data["nombre"],
        telefono: data["telefono"], fecha_nac: (data["fecha_nac"] as Timestamp).toDate(), genero: data["genero"]);
    usuario.contrasena = data["contrasena"] ?? "";
    usuario.foto = data["foto"] ?? "";
    return usuario;
  }

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "telefono": telefono,
      "contrasena": encryptPassword(contrasena),
      "fecha_nac": fecha_nac,
      "genero": genero,
      "foto": foto
    };
  }

  static String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}

