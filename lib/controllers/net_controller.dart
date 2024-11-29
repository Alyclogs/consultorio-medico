import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkController {
  bool hasInternet = true;
  late StreamSubscription<InternetStatus> listener;

  void checkInternetConnection({
    Function()? onInternetConnected,
    Function()? onInternetDisconnected,
  }) {
    InternetConnection().hasInternetAccess.then((value) {
      hasInternet = value;
      if (value) {
        onInternetConnected?.call();
      } else {
        onInternetDisconnected?.call();
      }
    });

    listener = InternetConnection().onStatusChange.listen((status) {
      final conectado = (status == InternetStatus.connected);
      if (hasInternet != conectado) {
        hasInternet = conectado;
        if (conectado) {
          onInternetConnected?.call();
        } else {
          onInternetDisconnected?.call();
        }
      }
      print('Conexion a internet $conectado');
    });
  }

  void dispose() {
    listener.cancel();
  }
}
