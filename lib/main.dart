import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'views/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => runApp(const MedicArtApp()));
}

class MedicArtApp extends StatelessWidget {
  const MedicArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          timeSelectorSeparatorColor: WidgetStatePropertyAll(Color(0xFF5494a3)),
          dialTextColor: Colors.grey[700],
          dialBackgroundColor: Color(0xffe0ecec),
          dialTextStyle: TextStyle(backgroundColor: Colors.transparent, fontSize: 16, fontWeight: FontWeight.bold)
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
          dayStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey[600]),
          weekdayStyle: TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xff0c4454),
              fontWeight: FontWeight.bold),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      showSemanticsDebugger: false,
    );
  }
}
