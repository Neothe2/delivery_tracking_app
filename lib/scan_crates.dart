import 'package:delivery_tracking_app/colour_constants.dart';
import 'package:delivery_tracking_app/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_barcode_scanner/barcode_scanner.dart';
import 'package:vibration/vibration.dart';

import 'models/crate.dart';

class ScanCratesPage extends StatefulWidget {
  final List<Crate> crateList;
  final String title;
  final Function afterScanningFinished;
  final Function(List<Crate>)? onCrateScanned;
  final List<Crate> alreadyScannedCrates;

  const ScanCratesPage(
      {super.key,
      required this.crateList,
      required this.title,
      required this.afterScanningFinished,
      this.onCrateScanned,
      this.alreadyScannedCrates = const []});

  @override
  State<ScanCratesPage> createState() => _ScanCratesPageState();
}

class _ScanCratesPageState extends State<ScanCratesPage> {
  TextEditingController crateIdTextController = TextEditingController();
  double progressBarValueForOneUnit = 0;
  List<Crate> remainingCrates = [];
  List<Crate> scannedCrates = [];
  double progressBarValue = 0;
  String correctionText = 'Scan the Crate QR';
  bool text = false;
  Color backgroundColor = ColorPalette.backgroundWhite;
  static const MethodChannel _channel = MethodChannel('vibration');

  initializeScannedCrates() {
    for (var crate in remainingCrates) {
      if (widget.alreadyScannedCrates.contains(crate.crateId)) {
        remainingCrates.remove(crate);
        scannedCrates.add(crate);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    progressBarValueForOneUnit = 1 / widget.crateList.length;
    setState(() {
      initializeRemainingCrates();
      initializeScannedCrates();
    });
  }

  void initializeRemainingCrates() {
    remainingCrates = [...widget.crateList];
  }

  static Future<void> vibrate({
    int duration = 500,
    List<int> pattern = const [],
    int repeat = -1,
    List<int> intensities = const [],
    int amplitude = -1,
  }) =>
      _channel.invokeMethod(
        "vibrate",
        {
          "duration": duration,
          "pattern": pattern,
          "repeat": repeat,
          "amplitude": amplitude,
          "intensities": intensities
        },
      );

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
        if (widget.onCrateScanned != null) {
          widget.onCrateScanned!(scannedCrates);
        }
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

  // vibrate() {
  //   _channel.invokeMethod(
  //     "vibrate",
  //     {
  //       "duration": null,
  //       "pattern": [250, 500, 250, 500, 250, 500],
  //       "repeat": null,
  //       "amplitude": 100,
  //       "intensities": null
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    print(widget.crateList);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: 'Crates',
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: text ? 258 : 252,
              child: OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(text ? 5 : 0),
                    ),
                  ),
                  backgroundColor: MaterialStatePropertyAll(ColorPalette.green),
                ),
                onPressed: () {
                  setState(() {
                    if (correctionText == 'Scan the Crate QR') {
                      correctionText = 'Enter the Crate ID';
                    } else if (correctionText == 'Enter the Crate ID') {
                      correctionText = 'Scan the Crate QR';
                    }

                    text = !text;
                  });
                },
                child: Text(
                  text ? 'Scan QR code instead' : 'Enter Text instead',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            (text)
                ? SizedBox(
                    width: 256,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 10),
                          child: TextField(
                            controller: crateIdTextController,
                            decoration:
                                const InputDecoration(labelText: "Crate ID"),
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
                    ),
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
                        onBarcodeDetected: (Barcode barcode) async {
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
                shape: const LinearBorder(),
                child: Padding(
                  padding: (text)
                      ? const EdgeInsets.only(
                          bottom: 20, left: 20, right: 20, top: 20)
                      : const EdgeInsets.all(20.0),
                  child: Text(
                    correctionText,
                    style: const TextStyle(
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            (text)
                ? const SizedBox(
                    height: 10,
                  )
                : const SizedBox(
                    height: 50,
                  ),
            Text(
              'Loaded Crates',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '${scannedCrates.length}/${widget.crateList.length}',
              style: const TextStyle(fontSize: 40),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: (remainingCrates.isNotEmpty)
                  ? Container(
                      decoration: BoxDecoration(
                          border: const Border.fromBorderSide(
                            BorderSide(
                              color: ColorPalette.greenDarkest,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(15)),
                      child: LinearProgressIndicator(
                        value:
                            progressBarValueForOneUnit * scannedCrates.length,
                        minHeight: 40,
                        borderRadius: BorderRadius.circular(15),
                        backgroundColor: ColorPalette.cream,
                      ),
                    )
                  : SizedBox(
                      width: 100000000,
                      height: 40,
                      child: OutlinedButton(
                        style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)))),
                        onPressed: () {
                          widget.afterScanningFinished();
                        },
                        child: const Text('Finish'),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
