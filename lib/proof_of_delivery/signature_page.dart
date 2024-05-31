import 'dart:typed_data';

import 'package:delivery_tracking_app/colour_constants.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  late SignatureController signatureController;

  @override
  void initState() {
    signatureController = SignatureController(
      penColor: ColorPalette.backgroundWhite,
      penStrokeWidth: 5,
    );
    super.initState();
  }

  @override
  void dispose() {
    signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff020202),
      appBar: AppBar(
        backgroundColor: Color(0xff020202),
        foregroundColor: ColorPalette.backgroundWhite,
        title: Title(
          color: Colors.white,
          child: Text(
            'Sign',
            style: TextStyle(color: ColorPalette.backgroundWhite),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Signature(
              controller: signatureController,
              backgroundColor: Color(0xff020202),
            ),
          ),
          buildButtons(context)
        ],
      ),
    );
  }

  buildButtons(BuildContext context) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [buildClear(), buildCheck(context)],
        ),
      );

  buildCheck(BuildContext context) => IconButton(
        onPressed: () async {
          if (signatureController.isNotEmpty) {
            final signature = await exportSignature();
          }
        },
        iconSize: 36,
        icon: const Icon(
          Icons.check,
          color: Colors.green,
        ),
      );

  buildClear() => IconButton(
        onPressed: () {
          signatureController.clear();
        },
        iconSize: 36,
        icon: const Icon(
          Icons.clear,
          color: Colors.red,
        ),
      );

  Future<Uint8List> exportSignature() async {
    final exportController = SignatureController(
      penStrokeWidth: 2,
      penColor: Color(0xff020202),
      exportBackgroundColor: ColorPalette.backgroundWhite,
      points: signatureController.points,
    );
    final signature = await exportController.toPngBytes();
    exportController.dispose();
    return signature!;
  }
}
