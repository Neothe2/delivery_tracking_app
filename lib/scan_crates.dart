import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_barcode_scanner/barcode_scanner.dart';

import 'delivery_batches.dart';

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

  @override
  void initState() {
    super.initState();
    progressBarValueForOneUnit = 1 / widget.crateList.length;
    setState(() {
      remainingCrates = [...widget.crateList];
    });
  }

  scan(String text) {
    String crateId = text;
    crateIdTextController.text = '';
    Crate? scannedCrate = getCrateByIdOrNull(crateId, remainingCrates);
    if (scannedCrate == null) {
      scannedCrate = getCrateByIdOrNull(crateId, scannedCrates);
      if (scannedCrate == null) {
        setState(() {
          HapticFeedback.heavyImpact();
          correctionText = 'Incorrect Crate';
          return;
        });
      } else {
        setState(() {
          HapticFeedback.heavyImpact();
          correctionText = 'Already Scanned';
          return;
        });
      }
    } else {
      setState(() {
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
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  )
                : SizedBox(
                    height: 250,
                    width: 250,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)),
                      child: BarcodeScannerWidget(
                        onError: (e) {},
                        onBarcodeDetected: (Barcode barcode) {
                          HapticFeedback.vibrate();
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
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    correctionText,
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(
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
