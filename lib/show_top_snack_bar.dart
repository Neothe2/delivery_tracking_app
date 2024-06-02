import 'package:flutter/material.dart';

void showTopSnackBar(
    BuildContext context, String message, Color backgroundColor) {
  // Create ScaffoldMessengerState to show the snackbar
  ScaffoldMessengerState scaffoldMessengerState = ScaffoldMessenger.of(context);

  // Remove any current snackbars
  scaffoldMessengerState.removeCurrentSnackBar();

  // Show the snackbar
  scaffoldMessengerState.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ),
  );
}
