import 'package:consultorio_medico/models/cita.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/views/components/info_row.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Cita cita;
  final String nombreMedico;
  final String nombreSede;
  const AppointmentDetailsScreen(
      {super.key,
      required this.cita,
      required this.nombreMedico,
      required this.nombreSede});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles de cita"),
      ),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildInfoRow("ID de Cita: ", cita.id, size: 18),
            SizedBox(
              height: 42,
            ),
            buildInfoRow(
                "Fecha: ", DateFormat('dd-MM-yyyy').format(cita.fecha)),
            SizedBox(
              height: 15,
            ),
            buildInfoRow("DNI del paciente: ", cita.dniPaciente),
            SizedBox(
              height: 15,
            ),
            buildInfoRow("Sede: ", nombreSede),
            SizedBox(
              height: 15,
            ),
            buildInfoRow("Médico: ", nombreMedico),
            SizedBox(
              height: 15,
            ),
            buildInfoRow("Motivo: ", cita.motivo),
            SizedBox(
              height: 15,
            ),
            buildInfoRow("Estado: ", cita.estado,
                otherComponent: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.fromBorderSide(BorderSide(
                          color: cita.estado == "PENDIENTE"
                              ? Colors.yellow
                              : cita.estado == "FINALIZADO"
                                  ? Colors.greenAccent
                                  : Colors.red))),
                  child: Text(
                    cita.estado,
                    style: TextStyle(
                        color: cita.estado == "PENDIENTE"
                            ? Colors.yellow
                            : cita.estado == "FINALIZADO"
                                ? Colors.greenAccent
                                : Colors.red),
                  ),
                )),
            SizedBox(
              height: 15,
            ),
            buildInfoRow("Activar notificación", "",
                otherComponent: Switch(
                  value:
                      UsuarioProvider.instance.usuarioActual.sendNotifications,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (bool value) {},
                )),
            SizedBox(
              height: 10,
            ),
            Text(
                "Para ${UsuarioProvider.instance.usuarioActual.sendNotifications ? "desactivar" : "activar"} las notificaciones, ve a la pestaña perfil > ${UsuarioProvider.instance.usuarioActual.sendNotifications ? "desactivar" : "activar"} notificaciones"),
          ],
        ),
      ),
    );
  }
}
