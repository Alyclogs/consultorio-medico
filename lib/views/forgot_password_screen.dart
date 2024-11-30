import 'package:consultorio_medico/controllers/sms_sender.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/views/change_password_screen2.dart';
import 'package:consultorio_medico/views/components/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _dniController = TextEditingController();
  final _telfController = TextEditingController();

  void _nextStep() async {
    loadingScreen(context);
    final matchedUser = await UsuarioProvider.instance
        .getRegistroPorNumero(_dniController.text, _telfController.text);
    final validNumber = await validateNumber(_telfController.text);
    Navigator.pop(context);

    if (validNumber && matchedUser != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => VerifyPhoneScreen(
              telephoneNumber: _telfController.text,
              onVerified: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) =>
                          ChangePasswordScreen2(matchedUser: matchedUser))))));
    } else {
      showInfoDialog(context, 'Error', 'Los datos son incorrectos');
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
              Text(
                'Ingrese los datos vinculados a su cuenta',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(
                height: 52,
              ),
              TextField(
                controller: _dniController,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLength: 8,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Número de DNI',
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: _telfController,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLength: 9,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Número de teléfono',
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextButton(
                  onPressed: () => showInfoDialog(
                        context,
                        'Ayuda',
                        'Si cambió de número, por favor, envíenos un mensaje al siguiente correo ',
                        linkText: 'aquirozag@ucvvirtual.edu.pe',
                        onClickLink: () async {
                          final url = Uri(
                              scheme: 'mailto', path: 'aquirozag@ucvvirtual.edu.pe');
                          await launchUrl(url);
                        },
                      ),
                  child: Text(
                    'Cambié de número',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontFamily: 'Poppins',
                        color: Theme.of(context).primaryColor,
                        fontSize: 13),
                  )),
              SizedBox(
                height: 52,
              ),
              Row(
                children: [
                  Expanded(
                      child: FilledButton(
                          style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16)),
                          onPressed: () {
                            _nextStep();
                          },
                          child: Text('Siguiente',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              )))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
