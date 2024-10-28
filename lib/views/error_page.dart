import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Center(
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
                    SizedBox(
                      height: 54,
                    ),
                    Container(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(0xFF5494a3),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Regresar',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
