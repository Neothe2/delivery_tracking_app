import 'package:delivery_tracking_app/error_modal.dart';
import 'package:flutter/material.dart';
import 'package:native_barcode_scanner/barcode_scanner.dart';
import 'package:vibration/vibration.dart';

import 'delivery_batches/delivery_batches.dart';

class ScanIndividualCrate extends StatefulWidget {
  final List<Crate> crateList;

  const ScanIndividualCrate({super.key, required this.crateList});

  @override
  State<ScanIndividualCrate> createState() => _ScanIndividualCrateState();
}

class _ScanIndividualCrateState extends State<ScanIndividualCrate> {
  @override
  void initState() {
    super.initState();
    BarcodeScanner.startScanner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Title(color: Colors.white, child: Text('Scan Crate')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 250,
                  width: 250,
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: BarcodeScannerWidget(
                      scannerType: ScannerType.barcode,
                      onError: (e) {},
                      onBarcodeDetected: (Barcode barcode) {
                        scan(barcode.value);
                      },
                      onTextDetected: (text) {},
                    ),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text('Cancel'))
        ],
      ),
    );
  }

  void scan(String value) {
    for (var crate in widget.crateList) {
      if (crate.crateId == value) {
        Vibration.vibrate(duration: 500);
        Navigator.pop(context, crate);
        return;
      }
    }
    Vibration.vibrate(pattern: [250, 500, 250, 500, 250, 500], amplitude: 255);
    showError(
        'An error occurred. Either that crate has already been included in another delivery batch, or a crate with that id does not exist',
        context);
    BarcodeScanner.startScanner();

    return;
  }
}
