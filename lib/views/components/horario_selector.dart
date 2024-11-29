import 'package:consultorio_medico/models/providers/cita_provider.dart';
import 'package:consultorio_medico/models/providers/medico_provider.dart';
import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';

class HorarioSelector {
  final DateTime fechaSeleccionada;
  final String idMedico;
  final String idSede;
  final String idPaciente;
  final Future<List<TimeOfDay?>> Function(
      String idSede, List<DateTime> horarioDoctor) obtenerHorariosOcupados;

  HorarioSelector({
    required this.fechaSeleccionada,
    required this.idMedico,
    required this.idSede,
    required this.idPaciente,
    required this.obtenerHorariosOcupados,
  });

  Future<void> mostrar(
      BuildContext context, Function(TimeOfDay) onSeleccionado) async {
    final isAlreadyBooked = await CitaProvider.instance
        .verificarCitaAgendada(idPaciente, fechaSeleccionada);
    final horarioDoctor = await MedicoProvider.instance
        .getHorarioActual(idMedico, fechaSeleccionada);
    final horariosOcupados =
        await obtenerHorariosOcupados(idSede, horarioDoctor!);
    final horariosDisponibles =
        await _generarHorariosDisponibles(horarioDoctor, horariosOcupados);

    const textStyle = TextStyle(fontSize: 40.0, height: 1.5);
    final wheelStyle = WheelPickerStyle(
      itemExtent: textStyle.fontSize! * textStyle.height!,
      // Text height
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
      builder: (context) {
        late String selected = horariosDisponibles[0];
        return Padding(
          padding: EdgeInsets.all(20),
          child: horariosDisponibles.isEmpty
              ? Text(
                  'No hay horarios disponibles. Por favor, elija otra fecha o médico')
              : isAlreadyBooked
                  ? Text(
                      'Ya se ha agendado una cita con el paciente en la fecha seleccionada')
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Horarios disponibles',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                                    color:
                                        const Color(0xFFC3C9FA).withAlpha(26),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: WheelPicker(
                                  itemCount: horariosDisponibles.length,
                                  builder: (context, index) {
                                    final horario = horariosDisponibles[index];
                                    return Text(
                                      horario,
                                      style: const TextStyle(fontSize: 16),
                                    );
                                  },
                                  style: wheelStyle,
                                  selectedIndexColor:
                                      Theme.of(context).primaryColor,
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: const Color(0xFF5494a3),
                                ),
                                onPressed: () {
                                  onSeleccionado(_stringToTime(selected));
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
  }

  Future<List<String>> _generarHorariosDisponibles(
      List<DateTime> horarioDoctor, List<TimeOfDay?> horariosOcupados) async {
    DateTime horaActual = DateTime(
        fechaSeleccionada.year,
        fechaSeleccionada.month,
        fechaSeleccionada.day,
        DateTime.now().hour,
        DateTime.now().minute);

    DateTime horaInicio = horarioDoctor.first;
    DateTime horaFin = horarioDoctor.last;

    List<DateTime> horariosCompletos = [];
    List<String> horariosDisponibles = [];

    if (_esElMismoDia(horaActual, DateTime.now())) {
      if (horaActual.hour >= horaFin.hour &&
          horaActual.minute >= horaFin.minute) {
        return [];
      }

      _generarHorariosDesde(horaActual, horaInicio, horaFin, horariosCompletos);
      horariosCompletos.removeWhere(
          (horario) => horario.difference(horaActual).inMinutes < 60);
    } else {
      horaActual = DateTime(horaActual.year, horaActual.month, horaActual.day,
          horaInicio.hour - 1, 0);
      _generarHorariosDesde(horaActual, horaInicio, horaFin, horariosCompletos);
    }
    horariosCompletos.forEach((horario) {
      horariosDisponibles
          .add('${horario.hour}:${horario.minute.toString().padLeft(2, '0')}');
    });
    horariosDisponibles.removeWhere(
        (horario) => _timeListToString(horariosOcupados).contains(horario));

    return horariosDisponibles;
  }
}

List<String> _timeListToString(List<TimeOfDay?> timeList) {
  List<String> stringList = [];
  for (var time in timeList) {
    if (time != null) {
      stringList.add(_timeToString(time));
    }
  }
  return stringList;
}

String _timeToString(TimeOfDay time) {
  return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}

TimeOfDay _stringToTime(String time) {
  return TimeOfDay(
      hour: int.parse(time.split(":")[0]),
      minute: int.parse(time.split(":")[1]));
}

bool _esElMismoDia(DateTime one, DateTime other) {
  return one.year == other.year &&
      one.month == other.month &&
      one.day == other.day;
}

void _generarHorariosDesde(DateTime horaActual, DateTime horaInicio,
    DateTime horaFin, List<DateTime> horariosDisponibles) {
  DateTime hora = horaInicio;

  while (hora.difference(horaFin) < Duration(minutes: 20)) {
    horariosDisponibles.add(DateTime(horaActual.year, horaActual.month,
        horaActual.day, hora.hour, hora.minute));
    hora = hora.add(Duration(minutes: 20));
  }
}
