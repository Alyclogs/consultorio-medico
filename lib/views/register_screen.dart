import 'package:consultorio_medico/controllers/auth_controller.dart';
import 'package:consultorio_medico/views/components/bottom_navbar.dart';
import 'package:consultorio_medico/views/components/loading_screen.dart';
import 'package:consultorio_medico/views/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/providers/usuario_provider.dart';
import '../models/usuario.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _pass2Controller = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telfController = TextEditingController();
  final TextEditingController _fnacController = TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final bd = UsuarioProvider.instance;
  late bool _passVisible = false;
  late bool _esMasculino = false;
  late DateTime _selectedDate = DateTime.now();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      String dni = _dniController.text;
      String pass = _passController.text;
      String pass2 = _pass2Controller.text;
      String nombre = _nombreController.text;
      String telf = _telfController.text;
      Usuario? existe;

      if (pass != pass2) {
        _showErrorDialog("Las contraseñas no coinciden");
        return;
      } else {
        loadingScreen(context);
        existe = await bd.getRegistro(dni);

        if (existe == null) {
          if (await AuthController.validarDNI(dni, nombre) != 200) {
            Navigator.pop(context);
            _showErrorDialog(
                "El DNI ingresado no es válido o los datos ingresados no coinciden");
            return;
          } else {
            final newUser = Usuario(
                id: dni,
                nombre: nombre,
                telefono: telf,
                edad: calcularEdad(_selectedDate),
                genero: _esMasculino ? "Masculino" : "Femenino");
            newUser.contrasena = pass;
            UsuarioProvider.instance.addRegistro(newUser, dni);
            UsuarioProvider.instance.usuarioActual = newUser;

            Navigator.pop(context);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => BottomNavBar()));
            return;
          }
        }
        Navigator.pop(context);
        _showErrorDialog(
            "Ya hay una cuenta asociada al número de DNI, si no recuerdas tu contraseña, por favor reestablécela ",
            forgot: true);
      }
    }
  }

  void _showErrorDialog(String msg, {bool forgot = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: msg,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                if (forgot)
                  TextSpan(
                    text: 'aquí',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgotPaswordScreen()),);
                      },
                  ),
              ],
            ),
          ),
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

  int calcularEdad(DateTime fechaNacimiento) {
    DateTime fechaActual = DateTime.now();
    int edad = fechaActual.year - fechaNacimiento.year;

    if (fechaActual.month < fechaNacimiento.month ||
        (fechaActual.month == fechaNacimiento.month &&
            fechaActual.day < fechaNacimiento.day)) {
      edad--;
    }

    return edad;
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
                  Text('Registro',
                      style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 30),
                  Text('Crea tu cuenta para comenzar',
                      style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(height: 52),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            "Datos personales",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          _buildInputField(
                              context, _dniController, "Número de DNI",
                              maxLength: 8, inputType: TextInputType.number),
                          SizedBox(height: 10),
                          _buildInputField(
                              context, _nombreController, "Nombre completo",
                              caps: TextCapitalization.sentences),
                          SizedBox(height: 10),
                          _buildInputField(
                              context, _telfController, "Número de teléfono",
                              maxLength: 9, inputType: TextInputType.number),
                          SizedBox(height: 10),
                          _buildInputField(
                              context, _fnacController, "Fecha de nacimiento",
                              onTap: () async {
                            loadingScreen(context);
                            await _selectDate(context);
                          }),
                          SizedBox(height: 10),
                          Text(
                            "Género:",
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: _esMasculino,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _esMasculino = !_esMasculino;
                                      });
                                    },
                                  ),
                                  Text('Masculino'),
                                ],
                              ),
                              SizedBox(width: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: !_esMasculino,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _esMasculino = !_esMasculino;
                                      });
                                    },
                                  ),
                                  Text('Femenino'),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Contraseña",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          _buildInputField(
                              context, _passController, "Cree una contraseña",
                              password: true),
                          SizedBox(height: 10),
                          _buildInputField(
                              context, _pass2Controller, "Repita su contraseña",
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
                                await _register();
                              },
                              child: Text(
                                'Registrarme',
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
                      Text('¿Ya tienes una cuenta? ',
                          style: TextStyle(
                            fontSize: 12,
                          )),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen())),
                        child: Text('Iniciar Sesión',
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

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked;
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecciona tu fecha de nacimiento',
    );
    Navigator.pop(context);

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked!;
        _fnacController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }
}
