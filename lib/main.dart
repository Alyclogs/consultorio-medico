import 'package:consultorio_medico/controllers/notifications_controller.dart';
import 'package:consultorio_medico/controllers/permission_handler.dart';
import 'package:consultorio_medico/models/providers/cita_provider.dart';
import 'package:consultorio_medico/models/providers/notificacion_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import 'views/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await CitaProvider.instance.checkAppointmentsStatus();
      return Future.value(true);
    } catch (e) {
      print("Error en la tarea de Workmanager: $e");
      return Future.value(false);
    }
  });
  Workmanager().executeTask((task, inputData) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await NotificationProvider.instance.removeOldNotifications();
      return Future.value(true);
    } catch (e) {
      print("Error en la tarea de Workmanager: $e");
      return Future.value(false);
    }
  });
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  var notifyPrefs = await Permission.notification.isGranted;
  if (!notifyPrefs) notifyPrefs = await requestNotificationPermissions();
  NotificationsController.instance.isNotificationPermsGranted = true;
  await NotificationsController.instance.initializeNotifications();

  final prefs = await SharedPreferences.getInstance();
  final workmanagerInitialized = prefs.getBool('wm_initialized');

  if (workmanagerInitialized != null && !workmanagerInitialized) {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    await Workmanager().registerPeriodicTask(
        'checkAppointments', 'checkAppointmentsStatus',
        frequency: const Duration(minutes: 15));
    await Workmanager().registerPeriodicTask(
        'removeNotifications', 'removeOldNotifications',
        frequency: const Duration(days: 7));

    await prefs.setBool('wm_initialized', true);
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MedicArtApp());
}

class MedicArtApp extends StatelessWidget {
  const MedicArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      supportedLocales: [const Locale('es', 'PE')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale('es'),
      theme: ThemeData(
        primaryColor: Color(0xFF5494a3),
        primaryColorDark: Color(0xff0c4454),
        colorScheme: ColorScheme.light(primary: Color(0xFF5494a3)),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            actionsIconTheme: IconThemeData(
              color: Color(0xff0c4454),
            ),
            titleTextStyle: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xff0c4454))),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xff0c4454),
            backgroundColor: Colors.white,
          ),
          bodyMedium: TextStyle(
              fontFamily: 'Poppins', color: Colors.grey[700], fontSize: 13),
          bodySmall: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300,
              color: Colors.grey[600],
              fontSize: 10),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          headerBackgroundColor: Color(0xFF5494a3),
          headerForegroundColor: Colors.white,
          dividerColor: Colors.transparent,
          cancelButtonStyle: OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
            overlayColor: Color(0xFF5494a3),
          ),
          //yearForegroundColor: WidgetStatePropertyAll(Colors.grey[600]),
          yearStyle:
              TextStyle(fontWeight: FontWeight.normal, color: Colors.grey[600]),
          dayStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey[600]),
          weekdayStyle: TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xff0c4454),
              fontWeight: FontWeight.bold),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(action: 'login'),
      showSemanticsDebugger: false,
    );
  }
}
