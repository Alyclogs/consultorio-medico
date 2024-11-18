import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String previousPass;
  const ChangePasswordScreen({super.key, required this.previousPass});

  @override
  State<StatefulWidget> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _previousPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passVisible = false;

  _changePassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_previousPassController.text != widget.previousPass) {
        _showErrorDialog("La constraseña actual es incorrecta");
        return;
      } else {
        setState(() {
          UsuarioProvider.instance.usuarioActual.contrasena =
              _newPassController.text;
        });
        await UsuarioProvider.instance
            .updateRegistro(UsuarioProvider.instance.usuarioActual);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contraseña actualizada')),
        );
        Navigator.pop(context, _newPassController.text);
      }
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Center(
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
                      SizedBox(height: 10),
                      _buildInputField(context, _newPassController,
                          "Ingrese una nueva contraseña",
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
                  )
              ),
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
        if (password &&
            value.length != 6 &&
            !RegExp(".*[0-9].*").hasMatch(value ?? '') &&
            !RegExp('.*[a-z].*').hasMatch(value ?? '') &&
            !RegExp('.*[A-Z].*').hasMatch(value ?? '')) {
          return 'La contraseña debe tener al menos 6 carácteres, letras mayúsculas y minúsculas y números';
        }
        return null;
      },
    );
  }
}
