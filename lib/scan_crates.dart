import 'package:flutter/material.dart';
import 'package:native_barcode_scanner/barcode_scanner.dart';
import 'package:vibration/vibration.dart';

import 'delivery_batches/delivery_batches.dart';

class ScanCratesPage extends StatefulWidget {
  final List<Crate> crateList;
  final String title;
  final Function afterScanningFinished;

  const ScanCratesPage(
      {super.key,
      required this.crateList,
      required this.title,
      required this.afterScanningFinished});

  @override
  State<ScanCratesPage> createState() => _ScanCratesPageState();
}

class _ScanCratesPageState extends State<ScanCratesPage> {
  TextEditingController crateIdTextController = TextEditingController();
  double progressBarValueForOneUnit = 0;
  List<Crate> remainingCrates = [];
  List<Crate> scannedCrates = [];
  double progressBarValue = 0;
  String correctionText = 'Enter the Crate ID';
  bool text = false;

  vibrateBad() async {
    // await Future.delayed(const Duration(milliseconds: 100));
    // Vibration.vibrate(duration: 500, amplitude: 255);
    // await Future.delayed(const Duration(milliseconds: 100));
    // Vibration.vibrate(duration: 500, amplitude: 255);
  }

  @override
  void initState() {
    super.initState();
    vibrateBad();
    progressBarValueForOneUnit = 1 / widget.crateList.length;
    setState(() {
      remainingCrates = [...widget.crateList];
    });
  }

  scan(String text) async {
    String crateId = text;

    crateIdTextController.text = '';
    Crate? scannedCrate = getCrateByIdOrNull(crateId, remainingCrates);
    if (scannedCrate == null) {
      scannedCrate = getCrateByIdOrNull(crateId, scannedCrates);
      if (scannedCrate == null) {
        Vibration.vibrate(
            pattern: [250, 500, 250, 500, 250, 500], amplitude: 50);
        setState(() {
          correctionText = 'Incorrect Crate';
          return;
        });
      } else {
        setState(() {
          Vibration.vibrate(pattern: [250, 500, 250, 500], amplitude: 50);

          correctionText = 'Already Scanned';
          return;
        });
      }
    } else {
      setState(() {
        Vibration.vibrate(duration: 100, amplitude: 10);
        correctionText = 'Correct';
        remainingCrates.remove(scannedCrate!);
        scannedCrates.add(scannedCrate);
        progressBarValue = progressBarValueForOneUnit * remainingCrates.length;
      });
    }
  }

  Crate? getCrateByIdOrNull(String crateId, List<Crate> list) {
    Crate? returnCrate;
    for (var crate in list) {
      if (crate.crateId == crateId) {
        return crate;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.crateList);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crates'),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            OutlinedButton(
                onPressed: () {
                  setState(() {
                    text = !text;
                  });
                },
                child:
                    Text(text ? 'Scan QR code instead' : 'Enter Text instead')),
            (text)
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 70.0, vertical: 10),
                        child: TextField(
                          controller: crateIdTextController,
                          decoration: InputDecoration(labelText: "Crate ID"),
                        ),
                      ),
                      OutlinedButton(
                          onPressed: () {
                            scan(crateIdTextController.value.text);
                          },
                          child: const Text('Enter')),
                      // const SizedBox(
                      //   height: 50,
                      // ),
                    ],
                  )
                : SizedBox(
                    height: 250,
                    width: 250,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)),
                      child: BarcodeScannerWidget(
                        scannerType: ScannerType.barcode,
                        onError: (e) {},
                        onBarcodeDetected: (Barcode barcode) {
                          scan(barcode.value);
                          if (remainingCrates.isNotEmpty) {
                            BarcodeScanner.startScanner();
                          }
                        },
                        onTextDetected: (text) {},
                      ),
                    ),
                  ),
            // OutlinedButton(
            //     onPressed: () {
            //       scan(crateIdTextController.value.text);
            //     },
            //     child: const Text('Enter')),

            SizedBox(
              width: 256,
              child: Card(
                shape: LinearBorder(),
                child: Padding(
                  padding: (text)
                      ? const EdgeInsets.only(
                          bottom: 20, left: 20, right: 20, top: 20)
                      : const EdgeInsets.all(20.0),
                  child: Text(
                    correctionText,
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            (text)
                ? SizedBox(
                    height: 10,
                  )
                : SizedBox(
                    height: 50,
                  ),
            Text(
              '${scannedCrates.length}/${widget.crateList.length}',
              style: TextStyle(fontSize: 40),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: (remainingCrates.isNotEmpty)
                  ? LinearProgressIndicator(
                      value: progressBarValueForOneUnit * scannedCrates.length,
                      minHeight: 50,
                      borderRadius: BorderRadius.circular(15),
                    )
                  : SizedBox(
                      width: 100000000,
                      child: OutlinedButton(
                          onPressed: () {
                            widget.afterScanningFinished();
                          },
                          child: const Text('Finish')),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
