import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/models/usuario.dart';
import 'package:consultorio_medico/views/change_password_screen.dart';
import 'package:consultorio_medico/views/login_screen.dart';
import 'package:flutter/material.dart';

import 'components/info_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  Usuario currentUser = UsuarioProvider.instance.usuarioActual;
  bool _passVisible = false;
  bool _isEditing = false;
  final _passController = TextEditingController();

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
            Text(
              "Datos personales",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {},
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
                      buildInfoRow("Edad", '${currentUser.edad}'),
                      SizedBox(height: 20),
                      buildInfoRow("Género", currentUser.genero),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ChangePasswordScreen(
                                        previousPass: UsuarioProvider.instance
                                            .usuarioActual.contrasena)));
                                setState(() {});
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
                        height: 20,
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

  Widget _buildInputField(
      BuildContext context, TextEditingController controller, String text,
      {int? maxLength,
      bool password = false,
      TextInputType? inputType,
      Function()? onTap,
      bool enabled = true,
      TextCapitalization? caps}) {
    return TextFormField(
      controller: controller,
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
        suffixIcon: password
            ? IconButton(
                icon: Icon(
                  _passVisible ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).primaryColorDark,
                ),
                onPressed: () {
                  setState(() {
                    _passVisible = !_passVisible;
                  });
                },
              )
            : null,
      ),
      maxLength: maxLength,
      keyboardType: inputType ?? TextInputType.text,
      textCapitalization: caps ?? TextCapitalization.none,
      style: Theme.of(context).textTheme.bodyMedium,
      obscureText: password ? !_passVisible : false,
      onTap: onTap,
      readOnly: !enabled,
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            (maxLength != null && value.length != maxLength)) {
          if (password &&
              value?.length != 6 &&
              !RegExp(".*[0-9].*").hasMatch(value ?? '') &&
              !RegExp('.*[a-z].*').hasMatch(value ?? '') &&
              !RegExp('.*[A-Z].*').hasMatch(value ?? '')) {
            return 'La contraseña debe tener al menos 6 carácteres, letras mayúsculas y minúsculas y números';
          }
          return 'Por favor complete este campo';
        }
        return null;
      },
    );
  }
}
