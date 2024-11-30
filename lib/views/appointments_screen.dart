import 'package:consultorio_medico/controllers/date_formatter.dart';
import 'package:consultorio_medico/models/providers/cita_provider.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/models/usuario.dart';
import 'package:consultorio_medico/views/components/loading_screen.dart';
import 'package:consultorio_medico/views/components/utils.dart';
import 'package:consultorio_medico/views/edit_appointment_screen.dart';
import 'package:consultorio_medico/views/new_appointment_screen.dart';
import 'package:consultorio_medico/views/resultado_cita_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/notifications_controller.dart';
import '../models/cita.dart';
import '../models/pago.dart';
import 'appointment_details_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  final int initialIndex;

  const AppointmentsScreen({super.key, this.initialIndex = 0});

  @override
  State<StatefulWidget> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  DateFormatter dateFormatter = DateFormatter();
  CitaProvider bd = CitaProvider.instance;
  Usuario usuarioActual = UsuarioProvider.instance.usuarioActual;
  late List<Cita> citasPendientes = [];
  late List<Cita> citasFinalizadas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCitas();
  }

  Future<void> _loadCitas() async {
    try {
      citasPendientes = await bd.getRegistros(usuarioActual.id, "PENDIENTE");
      citasFinalizadas = await bd.getRegistros(usuarioActual.id, "FINALIZADO");
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar citas: $e');
    }
  }

  void _showDeleteDialog(Cita cita) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Precaución'),
          content: Text('¿Está seguro de que desea eliminar la cita?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                loadingScreen(context);
                await bd.deleteRegistro(cita.id);
                await _loadCitas();
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                cita.estado = "ELIMINADO POR EL USUARIO";
                await CitaProvider.instance.updateRegistro(cita);
                showInfoDialog(
                    context,
                    """Se ha eliminado la cita, para consultar el estado de tu reembolso, por favor envía un mensaje al siguiente correo con el código ${cita.id}
                    """,
                    'aquirozag@ucvvirtual.edu.pe',
                    onClickLink: () async => await launchUrl(
                        Uri(scheme: 'mailto', path: 'aquirozag@ucvvirtual.edu.pe')));
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              indicatorColor: Color(0xFF5494a3),
              labelColor: Color(0xFF5494a3),
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.grey[400],
              tabs: [
                Tab(child: Text('Citas pendientes')),
                Tab(child: Text('Historial de citas')),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _listaCitas(context, citasPendientes),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _listaCitas(context, citasFinalizadas)
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NewAppointmentScreen()));
          },
          backgroundColor: Theme.of(context).primaryColor,
          shape: CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _listaCitas(BuildContext context, List<Cita> citas) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(32),
      child: Column(
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
        ],
      ),
    );
  }

  Future<Widget> _buildCita(Cita cita) async {
    final Pago pago = await CitaProvider.instance.getPago(cita.id);

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AppointmentDetailsScreen(
                    cita: cita,
                    pago: pago,
                  ))),
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
                        Text(cita.nomMedico,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xff0c4454))),
                        SizedBox(height: 10),
                        Text(cita.nomSede, style: TextStyle(fontSize: 11)),
                        SizedBox(height: 20),
                        Text(cita.motivo, style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  if (cita.estado == "PENDIENTE")
                    PopupMenuButton<String>(
                      padding: EdgeInsets.all(6),
                      color: Colors.white,
                      iconColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      onSelected: (value) async {
                        if (value == 'Modificar_${cita.id}') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditAppointmentScreen(
                                      citaSeleccionada: cita)));
                          await _loadCitas();
                        } else if (value == 'Eliminar_${cita.id}') {
                          _showDeleteDialog(cita);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          value: 'Modificar_${cita.id}',
                          child: Text(
                            'Modificar cita',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Eliminar_${cita.id}',
                          child: Text(
                            'Eliminar cita',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              if (cita.estado != "FINALIZADO" &&
                  cita.estado != "EN PROCESO" &&
                  cita.estado != "ELIMINADO POR EL USUARIO")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        NotificationsController
                                .instance.isNotificationPermsGranted
                            ? "Alerta activada"
                            : "Alerta desactivada",
                        style: TextStyle(fontSize: 11)),
                    Text(dateFormatter.formatStringDate(cita.fecha),
                        style: TextStyle(fontSize: 11)),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(dateFormatter.formatStringDate(cita.fecha),
                        style: TextStyle(fontSize: 11)),
                  ],
                ),
              if (cita.estado == "FINALIZADO")
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 6),
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                ResultadoCitaScreen(citaSeleccionada: cita))),
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
