import 'package:flutter/material.dart';
import '../models/cita.dart';

class ResultadoCitaScreen extends StatelessWidget {
  final Cita citaSeleccionada;
  const ResultadoCitaScreen({super.key, required this.citaSeleccionada});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resultado de cita ${citaSeleccionada.id}"),
      ),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "Observaciones del médico",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(
            height: 26,
          ),
          Text("El médico no ha añadido observaciones"),
        ]),
      ),
    );
  }
}
