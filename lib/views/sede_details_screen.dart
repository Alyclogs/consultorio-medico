import 'package:consultorio_medico/views/components/utils.dart';
import 'package:flutter/material.dart';
import '../models/sede.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SedeDetailsScreen extends StatelessWidget {
  final Sede selectedSede;
  const SedeDetailsScreen({super.key, required this.selectedSede});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles de sede"),
      ),
      body: SingleChildScrollView(
        // Permite desplazamiento en caso de overflow
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: selectedSede.foto.isNotEmpty
                        ? Image.network(
                            selectedSede.foto,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/hospital.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    selectedSede.nombre,
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
              SizedBox(
                height: 36,
              ),
              buildInfoRow("Dirección: ", selectedSede.direccion),
              SizedBox(
                height: 15,
              ),
              Container(
                height:
                    300,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                        double.parse(selectedSede.coordenadas.split(',').first),
                        double.parse(selectedSede.coordenadas.split(',').last)),
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.developer.consultorio_medico',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(double.parse(selectedSede.coordenadas.split(',').first),
                            double.parse(selectedSede.coordenadas.split(',').last)),
                          width: 80,
                          height: 80,
                          child: Icon(Icons.location_on, color: Colors.red,),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
