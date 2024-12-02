import 'package:consultorio_medico/models/notificacion.dart';
import 'package:consultorio_medico/models/providers/notificacion_provider.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/views/components/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationsScreen> {
  final NotificationProvider bd = NotificationProvider.instance;
  late List<Notificacion> _notificaciones = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() async {
    try {
      List<Notificacion> notifications =
          await bd.getNotifications(UsuarioProvider.instance.usuarioActual.id);

      setState(() {
        _notificaciones = notifications;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al cargar las notificaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _notificaciones.isEmpty
              ? Center(child: Text('No tienes notificaciones'))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: ListView.builder(
                    itemCount: _notificaciones.length,
                    itemBuilder: (context, index) {
                      Notificacion noti = _notificaciones[index];
                      return GestureDetector(
                        onTap: () async {
                          if (noti.seen = false) {
                            setState(() {
                              noti.seen = true;
                            });
                            await NotificationProvider.instance
                                .updateNotification(noti);
                          }
                          final exist = await NotificationProvider.instance
                              .navigateToAppointmentScreen(noti.citaId);
                          if (!exist) {
                            showMessenger(context,
                                'No se ha encontrado información sobre la cita');
                          }
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 3,
                          color: noti.seen ? Colors.white : Color(0xffe0ecec),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    noti.title,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey[700]),
                                    textAlign: TextAlign.start,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                children: [
                                  Text(
                                    noti.body,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.start,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy hh:mm a')
                                            .format(noti.timestamp!),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
