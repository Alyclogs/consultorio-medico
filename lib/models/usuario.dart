class Usuario {
  final String id;
  final String nombre;
  final String telefono;
  late String contrasena = "";
  final int edad;
  final String genero;
  late String foto = "";
  late bool sendNotifications = false;

  Usuario({required this.id, required this.nombre, required this.telefono, required this.edad, required this.genero});

  factory Usuario.fromJson (Map<String, dynamic> data, String id) {
    Usuario usuario = Usuario(id: id, nombre: data["nombre"],
        telefono: data["telefono"], edad: data["edad"], genero: data["genero"]);
    usuario.contrasena = data["contrasena"] ?? "";
    usuario.foto = data["foto"] ?? "";
    usuario.sendNotifications = data["sendNotifications"] ?? false;
    return usuario;
  }

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "telefono": telefono,
      "contrasena": contrasena,
      "edad": edad,
      "genero": genero,
      "foto": foto,
      "sendNotifications": sendNotifications ?? false
    };
  }
}

