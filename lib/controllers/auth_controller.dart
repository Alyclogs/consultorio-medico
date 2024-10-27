import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthController {
  static Future<int> validarDNI(String dni, String nombre) async {
    final response = await http.get(Uri.parse('https://api.factiliza.com/pe/v1/dni/info/${dni.trim()}'), headers: {
      'Authorization': 'Bearer ${dotenv.env['FACTILIZA_TOKEN']}',
    },);
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      if ('${(data["data"]["nombres"] as String).trim()} ${(data["data"]["apellido_paterno"] as String).trim()} ${(data["data"]["apellido_materno"] as String).trim()}' != nombre.trim().toUpperCase()) {
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
}