import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consultorio_medico/controllers/auth_controller.dart';
import 'package:consultorio_medico/models/cita.dart';
import 'package:consultorio_medico/models/providers/cita_provider.dart';
import 'package:consultorio_medico/models/providers/medico_provider.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/views/components/seleccion_modal.dart';
import 'package:consultorio_medico/views/components/loading_screen.dart';
import 'package:consultorio_medico/views/pago_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medico.dart';
import '../models/providers/sede_provider.dart';
import '../models/sede.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  NewAppointmentScreenState createState() => NewAppointmentScreenState();
}

class NewAppointmentScreenState extends State<NewAppointmentScreen> {
  int _currentStep = 0;
  bool isLoading = true;

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  final currentUser = UsuarioProvider.instance.usuarioActual;
  final _dniPaciente = TextEditingController();
  final _nombre = TextEditingController();
  final _edad = TextEditingController();
  final _genero = TextEditingController();
  bool _autofill = false;
  final _sede = TextEditingController();
  final _medico = TextEditingController();
  String _motivo = "";
  final _fechaSeleccionada = TextEditingController();
  final _horaSeleccionada = TextEditingController();
  bool _esMasculino = false;

  void _goToNextStep() {
    setState(() {
      _currentStep += 1;
    });
  }

  void _goToPreviousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep -= 1;
      }
    });
  }

  void _fillUserData() {
    if (_autofill) {
      setState(() {
        _nombre.text = currentUser.nombre;
        _dniPaciente.text = currentUser.id;
        _edad.text = '${currentUser.edad}';
        _esMasculino = currentUser.genero == "Masculino" ? true : false;
      });
    } else {
      setState(() {
        _nombre.text = "";
        _dniPaciente.text = "";
        _edad.text = "";
      });
    }
  }

  Future<void> _validateStep1() async {
    int estado = 401;
    loadingScreen(context);
    estado = await AuthController.validarDNI(
      _dniPaciente.text,
      _nombre.text
    );
    Navigator.pop(context);

    if (estado == 200) {
      _goToNextStep();
    } else if (estado == 404) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('DNI no encontrado')));
    } else if (estado == 400) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Los datos ingresados no coinciden con el DNI')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al validar el DNI')));
    }
  }

  Future<void> _validateStep2() async {
    if (_sede.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una sede.')),
      );
      return;
    }

    if (_medico.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona un médico.')),
      );
      return;
    }
    _goToNextStep();
  }

  Future<void> _validateStep3() async {
    if (_fechaSeleccionada.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una fecha.')),
      );
      return;
    }

    if (_horaSeleccionada.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una hora.')),
      );
      return;
    }
    _agendarCita();
  }

  Future<void> _agendarCita() async {
    final medico = await MedicoProvider.instance.getRegistroFromNombre(_medico.text);
    final sede = await SedeProvider.instance.getRegistroFromNombre(_sede.text);

    if (medico == null || sede == null) {
      return;
    } else {
      CitaProvider bd = CitaProvider.instance;
      final DateTime fechaHora = DateFormat('dd-MM-yyyy HH:mm')
          .parse('${_fechaSeleccionada.text} ${_horaSeleccionada.text}');
      final appointment = Cita(
          id: await bd.generarNuevoId(fechaHora),
          fecha: fechaHora,
          nomPaciente: _nombre.text,
          dniPaciente: _dniPaciente.text,
          idMedico: medico.id,
          idSede: sede.id,
          edadPaciente: int.parse(_edad.text),
          motivo: _motivo,
          costo: 50.0,
          estado: "PENDIENTE");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentWebView(appointment: appointment)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Cita'),
      ),
      body: SingleChildScrollView(
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () async {
            if (_currentStep == 0) {
              if (_formKeyStep1.currentState!.validate()) {
                _formKeyStep1.currentState!.save();
                _validateStep1();
              }
            } else if (_currentStep == 1) {
              if (_formKeyStep2.currentState!.validate()) {
                _formKeyStep2.currentState!.save();
                _validateStep2();
              }
            } else if (_currentStep == 2) {
              if (_formKeyStep3.currentState!.validate()) {
                _formKeyStep3.currentState!.save();
                _validateStep3();
              }
            }
          },
          onStepCancel: _goToPreviousStep,
          controlsBuilder: (context, details) => Padding(
            padding: EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Color(0xFF5494a3),
                    ),
                    onPressed: details.onStepContinue,
                    child: Text(
                      _currentStep < 2 ? "Siguiente" : "Agendar y pagar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                if (_currentStep != 0) ...[
                  Expanded(
                    child: TextButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: details.onStepCancel,
                      child: Text(
                        "Atrás",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
          steps: [
            Step(
              title: Text('Datos del paciente'),
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  Text(
                    "Ingrese los datos del paciente a ser atendido",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 36),
                  CheckboxListTile(
                      title: Text(
                        "Llenar con mis datos",
                        style: TextStyle(fontSize: 16),
                      ),
                      value: _autofill,
                      onChanged: (newValue) {
                        setState(() {
                          _autofill = !_autofill;
                        });
                        _fillUserData();
                      }),
                  Form(
                    key: _formKeyStep1,
                    child: Column(
                      children: <Widget>[
                        _buildInputField(context, "DNI del paciente",
                            controller: _dniPaciente,
                            maxLength: 8,
                            onSaved: (value) => _dniPaciente.text = value!,
                            keyboardType: TextInputType.number,
                            enabled: !_autofill),
                        SizedBox(
                          height: 10,
                        ),
                        _buildInputField(context, "Nombre del paciente",
                            controller: _nombre,
                            onSaved: (value) => _nombre.text = value!,
                            caps: TextCapitalization.sentences,
                            keyboardType: TextInputType.name,
                            enabled: !_autofill),
                        SizedBox(
                          height: 10,
                        ),
                        _buildInputField(context, "Edad del paciente",
                            controller: _edad,
                            onSaved: (value) => _edad.text = value!,
                            keyboardType: TextInputType.number,
                            enabled: !_autofill),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Género del paciente: ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _esMasculino,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _esMasculino = !_esMasculino;
                                    });
                                  },
                                ),
                                Text('Masculino'),
                              ],
                            ),
                            SizedBox(width: 20),
                            Row(
                              children: [
                                Checkbox(
                                  value: !_esMasculino,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _esMasculino = !_esMasculino;
                                    });
                                  },
                                ),
                                Text('Femenino'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              isActive: _currentStep == 0,
            ),
            Step(
              title: Text('Datos de consulta'),
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  Text(
                    "Ingrese los datos de la consulta",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKeyStep2,
                    child: Column(
                      children: <Widget>[
                        _buildInputField(context, "Selecciona Sede",
                            controller: _sede,
                            validator: false,
                            enabled: false, onTap: () {
                          final modal = SeleccionModal<Sede>(
                              getRegistros: SedeProvider.instance.getRegistros,
                              titulo: "Selecciona una sede");
                          modal.mostrar(context, (seleccionado) {
                            setState(() {
                              _sede.text = seleccionado;
                            });
                          });
                        }),
                        SizedBox(
                          height: 10,
                        ),
                        _buildInputField(context, 'Selecciona Médico',
                            controller: _medico,
                            validator: false,
                            enabled: false, onTap: () {
                          final modal = SeleccionModal<Medico>(
                              getRegistros:
                                  MedicoProvider.instance.getRegistros,
                              titulo: "Selecciona un médico");
                          modal.mostrar(context, (seleccionado) {
                            setState(() {
                              _medico.text = seleccionado;
                            });
                          });
                        }),
                        SizedBox(
                          height: 10,
                        ),
                        _buildInputField(context, "Motivo de la consulta",
                            onSaved: (value) => _motivo = value!,
                            multiline: true),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              isActive: _currentStep == 1,
            ),
            Step(
              title: Text('Datos de consulta'),
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  Text(
                    "Ingrese el horario en el que será atendido",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKeyStep3,
                    child: Column(
                      children: <Widget>[
                        _buildInputField(context, 'Seleccione fecha',
                            controller: _fechaSeleccionada,
                            validator: false, onTap: () async {
                          loadingScreen(context);
                          await selectDate(context);
                        }, enabled: false),
                        SizedBox(
                          height: 10,
                        ),
                        _buildInputField(context, 'Seleccione hora',
                            controller: _horaSeleccionada,
                            validator: false, onTap: () async {
                          loadingScreen(context);
                          await selectTime(context);
                        }, enabled: false),
                        SizedBox(
                          height: 42,
                        ),
                        Text(
                          'Costo de la consulta: S/50.0',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 16),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              isActive: _currentStep == 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context,
    String text, {
    TextEditingController? controller,
    int? maxLength,
    GestureTapCallback? onTap,
    FormFieldSetter<String>? onSaved,
    bool validator = true,
    TextInputType? keyboardType,
    TextCapitalization? caps,
    bool multiline = false,
    bool enabled = true,
  }) {
    return TextFormField(
        decoration: InputDecoration(
          hintText: text,
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        controller: controller,
        style: Theme.of(context).textTheme.bodyMedium,
        textCapitalization: caps ?? TextCapitalization.none,
        maxLength: maxLength,
        maxLines: multiline ? null : 1,
        keyboardType: keyboardType ??
            (multiline ? TextInputType.multiline : TextInputType.none),
        onTap: onTap,
        readOnly: !enabled,
        validator: validator
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor completa este campo';
                }
                return null;
              }
            : null,
        onSaved: onSaved);
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime twoWeeksLater = now.add(Duration(days: 14));
    Set<DateTime> fullyBookedDays = await getFullyBookedDays();

    await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: twoWeeksLater,
        selectableDayPredicate: (DateTime day) {
          return !fullyBookedDays
              .contains(DateTime(day.year, day.month, day.day));
        }).then((selectedDate) {
      Navigator.pop(context);
      if (selectedDate != null) {
        setState(() {
          _fechaSeleccionada.text =
              DateFormat('dd-MM-yyyy').format(selectedDate.toLocal());
        });
      }
    });
  }

  Future<void> selectTime(BuildContext context) async {
    TimeOfDay? selectedTime;

    selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 18, minute: 0),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        });
    Navigator.pop(context);

    if (selectedTime != null &&
        selectedTime.hour >= 18 &&
        selectedTime.hour <= 21) {
      final String? formattedTime = selectedTime.format(context);
      setState(() {
        _horaSeleccionada.text = formattedTime!;
      });
    }
  }

  Future<bool> isDayFullyBooked(DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day, 18, 0);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 21, 0);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('citas')
        .where('fecha', isGreaterThanOrEqualTo: startOfDay)
        .where('fecha', isLessThanOrEqualTo: endOfDay)
        .get();

    const int marginInMinutes = 30;
    List<DateTime> bloquesHorarios = [
      startOfDay,
      startOfDay.add(Duration(minutes: 30)),
      startOfDay.add(Duration(minutes: 60)),
      startOfDay.add(Duration(minutes: 90)),
      startOfDay.add(Duration(minutes: 120)),
      startOfDay.add(Duration(minutes: 150)),
    ];

    for (DateTime bloque in bloquesHorarios) {
      bool isAvailable = true;

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        DateTime citaHora =
            (doc.data() as Map<String, dynamic>)['fecha'].toDate();
        DateTime citaStart = citaHora;
        DateTime citaEnd = citaStart.add(Duration(minutes: marginInMinutes));

        if (bloque.isBefore(citaEnd) &&
            bloque.isAfter(
                citaStart.subtract(Duration(minutes: marginInMinutes)))) {
          isAvailable = false;
          break;
        }
      }
      if (isAvailable) return false;
    }
    return true;
  }

  Future<Set<DateTime>> getFullyBookedDays() async {
    Set<DateTime> fullyBookedDays = {};

    DateTime now = DateTime.now();
    DateTime twoWeeksLater = now.add(Duration(days: 14));

    for (int i = 0; i <= twoWeeksLater.difference(now).inDays; i++) {
      DateTime dayToCheck = now.add(Duration(days: i));

      bool isFullyBooked = await isDayFullyBooked(dayToCheck);

      if (isFullyBooked) {
        fullyBookedDays
            .add(DateTime(dayToCheck.year, dayToCheck.month, dayToCheck.day));
      }
    }
    return fullyBookedDays;
  }
}
