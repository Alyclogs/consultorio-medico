import 'package:permission_handler/permission_handler.dart';

Future<bool> openApplicationSettings() async {
  return await openAppSettings();
}

Future<bool> requestSmsPermissions() async {
  if (await Permission.sms.isGranted) {
    print('Permiso de SMS ya concedido');
    return true;
  }

  final status = await Permission.sms.request();
  if (status.isGranted) {
    print('Permiso de SMS concedido');
  } else if (status.isDenied) {
    print('Permiso de SMS denegado');
  }
  return status.isGranted;
}

Future<bool> requestNotificationPermissions() async {
  if (await Permission.notification.isGranted) {
    print('Permiso de Notificaciones ya concedido');
  }

  PermissionStatus status = await Permission.notification.request();
  if (status.isGranted) {
    print('Permiso de Notificaciones concedido');
  } else if (status.isDenied) {
    print('Permiso de Notificaciones denegado');
  }
  return status.isGranted;
}
