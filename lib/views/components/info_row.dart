import 'package:flutter/material.dart';

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