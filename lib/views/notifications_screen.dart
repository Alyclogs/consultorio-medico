import 'package:consultorio_medico/controllers/notifications_controller.dart';
import 'package:consultorio_medico/models/notificacion.dart';
import 'package:consultorio_medico/models/providers/notificacion_provider.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/views/components/loading_screen.dart';
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
      // Simula la carga de notificaciones
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
                  padding: const EdgeInsets.all(32.0),
                  child: ListView.builder(
                    itemCount: _notificaciones.length,
                    itemBuilder: (context, index) {
                      Notificacion noti = _notificaciones[index];
                      return GestureDetector(
                        onTap: () async {
                          final exist = await NotificationProvider.instance
                              .navigateToAppointmentScreen(noti.citaId);
                          if (!exist) {
                            showMessenger(context, 'No se ha encontrado información sobre la cita');
                          }
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 3,
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(noti.title, style: TextStyle(fontSize: 16),),
                              subtitle: Text('${noti.body}\n\n${DateFormat('dd/MM/yyyy hh:mm a').format(noti.timestamp)}'),
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
