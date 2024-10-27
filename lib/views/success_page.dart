import 'package:consultorio_medico/models/pago.dart';
import 'package:consultorio_medico/views/components/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
            Expanded(
                child: Column(
              children: [
                Image.asset('assets/images/success.webm'),
                SizedBox(
                  height: 20,
                ),
                Text("Tu cita fue agendada correctamente"),
                SizedBox(
                  height: 40,
                ),
                Text("Detalle de pago:"),
                SizedBox(
                  height: 10,
                ),
                Card(
                  child: Container(
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
                        _buildInfoRow("PagoId:", pago.id),
                        _buildInfoRow("Fecha:",
                            DateFormat('dd/MM/yyyy HH:mm').format(pago.fecha)),
                        _buildInfoRow("Monto recibido:", '${pago.monto}'),
                        _buildInfoRow("Motivo:", pago.motivo)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Expanded(
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
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xff0c4454),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
