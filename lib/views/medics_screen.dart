import 'package:consultorio_medico/models/providers/medico_provider.dart';
import 'package:consultorio_medico/views/medic_details_screen.dart';
import 'package:flutter/material.dart';

import '../models/medico.dart';

class MedicsScreen extends StatefulWidget {
  const MedicsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MedicsScreenState();
}

class _MedicsScreenState extends State<MedicsScreen>
    with SingleTickerProviderStateMixin {
  final bd = MedicoProvider.instance;
  late List<Medico> medicos = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedics();
  }

  Future<void> _loadMedics() async {
    try {
      medicos = await bd.getRegistros();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar medicos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : medicos.isEmpty
              ? Center(child: Text("No hay médicos para mostrar"),)
              : Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Médicos",
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 24),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                            childAspectRatio: 0.6,
                          ),
                          itemCount: medicos.length,
                          itemBuilder: (context, index) {
                            final Medico medico = medicos[index];
                            return _buildMedico(medico);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMedico(Medico medico) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MedicDetailsScreen(selectedMedic: medico))),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 3,
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      "assets/images/usuario.png",
                      width: 72.0,
                      height: 72.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(medico.nombre,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xff0c4454),
                      )),
                  SizedBox(height: 20),
                  Text(medico.titulo,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
