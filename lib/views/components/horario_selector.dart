import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';

class HorarioSelector {
  final DateTime fechaSeleccionada;
  final Future<List<TimeOfDay>> Function(DateTime fecha)
      obtenerHorariosOcupados;

  HorarioSelector({
    required this.fechaSeleccionada,
    required this.obtenerHorariosOcupados,
  });

  Future<void> mostrar(
      BuildContext context, Function(TimeOfDay) onSeleccionado) async {
    late List<TimeOfDay> horariosDisponibles = [];
    const textStyle = TextStyle(fontSize: 40.0, height: 1.5);
    final wheelStyle = WheelPickerStyle(
      itemExtent: textStyle.fontSize! * textStyle.height!, // Text height
      squeeze: 1.25,
      diameterRatio: .8,
      surroundingOpacity: .25,
      magnification: 1.2,
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FutureBuilder<List<TimeOfDay>>(
          future: obtenerHorariosOcupados(fechaSeleccionada),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final horariosDisponibles =
                _generarHorariosDisponibles(snapshot.data!);
            late TimeOfDay selected;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Horarios disponibles',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200.0,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Align(
                          alignment: Alignment(0, -0.3),
                          child: Container(
                            height: 42.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC3C9FA).withAlpha(26),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: WheelPicker(
                            itemCount: horariosDisponibles.length,
                            builder: (context, index) {
                              final horario = horariosDisponibles[index];
                              return Text(
                                horario.format(context),
                                style: const TextStyle(fontSize: 16),
                              );
                            },
                            style: wheelStyle,
                            selectedIndexColor: Theme.of(context).primaryColor,
                            looping: false,
                            onIndexChanged: (index) {
                              selected = horariosDisponibles[index];
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF5494a3),
                          ),
                          onPressed: () {
                            onSeleccionado(selected);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Seleccionar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<TimeOfDay> _generarHorariosDisponibles(
      List<TimeOfDay> horariosOcupados) {
    const inicio = TimeOfDay(hour: 18, minute: 0);
    const fin = TimeOfDay(hour: 21, minute: 0);

    List<TimeOfDay> horarios = [];
    TimeOfDay actual = inicio;

    while (_compararHoras(actual, fin) <= 0) {
      if (!horariosOcupados
          .any((ocupado) => _compararHoras(actual, ocupado) == 0)) {
        horarios.add(actual);
      }
      actual = _sumarMinutos(actual, 15);
    }

    return horarios;
  }

  int _compararHoras(TimeOfDay a, TimeOfDay b) {
    return a.hour == b.hour ? a.minute - b.minute : a.hour - b.hour;
  }

  TimeOfDay _sumarMinutos(TimeOfDay hora, int minutos) {
    int totalMinutes = hora.hour * 60 + hora.minute + minutos;
    int newHour = totalMinutes ~/ 60;
    int newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }
}
