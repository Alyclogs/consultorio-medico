import 'package:consultorio_medico/controllers/date_formatter.dart';
import 'package:consultorio_medico/models/medico.dart';
import 'package:consultorio_medico/models/providers/cita_provider.dart';
import 'package:consultorio_medico/models/providers/medico_provider.dart';
import 'package:consultorio_medico/models/providers/sede_provider.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/models/usuario.dart';
import 'package:flutter/material.dart';
import '../models/cita.dart';

import '../models/sede.dart';

class AppointmentsScreen extends StatefulWidget {
  final int initialIndex;

  const AppointmentsScreen({super.key, this.initialIndex = 0});

  @override
  State<StatefulWidget> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  DateFormatter dateFormatter = DateFormatter();
  CitaProvider bd = CitaProvider.instance;
  Usuario usuarioActual = UsuarioProvider.instance.usuarioActual;
  late List<Cita> citasPendientes = [];
  late List<Cita> citasFinalizadas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedics();
  }

  Future<void> _loadMedics() async {
    try {
      citasPendientes = await bd.getRegistros(usuarioActual.id, "PENDIENTE");
      citasPendientes = await bd.getRegistros(usuarioActual.id, "FINALIZADO");
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar citas: $e');
    }
  }

  /*
  List<Cita> citasPendientes = [
    Cita(
        id: "Ci-10001",
        fecha: DateTime.now(),
        nomPaciente: "Ana",
        dniPaciente: "46564572",
        edadPaciente: 42,
        idMedico: "Med-1001",
        idSede: "MedicArt-Ate-01",
        motivo: "Consulta General",
        costo: 50.0,
        estado: "PENDIENTE",
        notificar: true),
    Cita(
        id: "Ci-10032",
        fecha: DateTime.now(),
        nomPaciente: "Carlos",
        dniPaciente: "06948322",
        edadPaciente: 56,
        idMedico: "Med-1001",
        idSede: "MedicArt-Ate-01",
        motivo: "Cita de Control",
        costo: 0.0,
        estado: "PENDIENTE",
        notificar: true),
  ];

  List<Cita> citasFinalizadas = [
    Cita(
        id: "Ci-10011",
        fecha: DateTime.now(),
        nomPaciente: "Carlos",
        dniPaciente: "06948322",
        edadPaciente: 56,
        idMedico: "Med-1001",
        idSede: "MedicArt-Ate-01",
        motivo: "Consulta General",
        costo: 50.0,
        estado: "FINALIZADO",
        notificar: false),
    Cita(
        id: "Ci-10023",
        fecha: DateTime.now(),
        nomPaciente: "Ana",
        dniPaciente: "46564572",
        idMedico: "Med-1001",
        idSede: "MedicArt-Ate-01",
        edadPaciente: 42,
        motivo: "Analisis Medico",
        costo: 50.0,
        estado: "FINALIZADO",
        notificar: false)
  ];

  final Resultado resultadoCita = Resultado("ResCi-10002", "Ci-10002",
      "Faringitis", "No bebidas heladas, Si tomar agua tibia", [
    Medicamento(
        medicamento: "Amoxicilina con Acido Clavulanico",
        dosis: "1und. Mañana, 1und Noche (Antes de las comidas)",
        duracion: "7 días")
  ]);

  final Analisis analisis = Analisis("AnCi-10023", "Ci-10023", [
    ResultadoAnalisis("Hemoglobina", 14),
    ResultadoAnalisis("Glucosa", 92),
    ResultadoAnalisis("Colesterol total", 159),
    ResultadoAnalisis("Triglicéridos", 67)
  ]);
   */

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              indicatorColor: Color(0xFF5494a3),
              labelColor: Color(0xFF5494a3),
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.grey[400],
              tabs: [
                Tab(child: Text('Citas pendientes')),
                Tab(child: Text('Historial de citas')),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  isLoading ? Center(child: CircularProgressIndicator()) : _listaCitas(context, citasPendientes),
                  isLoading ? Center(child: CircularProgressIndicator()) : _listaCitas(context, citasFinalizadas),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaCitas(BuildContext context, List<Cita> citas) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          if (citas.isNotEmpty)
          ...citas.map((cita) => FutureBuilder<Widget>(
            future: _buildCita(cita),
            builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return snapshot.data ?? SizedBox();
              }
            },
          ))
          else
            Center(child: Text("No hay citas para mostrar")),
          SizedBox(height: 62),
        ],
      ),
    );
  }


  Future<Widget> _buildCita(Cita cita) async {
    final Medico? medico = await MedicoProvider.instance.getRegistro(cita.idMedico);
    final Sede? sede = await SedeProvider.instance.getRegistro(cita.idSede);

    return GestureDetector(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 3,
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: Image.asset(
                      "assets/images/usuario.png",
                      width: 46.0,
                      height: 46.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(medico != null ? medico.nombre : "Médico No Identificado",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff0c4454))),
                        SizedBox(height: 10),
                        Text(sede != null ? sede.nombre : "Sede No Identificada", style: TextStyle(fontSize: 11)),
                        SizedBox(height: 20),
                        Text(cita.motivo, style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  if (cita.estado == "PENDIENTE")
                    PopupMenuButton<String>(
                      padding: EdgeInsets.all(6),
                      color: Colors.white,
                      iconColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      onSelected: (value) {
                        // Manejo de selección
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          value: 'ToggleNotification_${cita.id}',
                          child: Text(cita.notificar
                              ? "Desactivar alarma"
                              : "Activar alarma", style: TextStyle(color: Colors.grey[700]),),
                        ),
                        PopupMenuItem(
                          value: 'Modificar_${cita.id}',
                          child: Text('Modificar cita', style: TextStyle(color: Colors.grey[700]),),
                        ),
                        PopupMenuItem(
                          value: 'Eliminar_${cita.id}',
                          child: Text('Eliminar cita', style: TextStyle(color: Colors.grey[700]),),
                        ),
                      ],
                    )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              if (cita.estado != "FINALIZADO")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        cita.notificar
                            ? "Alerta activada"
                            : "Alerta desactivada",
                        style: TextStyle(fontSize: 11)),
                    Text(dateFormatter.formatStringDate(cita.fecha),
                        style: TextStyle(fontSize: 11)),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(dateFormatter.formatStringDate(cita.fecha),
                        style: TextStyle(fontSize: 11)),
                  ],
                ),
              if (cita.estado == "FINALIZADO")
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 6),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.all(12),
                      side: BorderSide(width: 1, color: Color(0xFF5494a3)),
                      overlayColor: Color(0xFF5494a3),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF5494a3),
                          size: 11,
                        ),
                        SizedBox(width: 8,),
                        Text(
                          "Ver resultado",
                          style:
                              TextStyle(fontSize: 11, color: Color(0xFF5494a3)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
