import 'package:flutter/material.dart';

Future<void> showError(String message, BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "Error",
        style: TextStyle(color: Colors.red),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("OK"),
        ),
      ],
      backgroundColor: Colors.red[100],
    ),
  );
}
