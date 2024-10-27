import 'dart:convert';
import 'package:consultorio_medico/models/providers/cita_provider.dart';
import 'package:consultorio_medico/views/success_page.dart';
import 'package:http/http.dart' as http;
import 'package:consultorio_medico/models/cita.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'error_page.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({super.key, required this.appointment});
  final Cita appointment;

  @override
  PaymentWebViewState createState() => PaymentWebViewState();
}

class PaymentWebViewState extends State<PaymentWebView> {
  final Usuario _currentUser = UsuarioProvider.instance.usuarioActual;
  late WebViewController _controller;
  String? _finalUrl;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() async {
    String? finalUrl = await _getConfig();

    setState(() {
      _finalUrl = finalUrl!;
    });
  }

  Future<String?> _getConfig() async {
    var url = Uri.parse('http://34.136.53.241:3000/url');
    String amountInteger = '${(widget.appointment.costo * 100).toInt()}';

    var body = {
      'email': "${_currentUser.id}@email.com",
      'amount': amountInteger,
      'currency': "604",
      'mode': "TEST",
      'language': "es",
      'orderId': widget.appointment.id
    };

    var jsonData = json.encode(body);
    print(jsonDecode(jsonData));

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );

    print(jsonDecode(response.body));
    if (response.statusCode != 200) return null;
    var data = jsonDecode(response.body);
    String responseString = data['redirectionUrl'].toString();
    return responseString;
  }

  @override
  Widget build(BuildContext context) {
    if (_finalUrl == null) {
      return Center(child: CircularProgressIndicator());
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x80000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            if (url.contains('success')) {
              await CitaProvider.instance.addRegistro(widget.appointment);
              final pago =
                  await CitaProvider.instance.getPago(widget.appointment.id);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SuccessPage(pago: pago)));
              return NavigationDecision.prevent;
            } else if (url.contains('error') || url.contains('cancel')) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ErrorPage()));
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_finalUrl!));

    return Scaffold(
      appBar: AppBar(
        title: Text("Pagar cita"),
      ),
      body: Container(
        color: Colors.transparent,
        child: WebViewWidget(key: UniqueKey(), controller: _controller),
      ),
    );
  }

  @override
  void dispose() {
    _clearCache();
    super.dispose();
  }

  Future<void> _clearCache() async {
    await _controller.clearCache();
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();
  }
}
