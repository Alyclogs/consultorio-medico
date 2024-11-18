import 'package:consultorio_medico/models/cita.dart';
import 'package:consultorio_medico/models/providers/cita_provider.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/models/usuario.dart';
import 'package:consultorio_medico/views/appointment_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medico.dart';
import '../models/providers/medico_provider.dart';
import '../models/providers/sede_provider.dart';
import '../models/sede.dart';
import 'new_appointment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Usuario currentUser = UsuarioProvider.instance.usuarioActual;
  late List<Cita> citas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCitas();
  }

  Future<void> _loadCitas() async {
    try {
      citas = await CitaProvider.instance.getRegistros(UsuarioProvider.instance.usuarioActual.id, "PENDIENTE");
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar citas: $e');
    }
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
            Expanded(child:
            SingleChildScrollView(
              child:
                    _listaCitas(context, citas.length > 2 ? citas.sublist(0,2) : citas),
            ),
            ),
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
          ],
        ),
      ),
    );
  }

  Widget _listaCitas(BuildContext context, List<Cita> citas) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (citas.isNotEmpty)
            ...citas.map((cita) => FutureBuilder<Widget>(
              future: _buildCita(cita),
              builder:
                  (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return snapshot.data ?? SizedBox();
                }
              },
            ))
          else
            Center(child: Text("No hay citas para mostrar")),
          SizedBox(height: 62),
        ],
    );
  }

  Future<Widget> _buildCita(Cita cita) async {
    final Medico? medico = await MedicoProvider.instance.getRegistro(cita.idMedico);
    final Sede? sede = await SedeProvider.instance.getRegistro(cita.idSede);

    return GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentDetailsScreen(cita: cita, nombreMedico: medico!.nombre, nombreSede: sede!.nombre,))),
        child: Card(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 3,
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: Image.asset(
                      "assets/images/usuario.png",
                      width: 46.0,
                      height: 46.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            medico != null
                                ? medico.nombre
                                : "Médico",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xff0c4454))),
                        SizedBox(height: 10),
                        Text(
                            sede != null ? sede.nombre : "Sede",
                            style: TextStyle(fontSize: 11)),
                        SizedBox(height: 20),
                        Text(cita.motivo, style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              if (cita.estado != "FINALIZADO")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        UsuarioProvider.instance.usuarioActual.sendNotifications
                            ? "Alerta activada"
                            : "Alerta desactivada",
                        style: TextStyle(fontSize: 11)),
                    Text(DateFormat('dd/MM/yyyy').format(cita.fecha),
                        style: TextStyle(fontSize: 11)),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(DateFormat('dd/MM/yyyy').format(cita.fecha),
                        style: TextStyle(fontSize: 11)),
                  ],
                ),
              if (cita.estado == "FINALIZADO")
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 6),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.all(12),
                      side: BorderSide(width: 1, color: Color(0xFF5494a3)),
                      overlayColor: Color(0xFF5494a3),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF5494a3),
                          size: 11,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Ver resultado",
                          style:
                          TextStyle(fontSize: 11, color: Color(0xFF5494a3)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        ),
    );
  }
}
