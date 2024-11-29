import 'dart:convert';
import 'dart:math';
import 'package:consultorio_medico/controllers/permission_handler.dart';
import 'package:consultorio_medico/views/components/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_auth/smart_auth.dart';

Future<bool> validateNumber(String number) async {
  try {
    final response = await http.get(
        Uri.parse(
            'https://phonenumbervalidatefree.p.rapidapi.com/ts_PhoneNumberValidateTest.jsp?number=%2B51$number'),
        headers: {
          'x-rapidapi-key': '${dotenv.env['RAPIDAPI_KEY']}',
          'x-rapidapi-host': 'phonenumbervalidatefree.p.rapidapi.com'
        });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["location"] == "Peru";
    }
    return false;
  } catch (e) {
    print("No se ha podido validar el numero ingresado $e");
    return false;
  }
}

String? _validateOtpCode(String body) {
  final otpCodeRegex = RegExp(r'\b\d{4}\b');
  Match? match = otpCodeRegex.firstMatch(body);
  if (match != null) {
    String otpCode = match.group(0)!;
    return otpCode;
  } else {
    return null;
  }
}

Future<String?> sendSMS(String number, String appSignature) async {
  final random = Random();
  final otpCode = _validateOtpCode('${random.nextInt(9000) + 1000}');
  if (otpCode != null) {
    try {
      final body = json.encode({
        'recipients': ['+51$number'],
        'message': """
        <#> MedicArt: Su código de verificación es $otpCode
        
        $appSignature
        """,
      });
      final headers = {
        'x-api-key': '${dotenv.env["TEXTBEE_API_KEY"]}',
        'Content-Type': 'application/json',
      };
      final response = await http.post(
          Uri.parse(
              'https://api.textbee.dev/api/v1/gateway/devices/${dotenv.env["TEXTBEE_DEVICE_ID"]}/send-sms'),
          headers: headers,
          body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Code sent: $otpCode');
        return otpCode;
      }
    } catch (e) {
      print("No se ha podido validar el numero ingresado $e");
      return null;
    }
  }
  return null;
}

class VerifyPhoneScreen extends StatefulWidget {
  final String telephoneNumber;
  final Function() onVerified;

  const VerifyPhoneScreen(
      {super.key, required this.telephoneNumber, required this.onVerified});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  String otpCode = '';
  final otpEditingController = TextEditingController();
  final smartAuth = SmartAuth();
  String? codeSent;
  int secondsToResend = 31;

  @override
  void initState() {
    super.initState();
    _initValidation();
  }

  Future<String?> getAppSignature() async {
    return await smartAuth.getAppSignature();
  }

  Future<bool> _checkPermissions() async {
    bool isGranted = await Permission.sms.isGranted;
    if (!isGranted) {
      isGranted = await requestSmsPermissions();
    }
    setState(() {});
    return isGranted;
  }

  @override
  void dispose() {
    otpEditingController.dispose();
    smartAuth.removeSmsListener();
    super.dispose();
  }

  void _initValidation() async {
    final permGranted = await _checkPermissions();
    if (permGranted) {
      otpEditingController.addListener(() {
        if (otpEditingController.text == codeSent) {
          _codeValidator();
        }
      });
      _sendCode();
    } else {
      print('SMS permission not granted');
      showInfoDialog(context, 'Error',
          'El permiso para recibir notificaciones es necesario para la validación.');
    }
  }

  void _sendCode() async {
    final appSignature = await getAppSignature();
    try {
      codeSent = await sendSMS(widget.telephoneNumber, appSignature ?? '');
      if (codeSent != null) {
        setState(() {
          secondsToResend = 31;
        });
        _smsRetriever();
        _resetCounter();
      }
    } catch (e) {
      print('Error al enviar código SMS');
      showInfoDialog(context, 'Error',
          'Ocurrió un error al enviar el código SMS. Inténtelo de nuevo más tarde');
    }
  }

  void _codeValidator() {
    if (otpEditingController.text == codeSent) {
      Future.delayed(Duration(seconds: 1), () {
        widget.onVerified();
      });
    }
  }

  void _smsRetriever() async {
    print('Listening for SMS...');
    final res = await smartAuth.getSmsCode();

    if (res.codeFound && res.code == codeSent) {
      setState(() {
        otpEditingController.text = res.code!;
        otpEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: otpEditingController.text.length),
        );
      });
      _codeValidator();
    } else {
      debugPrint('No se encontró un código válido en el SMS: $res');
    }
  }

  void _resetCounter() {
    if (otpEditingController.text != codeSent) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          secondsToResend--;
        });
        if (secondsToResend > 0) {
          _resetCounter();
        }
      });
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 36),
          child: Text('Validación de número'),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ingrese el código enviado al número',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            widget.telephoneNumber,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          Pinput(
            controller: otpEditingController,
            length: 4,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,
          ),
          const SizedBox(height: 42),
          Text(
            'No recibiste el código?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextButton(
            onPressed: secondsToResend == 0 ? _sendCode : null,
            child: Text(
              'Reenviar',
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontFamily: 'Poppins',
                  color: secondsToResend == 0
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          if (secondsToResend > 0 && secondsToResend < 31) ...[
            Text(
              'Puedes solicitar un nuevo código en $secondsToResend segundos',
              style: TextStyle(color: Colors.grey, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ]
        ],
      ),
    );
  }
}
