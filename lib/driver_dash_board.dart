// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class DriverDashBoard extends StatefulWidget {
  const DriverDashBoard({super.key});

  @override
  State<DriverDashBoard> createState() => _DriverDashBoardState();
}

class _DriverDashBoardState extends State<DriverDashBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            color: Colors.white,
            shadowColor: Colors.black12,
            child: Text('Hi'),
          )
        ],
      ),
    );
  }
}
