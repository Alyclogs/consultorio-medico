import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.error,
                    color: Color(0xFF5494a3),
                    size: 72,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                      "Hubo un error al procesar tu pago, por favor vuelve a intentarlo"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
