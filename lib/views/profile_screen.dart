import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/models/usuario.dart';
import 'package:flutter/material.dart';

import 'components/info_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  Usuario currentUser = UsuarioProvider.instance.usuarioActual;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Datos personales",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xFF5494a3),
                  ),
                  child: Text(
                    "Editar datos",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView( // Agrega scroll si el contenido es grande
                child: Container(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      ClipOval(
                        child: currentUser.foto.isNotEmpty
                            ? Image.network(
                          currentUser.foto,
                          width: 168.0,
                          height: 168.0,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          'assets/images/usuario.png',
                          width: 168.0,
                          height: 168.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 56),
                      buildInfoRow("Nombre", currentUser.nombre),
                      SizedBox(height: 20),
                      buildInfoRow("DNI", currentUser.id),
                      SizedBox(height: 20),
                      buildInfoRow("Teléfono", currentUser.telefono),
                      SizedBox(height: 20),
                      buildInfoRow("Edad", '${currentUser.edad}'),
                      SizedBox(height: 20),
                      buildInfoRow("Género", currentUser.genero),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
