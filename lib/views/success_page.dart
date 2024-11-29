import 'package:consultorio_medico/models/pago.dart';
import 'package:consultorio_medico/views/components/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/utils.dart';

class SuccessPage extends StatelessWidget {
  final Pago pago;
  const SuccessPage({super.key, required this.pago});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
              size: 72,
            ),
            SizedBox(
              height: 20,
            ),
            Text("Tu cita fue agendada correctamente"),
            SizedBox(
              height: 15,
            ),
            Text(pago.idCita, style: TextStyle(fontSize: 42, color: Theme.of(context).primaryColor),),
            SizedBox(
              height: 40,
            ),
            Text("Detalle de pago:"),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Detalles de pago:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  buildInfoRow("PagoId:", pago.id),
                  buildInfoRow("Fecha:",
                      DateFormat('dd/MM/yyyy HH:mm').format(pago.fecha)),
                  buildInfoRow("Monto recibido:", '${pago.monto}'),
                  buildInfoRow("Motivo:", pago.motivo)
                ],
              ),
            ),
            SizedBox(
              height: 56,
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BottomNavBar()));
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor: Color(0xFF5494a3)),
                  child: Text("Regresar al inicio")),
            ),
            SizedBox(
              height: 15,
            ),
            /*
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: () async {
                    if (await canLaunchUrl(pdfUrl)) {
                      await launchUrl(pdfUrl);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent),
                  icon: Icon(Icons.picture_as_pdf, color: Theme.of(context).primaryColor,),
                  label: Text("Descargar pdf")),
            ),
             */
          ],
        ),
      ),
    );
  }
}
