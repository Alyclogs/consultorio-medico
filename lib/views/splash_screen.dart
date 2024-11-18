import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/views/components/bottom_navbar.dart';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  String? _usuarioId;
  Usuario? _usuarioActual;

  @override
  void initState() {
    super.initState();
    _iniciarSesion();
  }

  Future<void> _iniciarSesion() async {
    final sesionId = await UsuarioProvider.instance.obtenerSesionGuardada();
    print("Sesión encontrada: $sesionId");

    if (sesionId != null && sesionId.isNotEmpty) {
      final usuario = await UsuarioProvider.instance.getRegistro(sesionId);
      if (usuario != null) {
        setState(() {
          _usuarioId = sesionId;
          _usuarioActual = usuario;
          UsuarioProvider.instance.usuarioActual = _usuarioActual!;
        });
        _navegarHacia(BottomNavBar());
        return;
      }
    }
    _navegarHacia(LoginScreen());
  }

  void _navegarHacia(Widget pantalla) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => pantalla),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5494a3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/heart-pulse_white.png'),
            const SizedBox(height: 10),
            const Text(
              'MedicArt',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}