import 'package:flutter/material.dart';

class SelectorMotivoCita extends StatefulWidget {
  final Function(String) onSeleccionado;

  const SelectorMotivoCita({required this.onSeleccionado, Key? key})
      : super(key: key);

  @override
  _SelectorMotivoCitaState createState() => _SelectorMotivoCitaState();
}

class _SelectorMotivoCitaState extends State<SelectorMotivoCita> {
  final List<String> motivos = [
    "Consulta general",
    "Revisión médica",
    "Dolor o molestia específica",
    "Aplicación de inyectables",
    "Problemas emocionales/psicológicos",
    "Otro motivo"
  ];

  String? motivoSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seleccionar Motivo")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Selecciona el motivo de tu cita",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: motivos.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(motivos[index]),
                              onTap: () {
                                setState(() {
                                  motivoSeleccionado = motivos[index];
                                });
                                if (motivos[index] != "Otro motivo") {
                                  widget.onSeleccionado(motivos[index]);
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Text("Seleccionar Motivo"),
        ),
      ),
    );
  }
}
