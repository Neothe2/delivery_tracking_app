// main.dart
import 'package:flutter/material.dart';

import 'login_page.dart'; // Make sure to import login_page.dart here

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // primarySwatch: Colors.grey,
          ),
      home: LoginPage(), // Replace MyHomePage with LoginPage
    );
  }
}
