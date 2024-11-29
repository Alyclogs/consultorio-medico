import 'package:consultorio_medico/models/notificacion.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/providers/notificacion_provider.dart';

class NotificationsController {
  static final NotificationsController instance =
      NotificationsController._init();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'appointment_channel',
    'Appointment Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
  );
  bool isNotificationPermsGranted = false;

  NotificationsController._init() {
    tz_data.initializeTimeZones();
  }

  Future<bool> openApplicationSettings() async {
    return await openAppSettings();
  }

  Future<void> initializeNotifications() async {
    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (response) async {
        if (response.payload != null && response.payload!.isNotEmpty) NotificationProvider.instance.navigateToAppointmentScreen(response.payload!);
    },);
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> scheduleNotification({
    required Notificacion notification,
  }) async {
    try {
      final location = tz.getLocation('America/Lima');
      final scheduledTZTime = tz.TZDateTime.from(notification.timestamp!, location);

      var androidDetails = AndroidNotificationDetails(
        'appointment_channel',
        'Appointment Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      var platformDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        scheduledTZTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        payload: notification.citaId,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('Notificación programada para: $scheduledTZTime');

      await NotificationProvider.instance.addNotification(notification);
    } catch (e) {
      print("Error al programar la notificación: $e");
    }
  }

  Future<void> sendNotification(Notificacion notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'appointment_channel',
          'Appointment Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      notification.id,
      notification.title,
      notification.body,
      payload: notification.citaId,
      platformChannelSpecifics,
    );
  }

  Future<void> updateNotification(Notificacion notification) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(notification.id);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'appointment_channel',
        'Appointment Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );
      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
      await NotificationProvider.instance.updateNotification(notification);

      await _flutterLocalNotificationsPlugin.show(
        notification.id,
        notification.title,
        notification.body,
        payload: notification.citaId,
        platformChannelSpecifics,
      );
    } catch (e) {
      print("Error al actualizar la notificación: $e");
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      await NotificationProvider.instance.deleteNotification(notificationId);

    } catch (e) {
      print('Error al eliminar la notificación');
    }
  }

  Future<void> updateNotificationScheduled({
    required Notificacion notification,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(notification.id);

      final location = tz.getLocation('America/Lima');
      final scheduledTZTime = tz.TZDateTime.from(notification.timestamp!, location);

      var androidDetails = AndroidNotificationDetails(
        'appointment_channel',
        'Appointment Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      var platformDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        scheduledTZTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        payload: notification.citaId,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('Notificación programada para: $scheduledTZTime');

      await NotificationProvider.instance.updateNotification(notification);
    } catch (e) {
      print("Error al actualizar la notificación: $e");
    }
  }
}
