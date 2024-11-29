import 'package:consultorio_medico/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../models/providers/usuario_provider.dart';

class AuthController {
  static Future<void> iniciarSesion(
      Function(Usuario) onSesionFound, Function() onSesionNotFound) async {
    final sesionId = await UsuarioProvider.instance.obtenerSesionGuardada();
    print("Sesión encontrada: $sesionId");

    if (sesionId != null && sesionId.isNotEmpty) {
      final usuario = await UsuarioProvider.instance.getRegistro(sesionId);
      if (usuario != null) {
        onSesionFound(usuario);
        return;
      }
    }
    onSesionNotFound();
  }

  static Future<int> validarDNI(String dni, String nombre, String sexo,
      {DateTime? fecha}) async {
    final response = await http.get(
      Uri.parse('https://api.factiliza.com/pe/v1/dni/info/${dni.trim()}'),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['FACTILIZA_TOKEN']}',
      },
    );
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      final nombres = (data["data"]["nombres"] as String).trim();
      final apellidos =
          '${(data["data"]["apellido_paterno"] as String).trim()} ${(data["data"]["apellido_materno"] as String).trim()}';
      final fechaNac = (data["data"]["fecha_nacimiento"] as String).trim();

      if ('$nombres $apellidos' != nombre.trim().toUpperCase() ||
          ((fecha != null &&
                  fechaNac != DateFormat('dd/MM/yyyy').format(fecha).trim()) ||
              (data["data"]["sexo"] as String).trim() != sexo.trim())) {
        return 400;
      } else {
        return 200;
      }
    } else if (response.statusCode == 401) {
      return 401;
    } else if (response.statusCode == 404) {
      return 404;
    }
    return 400;
  }

  static int calcularEdad(DateTime fechaNacimiento) {
    DateTime fechaActual = DateTime.now();
    int edad = fechaActual.year - fechaNacimiento.year;

    if (fechaActual.month < fechaNacimiento.month ||
        (fechaActual.month == fechaNacimiento.month &&
            fechaActual.day < fechaNacimiento.day)) {
      edad--;
    }

    return edad;
  }
}
