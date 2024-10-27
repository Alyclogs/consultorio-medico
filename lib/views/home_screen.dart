import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/models/usuario.dart';
import 'package:flutter/material.dart';
import 'new_appointment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Usuario currentUser = UsuarioProvider.instance.usuarioActual;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipOval(
                  child: currentUser.foto.isNotEmpty
                      ? Image.network(currentUser.foto,
                          width: 46.0, height: 46.0, fit: BoxFit.cover)
                      : Image.asset('assets/images/usuario.png',
                          width: 46.0, height: 46.0, fit: BoxFit.cover),
                ),
                SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: Text(
                    'Buenos días ${currentUser.nombre.split(' ').first}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,  // Adds ellipsis if the text overflows
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No hay reservas pendientes',
                        style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(height: 16),
                    Container(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(0xFF5494a3),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => NewAppointmentScreen()),
                          );
                        },
                        child: Text('Reservar una cita',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
