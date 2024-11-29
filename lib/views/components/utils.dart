import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildInfoRow(String label, String value, {double? size, Widget? otherComponent}) {
  return Row(
    children: [
      Text(
        label,
        style: TextStyle(
          color: Color(0xff0c4454),
          fontSize: size ?? 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(width: 10),
      otherComponent ?? Expanded(
        child: Text(
          value,
          style: TextStyle(fontSize: size ?? 14),
        ),
      ),
    ],
  );
}

void showInfoDialog(BuildContext context, String title, String msg, {String? linkText, Function()? onClickLink}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: msg,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (linkText != null)
                TextSpan(
                  text: linkText,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                      fontFamily: 'Poppins',
                      fontSize: 13),
                  recognizer: TapGestureRecognizer()
                    ..onTap = onClickLink
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Aceptar'),
          ),
        ],
      );
    },
  );
}

showMessenger(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text)),
  );
}