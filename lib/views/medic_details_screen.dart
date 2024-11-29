import 'package:consultorio_medico/models/medico.dart';
import 'package:consultorio_medico/views/components/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class MedicDetailsScreen extends StatelessWidget {
  final Medico selectedMedic;
  const MedicDetailsScreen({super.key, required this.selectedMedic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles de médico"),
      ),
      body: Padding(padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child:
                selectedMedic.foto.isNotEmpty
                  ? Image.network(
                selectedMedic.foto,
                width: 40,
                height: 40,
              )
                  : Image.asset('assets/images/doctor.png',
                width: 60,
                height: 60,
              ),
              ),
              SizedBox(width: 10,),
              Text(selectedMedic.nombre, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 18),)
            ],
          ),
          SizedBox(height: 36,),
          buildInfoRow("Especialidad: ", selectedMedic.titulo),
          SizedBox(height: 15,),
          buildInfoRow("Ubicación: ", selectedMedic.idSede),
          SizedBox(height: 15,),
          buildInfoRow("Descripción: ", selectedMedic.descripcion),
          SizedBox(height: 15,),
          buildInfoRow("CMP: ", selectedMedic.cmp, otherComponent: Link(uri: Uri.parse('https://www.cmp.org.pe/conoce-a-tu-medico/'),
              builder: (context, openLink) => TextButton(onPressed: openLink, child: Text(selectedMedic.cmp)))),
        ],
      ),),
    );
  }

}