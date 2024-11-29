import 'package:consultorio_medico/controllers/auth_controller.dart';
import 'package:consultorio_medico/controllers/notifications_controller.dart';
import 'package:consultorio_medico/controllers/sms_sender.dart';
import 'package:consultorio_medico/models/providers/image_provider.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/models/usuario.dart';
import 'package:consultorio_medico/views/change_password_screen.dart';
import 'package:consultorio_medico/views/components/image_source_selector.dart';
import 'package:consultorio_medico/views/components/loading_screen.dart';
import 'package:consultorio_medico/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'components/utils.dart';

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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Datos personales",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final selector = ImageSourceSelector();
                        selector.mostrar(context, (source) async {
                          Navigator.pop(context);
                          final file = await CloudinaryProvider.instance
                              .pickImage(source);
                          if (file != null) {
                            final url = await CloudinaryProvider.instance
                                .uploadImage(
                                    file, 'users_pfps', currentUser.id);
                            if (url != null) {
                              loadingScreen(context);
                              currentUser.foto = url;
                              await UsuarioProvider.instance
                                  .updateRegistro(currentUser);
                              Navigator.pop(context);
                              setState(() {});
                            }
                          }
                        });
                      },
                      child: ClipOval(
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
                    ),
                    SizedBox(height: 56),
                    buildInfoRow("Nombre", currentUser.nombre),
                    SizedBox(height: 20),
                    buildInfoRow("DNI", currentUser.id),
                    SizedBox(height: 20),
                    buildInfoRow("Teléfono", currentUser.telefono),
                    SizedBox(height: 20),
                    buildInfoRow("Edad",
                        '${AuthController.calcularEdad(currentUser.fecha_nac)}'),
                    SizedBox(height: 20),
                    buildInfoRow("Género", currentUser.genero),
                    SizedBox(height: 40),
                    Text(
                      "Acciones",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => VerifyPhoneScreen(
                                      telephoneNumber: currentUser.telefono,
                                      onVerified: () => Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangePasswordScreen())))));
                            },
                            style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                backgroundColor:
                                    Theme.of(context).primaryColor),
                            label: Text("Cambiar contraseña"),
                            icon: Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await UsuarioProvider.instance.cerrarSesion();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                  (_) => false);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.all(12),
                              side: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).primaryColor),
                            ),
                            label: Text("Cerrar sesión"),
                            icon: Icon(
                              Icons.logout,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 40),
                    Text(
                      "Preferencias",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    buildInfoRow("Activar notificación", "",
                        otherComponent: Switch(
                          value: NotificationsController
                              .instance.isNotificationPermsGranted,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (bool value) async {
                            loadingScreen(context);
                            await NotificationsController.instance
                                .openApplicationSettings();
                            if (mounted) Navigator.pop(context);
                          },
                        )),
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
