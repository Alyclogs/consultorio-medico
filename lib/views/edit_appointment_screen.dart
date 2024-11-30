import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:consultorio_medico/controllers/auth_controller.dart';
import 'package:consultorio_medico/models/cita.dart';
import 'package:consultorio_medico/models/providers/cita_provider.dart';
import 'package:consultorio_medico/models/providers/medico_provider.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/views/components/bottom_navbar.dart';
import 'package:consultorio_medico/views/components/seleccion_modal.dart';
import 'package:consultorio_medico/views/components/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/notifications_controller.dart';
import '../models/medico.dart';
import '../models/notificacion.dart';
import '../models/providers/sede_provider.dart';
import '../models/sede.dart';
import 'components/horario_selector.dart';
import 'components/motivo_selector.dart';

class EditAppointmentScreen extends StatefulWidget {
  final Cita citaSeleccionada;
  const EditAppointmentScreen({super.key, required this.citaSeleccionada});

  @override
  EditAppointmentScreenState createState() => EditAppointmentScreenState();
}

class EditAppointmentScreenState extends State<EditAppointmentScreen> {
  int _currentStep = 0;
  bool isLoading = true;

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fillData();
  }

  void _fillData() async {
    await _fillCitaData();
  }

  final currentUser = UsuarioProvider.instance.usuarioActual;
  final bd = CitaProvider.instance;
  final _dniPaciente = TextEditingController();
  final _nombre = TextEditingController();
  final _edad = TextEditingController();
  final _genero = TextEditingController();
  bool _autofill = false;
  final _sede = TextEditingController();
  final _medico = TextEditingController();
  final _motivo = TextEditingController();
  final _fechaSeleccionada = TextEditingController();
  final _horaSeleccionada = TextEditingController();
  bool _esMasculino = false;
  late DateTime _selectedDate;
  Medico? _medicoSeleccionado;
  Sede? _sedeSeleccionada;

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

  Future<void> _fillCitaData() async {
    final user = await UsuarioProvider.instance
        .getRegistro(widget.citaSeleccionada.dniPaciente);
    final medico = await MedicoProvider.instance
        .getRegistro(widget.citaSeleccionada.idMedico);
    final sede =
        await SedeProvider.instance.getRegistro(widget.citaSeleccionada.idSede);
    if (user == null || medico == null || sede == null) {
      return;
    }
    setState(() {
      _nombre.text = user.nombre;
      _dniPaciente.text = user.id;
      _edad.text = '${AuthController.calcularEdad(user.fecha_nac)}';
      _esMasculino = user.genero == "Masculino" ? true : false;
      _sede.text = sede.nombre;
      _medico.text = medico.nombre;
      _motivo.text = widget.citaSeleccionada.motivo;
      _fechaSeleccionada.text =
          DateFormat('dd-MM-yyyy').format(widget.citaSeleccionada.fecha);
      _horaSeleccionada.text =
          DateFormat('HH:mm').format(widget.citaSeleccionada.fecha);
    });
  }

  void _fillUserData() {
    if (_autofill) {
      setState(() {
        _nombre.text = currentUser.nombre;
        _dniPaciente.text = currentUser.id;
        _edad.text = '${AuthController.calcularEdad(currentUser.fecha_nac)}';
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
    if (_autofill) {
      _goToNextStep();
    } else {
      int estado = 401;
      loadingScreen(context);
      estado = await AuthController.validarDNI(
          _dniPaciente.text, _nombre.text, _esMasculino ? 'M' : 'F');
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
    _editarCita();
  }

  Future<void> _editarCita() async {
    if (_medicoSeleccionado == null || _sedeSeleccionada == null) {
      return;
    } else {
      CitaProvider bd = CitaProvider.instance;
      final DateTime fechaHora = DateFormat('dd-MM-yyyy HH:mm')
          .parse('${_fechaSeleccionada.text} ${_horaSeleccionada.text}');
      final appointment = Cita(
          id: widget.citaSeleccionada.id,
          fecha: fechaHora,
          dniUsuario: UsuarioProvider.instance.usuarioActual.id,
          nomPaciente: _nombre.text,
          dniPaciente: _dniPaciente.text,
          idMedico: _medicoSeleccionado!.id,
          nomMedico: _medicoSeleccionado!.nombre,
          idSede: _sedeSeleccionada!.id,
          nomSede: _sedeSeleccionada!.nombre,
          edadPaciente: int.parse(_edad.text),
          motivo: _motivo.text.isNotEmpty ? _motivo.text : "Consulta general",
          costo: _medicoSeleccionado!.costoCita,
          estado: "PENDIENTE");

      await bd.updateRegistro(appointment);
      final scheduledTime = fechaHora.subtract(Duration(hours: 1));
      final notification = Notificacion(
          appointment.id.hashCode,
          appointment.id,
          appointment.fecha,
          appointment.dniUsuario,
          '⏰ Cita en 1 hora',
          'Tienes una cita con ${appointment.nomMedico} a las ${DateFormat('hh:mm a').format(fechaHora)}.',
          false);

      if (appointment.fecha.difference(DateTime.now()) >
          Duration(minutes: 60)) {
        notification.timestamp = scheduledTime;
        await NotificationsController.instance
            .updateNotificationScheduled(notification: notification);
      } else {
        notification.timestamp = DateTime.now();
        await NotificationsController.instance.updateNotification(notification);
      }

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BottomNavBar(
                    initialIndex: 1,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Cita'),
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
                      _currentStep < 2 ? "Siguiente" : "Actualizar cita",
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
                            enabled: false, onTap: () async {
                          final modal = SeleccionModal<Sede>(
                              getRegistros:
                                  SedeProvider.instance.getRegistros(),
                              titulo: "Selecciona una sede");
                          modal.mostrar(context, (seleccionado) {
                            setState(() {
                              _sede.text = seleccionado.nombre;
                              _sedeSeleccionada = seleccionado as Sede;
                            });
                          });
                        }),
                        SizedBox(
                          height: 10,
                        ),
                        _buildInputField(context, 'Selecciona Médico',
                            controller: _medico,
                            validator: false,
                            enabled: false, onTap: () async {
                          final modal = SeleccionModal<Medico>(
                              getRegistros: MedicoProvider.instance
                                  .getRegistrosPorSede(_sedeSeleccionada!.id),
                              titulo: "Selecciona un médico");
                          modal.mostrar(context, (seleccionado) {
                            setState(() {
                              _medico.text = seleccionado.nombre;
                              _medicoSeleccionado = seleccionado as Medico;
                            });
                          });
                        }),
                        SizedBox(
                          height: 10,
                        ),
                        _buildInputField(
                          context,
                          "Motivo de la consulta",
                          controller: _motivo,
                          onSaved: (value) => _motivo.text = value!,
                          multiline: true,
                          caps: TextCapitalization.sentences,
                          validator: false,
                          onTap: () {
                            SelectorMotivoCita().mostrar(
                              context,
                              (motivo) {
                                setState(() {
                                  _motivo.text = motivo;
                                });
                              },
                            );
                          },
                        ),
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
                          _selectTime(context);
                        }, enabled: false),
                        SizedBox(
                          height: 20,
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
          _selectedDate = selectedDate;
          _fechaSeleccionada.text =
              DateFormat('dd-MM-yyyy').format(selectedDate.toLocal());
        });
      }
    });
  }

  void _selectTime(BuildContext context) {
    final selector = HorarioSelector(
        fechaSeleccionada: _selectedDate,
        obtenerHorariosOcupados: bd.obtenerHorariosOcupados,
        idMedico: _medicoSeleccionado!.id,
        idPaciente: _dniPaciente.text,
        idSede: _sedeSeleccionada!.id);

    Navigator.pop(context);
    selector.mostrar(context, (TimeOfDay seleccionado) {
      setState(() {
        _horaSeleccionada.text = seleccionado.format(context);
      });
    });
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
