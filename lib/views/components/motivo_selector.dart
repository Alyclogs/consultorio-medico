import 'package:flutter/material.dart';

class SelectorMotivoCita {

  void mostrar(BuildContext context, Function(String) onSeleccionado) {
    final List<String> motivos = [
      "Consulta general",
      "Revisión médica",
      "Dolor o molestia específica",
      "Aplicación de inyectables",
      "Problemas emocionales/psicológicos",
      "Otro motivo"
    ];

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
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.fromBorderSide(BorderSide(color: Colors.grey))
                      ),
                      child: ListTile(
                      title: Text(motivos[index], style: Theme.of(context).textTheme.bodyMedium,),
                      onTap: () {
                        if (motivos[index] != "Otro motivo") {
                          onSeleccionado(motivos[index]);
                        }
                        Navigator.pop(context);
                      },
                    ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
