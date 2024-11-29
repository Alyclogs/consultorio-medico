import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/views/components/loading_screen.dart';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'components/utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _previousPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _newPassController2 = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passVisible = false;
  final currentUser = UsuarioProvider.instance.usuarioActual;

  _changePassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final prevPass = Usuario.encryptPassword(_previousPassController.text);
      if (prevPass != currentUser.contrasena) {
        showInfoDialog(context, 'Error', "La contraseña actual es incorrecta");
        return;
      }
      final newPass = _newPassController.text;
      if (newPass != _newPassController2.text) {
        showInfoDialog(context, 'Error', "Las contraseñas no coinciden");
        return;
      }
      if (prevPass == Usuario.encryptPassword(newPass)) {
        showInfoDialog(context, 'Error',
            'La contraseña nueva no debe ser igual a la contraseña actual');
        return;
      }
      if (newPass.length < 6 ||
          !RegExp(".*[0-9].*").hasMatch(newPass) ||
          !RegExp('.*[a-z].*').hasMatch(newPass) ||
          !RegExp('.*[A-Z].*').hasMatch(newPass)) {
        showInfoDialog(context, 'Error',
            'La contraseña debe tener al menos 6 carácteres, letras mayúsculas, minúsculas y números');
        return;
      }
      setState(() {
        currentUser.contrasena = _newPassController.text;
      });
      loadingScreen(context);
      await UsuarioProvider.instance.updateRegistro(currentUser);
      setState(() {
        UsuarioProvider.instance.usuarioActual = currentUser;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contraseña actualizada')),
      );
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, _newPassController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Cambia tu contraseña",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(
                height: 52,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInputField(context, _previousPassController,
                          "Ingrese su contraseña actual"),
                      SizedBox(height: 20),
                      _buildInputField(context, _newPassController,
                          "Ingrese una nueva contraseña",
                          password: true),
                      SizedBox(height: 10),
                      _buildInputField(context, _newPassController2,
                          "Repita la nueva contraseña",
                          password: true),
                      SizedBox(height: 52),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Color(0xFF5494a3),
                          ),
                          onPressed: () async {
                            await _changePassword();
                          },
                          child: Text(
                            'Cambiar contraseña',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      BuildContext context, TextEditingController controller, String text,
      {bool password = false}) {
    return TextFormField(
      controller: controller,
      obscureText: !_passVisible,
      style: Theme.of(context).textTheme.bodyMedium,
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
        suffixIcon: IconButton(
          icon: Icon(
            _passVisible ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).primaryColorDark,
          ),
          onPressed: () {
            setState(() {
              _passVisible = !_passVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, rellena este campo';
        }
        return null;
      },
    );
  }
}
