import 'package:consultorio_medico/models/providers/sede_provider.dart';
import 'package:consultorio_medico/views/sede_details_screen.dart';
import 'package:flutter/material.dart';

import '../models/sede.dart';

class SedesScreen extends StatefulWidget {
  const SedesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SedesScreenState();
}

class _SedesScreenState extends State<SedesScreen>
    with SingleTickerProviderStateMixin {
  final bd = SedeProvider.instance;
  late List<Sede> sedes = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSedes();
  }

  Future<void> _loadSedes() async {
    try {
      sedes = await bd.getRegistros();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar sedes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : sedes.isEmpty
          ? Center(
        child: Text("No hay sedes para mostrar"),
      )
          : Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sedes",
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: sedes.length,
                itemBuilder: (context, index) {
                  return _buildSede(sedes[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSede(Sede sede) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SedeDetailsScreen(selectedSede: sede))),
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
                      "assets/images/hospital.png",
                      width: 72.0,
                      height: 72.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(sede.nombre,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xff0c4454),
                      )),
                  SizedBox(height: 20),
                    Text(sede.direccion,
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