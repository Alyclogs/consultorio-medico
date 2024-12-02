import 'package:consultorio_medico/controllers/auth_controller.dart';
import 'package:consultorio_medico/controllers/net_controller.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/views/components/bottom_navbar.dart';
import 'package:flutter/material.dart';
import '../models/providers/cita_provider.dart';
import '../models/providers/notificacion_provider.dart';
import '../models/usuario.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  final String action;
  const SplashScreen({super.key, required this.action});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final netController = NetworkController();

  @override
  void initState() {
    super.initState();
    netController.checkInternetConnection(onInternetConnected: () {
      setState(() {});
      _initAction();
    }, onInternetDisconnected: () {
      setState(() {});
      _initAction();
    });
  }

  @override
  void dispose() {
    super.dispose();
    netController.listener.cancel();
  }

  void _initAction() async {
    final action = widget.action;
    if (action == 'login') {
      if (netController.hasInternet) {
        await CitaProvider.instance.checkAppointmentsStatus();
        await NotificationProvider.instance.removeOldNotifications();

        AuthController.iniciarSesion((usuario) => _onSesionFound(usuario),
                () => _navigateTo(LoginScreen()));
        return;
      }
    }
    if (action == 'checkInternet') {
      if (netController.hasInternet) {
        Navigator.pop(context);
      }
    }
  }

  void _onSesionFound(Usuario usuario) {
    setState(() {
      UsuarioProvider.instance.usuarioActual = usuario;
    });
    _navigateTo(BottomNavBar());
  }

  void _navigateTo(Widget screen) {
    Future.delayed(
        Duration(seconds: 1),
        () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => screen),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5494a3),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
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
            if (!netController.hasInternet) ...[
              Text(
                'Parece que no tienes conexión a internet. Verifica tu conexión e inténtalo de nuevo',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton(
                    onPressed: netController.checkInternetConnection,
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.all(16),
                        side: BorderSide(color: Colors.white)),
                    child: Text(
                      'Reintentar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ))
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
