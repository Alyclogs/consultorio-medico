import 'dart:convert';
import 'package:consultorio_medico/models/providers/cita_provider.dart';
import 'package:consultorio_medico/views/success_page.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:consultorio_medico/models/cita.dart';
import 'package:consultorio_medico/models/providers/usuario_provider.dart';
import 'package:consultorio_medico/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'error_page.dart';

class PaymentWebView extends StatefulWidget {
  const PaymentWebView({super.key, required this.appointment});
  final Cita appointment;

  @override
  PaymentWebViewState createState() => PaymentWebViewState();
}

class PaymentWebViewState extends State<PaymentWebView> {
  final Usuario _currentUser = UsuarioProvider.instance.usuarioActual;
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllowFullscreen: true,
    useOnDownloadStart: true,
    allowFileAccessFromFileURLs: true,
    useOnLoadResource: true,
    supportMultipleWindows: true,
  );

  PullToRefreshController? pullToRefreshController;
  double progress = 0;
  String? _finalUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Color(0xFF5494a3),
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
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

    return Scaffold(
      appBar: AppBar(
        title: Text("Pagar cita"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: WebUri(_finalUrl!)),
                  initialSettings: settings,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      isLoading = true;
                    });
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;
                    if (uri.scheme.contains('success')) {
                      await CitaProvider.instance
                          .addRegistro(widget.appointment);
                      final pago = await CitaProvider.instance
                          .getPago(widget.appointment.id);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SuccessPage(pago: pago)));
                      return NavigationActionPolicy.CANCEL;
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController?.endRefreshing();
                    setState(() {
                      isLoading = false;
                    });
                  },
                  onReceivedError: (controller, request, error) {
                    pullToRefreshController?.endRefreshing();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => ErrorPage()));
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController?.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  onPermissionRequest: (InAppWebViewController controller,
                      PermissionRequest request) async {
                    return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT,
                    );
                  },
                  onDownloadStartRequest: (controller, request) async {
                    print("Download Start: $request.url");
                    if (request.url.toString().toLowerCase().endsWith('.pdf')) {
                      await launchUrl(request.url);
                    }
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
