import 'package:consultorio_medico/views/components/bottom_navbar.dart';
import 'package:consultorio_medico/views/components/loading_screen.dart';
import 'package:consultorio_medico/views/register_screen.dart';
import 'package:flutter/material.dart';
import '../models/providers/usuario_provider.dart';
import '../models/usuario.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final bd = UsuarioProvider.instance;
  late bool _passVisible = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      String dni = _dniController.text;
      String pass = _passController.text;
      bool existe = false;

      loadingScreen(context);
      existe = await bd.validarUsuario(dni, pass);
      if (existe) {
        Usuario? usuario;
        usuario = await bd.getRegistro(dni);

        if (usuario != null) {
          setState(() {
            bd.usuarioActual = usuario!;
          });
          Navigator.pop(context);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => BottomNavBar()));
          return;
        }
      }
      Navigator.pop(context);
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Usuario o contraseña incorrectos.'),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right: 16, top: 24),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Image.asset('assets/images/heart-pulse_green.png'),
                  SizedBox(height: 10),
                  Text('MedicArt',
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: 'Poppins',
                      )),
                  SizedBox(height: 56),
                  Text('Bienvenido de nuevo',
                      style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 24),
                  Text('Ingrese los credenciales vinculados a su cuenta',
                      style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(height: 52),
                  Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _dniController,
                            decoration: InputDecoration(
                              hintText: 'Número de DNI',
                              hintStyle: Theme.of(context).textTheme.bodyMedium,
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                            keyboardType: TextInputType.number,
                            maxLength: 8,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su número de DNI';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _passController,
                            decoration: InputDecoration(
                              hintText: 'Contraseña',
                              hintStyle: Theme.of(context).textTheme.bodyMedium,
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passVisible = !_passVisible;
                                  });
                                },
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                            obscureText: !_passVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese su contraseña';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 36),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Color(0xFF5494a3),
                              ),
                              onPressed: () {
                                _login();
                              },
                              child: Text(
                                'Ingresar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Color(0xffe0ecec),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('¿No tienes una cuenta? ',
                          style: TextStyle(
                            fontSize: 12,
                          )),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()));
                        },
                        child: Text('Registrarme',
                            style: TextStyle(
                                color: Color(0xFF5494a3),
                                fontSize: 12,
                                decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
