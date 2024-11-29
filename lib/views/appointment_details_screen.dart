import 'package:consultorio_medico/controllers/notifications_controller.dart';
import 'package:consultorio_medico/models/cita.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/views/components/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pago.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Cita cita;
  final Pago? pago;

  const AppointmentDetailsScreen({super.key, required this.cita, this.pago});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detalles de cita"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildInfoRow("ID de Cita: ", cita.id, size: 18),
                SizedBox(
                  height: 42,
                ),
                buildInfoRow("Fecha y hora de la cita: ",
                    DateFormat('dd-MM-yyyy HH:mm').format(cita.fecha)),
                SizedBox(
                  height: 15,
                ),
                buildInfoRow("DNI del paciente: ", cita.dniPaciente),
                SizedBox(
                  height: 15,
                ),
                buildInfoRow("Sede: ", cita.nomSede),
                SizedBox(
                  height: 15,
                ),
                buildInfoRow("Médico: ", cita.nomMedico),
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
                              color: cita.estado == "PENDIENTE" || cita.estado == "EN PROCESO"
                                  ? Colors.yellow
                                  : cita.estado == "FINALIZADO"
                                      ? Colors.greenAccent
                                      : Colors.red))),
                      child: Text(
                        cita.estado,
                        style: TextStyle(
                            color: cita.estado == "PENDIENTE" || cita.estado == "EN PROCESO"
                                ? Colors.yellow
                                : cita.estado == "FINALIZADO"
                                    ? Colors.greenAccent
                                    : Colors.red),
                      ),
                    )),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Información de pago:",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (pago != null) ...[
                  SizedBox(
                    height: 15,
                  ),
                  buildInfoRow("PagoId:", pago!.id),
                  SizedBox(
                    height: 15,
                  ),
                  buildInfoRow("Fecha:",
                      DateFormat('dd/MM/yyyy HH:mm').format(pago!.fecha)),
                  SizedBox(
                    height: 15,
                  ),
                  buildInfoRow("Monto recibido:", '${pago!.monto}'),
                  SizedBox(
                    height: 15,
                  ),
                  buildInfoRow("Motivo:", pago!.motivo)
                ] else ...[
                  Text("Se efectuó la devolución del pago.")
                ]
              ],
            ),
          ),
        ));
  }
}
