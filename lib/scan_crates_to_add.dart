import 'package:delivery_tracking_app/confirmation_modal.dart';
import 'package:delivery_tracking_app/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_barcode_scanner/barcode_scanner.dart';
import 'package:vibration/vibration.dart';

import 'colour_constants.dart';
import 'models/crate.dart';

class ScanCratesForAdd extends StatefulWidget {
  final List<Crate> selectedCrateList;
  final Function(String crateId) validate; // Should return Crate

  const ScanCratesForAdd(
      {super.key, required this.selectedCrateList, required this.validate});

  @override
  State<ScanCratesForAdd> createState() => _ScanCratesForAddState();
}

class _ScanCratesForAddState extends State<ScanCratesForAdd> {
  List<Crate> selectedCrates = [];
  static const MethodChannel _channel = MethodChannel('vibration');

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedCrates = widget.selectedCrateList;
    });
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

  scan1(String text) async {
    String crateId = text;
    Crate? scannedCrate = widget.validate(text);
    if (scannedCrate == null) {
      scannedCrate = getCrateByIdOrNull(crateId, selectedCrates);
      if (scannedCrate == null) {
        Vibration.vibrate(
            pattern: [250, 500, 250, 500, 250, 500], amplitude: 50);

        setState(() {
          showTopSnackBar(context, 'Crate Not Found', Colors.red);
          // correctionText = 'Incorrect Crate';
          return;
        });
      } else {
        setState(() {
          Vibration.vibrate(pattern: [250, 500, 250, 500], amplitude: 50);
          //Show bread crumb
          showTopSnackBar(context, 'Crate Already Scanned', Colors.black38);
          // correctionText = 'Already Scanned';
          return;
        });
      }
    } else {
      setState(() {
        Vibration.vibrate(duration: 100, amplitude: 10);
        showTopSnackBar(context, 'Scanned Successfully', ColorPalette.green);
        selectedCrates.add(scannedCrate!);
      });
    }
  }

  scan(String text) async {
    String crateId = text;
    Crate? scannedCrate = getCrateByIdOrNull(crateId, selectedCrates);
    if (scannedCrate == null) {
      scannedCrate = widget.validate(crateId);
      if (scannedCrate == null) {
        Vibration.vibrate(
            pattern: [250, 500, 250, 500, 250, 500], amplitude: 50);

        setState(() {
          showTopSnackBar(context, 'Crate Not Found', Colors.red);
          // correctionText = 'Incorrect Crate';
          return;
        });
      } else {
        setState(() {
          Vibration.vibrate(duration: 100, amplitude: 10);
          showTopSnackBar(context, 'Scanned Successfully', ColorPalette.green);
          selectedCrates.add(scannedCrate!);
        });
      }
    } else {
      setState(() {
        Vibration.vibrate(pattern: [250, 500, 250, 500], amplitude: 50);
        //Show bread crumb
        showTopSnackBar(context, 'Crate Already Scanned', Colors.black38);
        // correctionText = 'Already Scanned';
        return;
      });
    }
  }

  Crate? getCrateByIdOrNull(String crateId, List<Crate> list) {
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
    print(widget.selectedCrateList);
    return Scaffold(
      backgroundColor: ColorPalette.backgroundWhite,
      appBar: CustomAppBar(
        title: 'Scan Crates',
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),

              SizedBox(
                height: 250,
                width: 250,
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: BarcodeScannerWidget(
                    scannerType: ScannerType.barcode,
                    onError: (e) {},
                    onBarcodeDetected: (Barcode barcode) async {
                      scan(barcode.value);
                      BarcodeScanner.startScanner();
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

              const SizedBox(
                height: 50,
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: const Border.fromBorderSide(
                      BorderSide(color: Colors.grey),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 300,
                  child: Column(
                    children: [
                      Expanded(
                          child: (selectedCrates.isNotEmpty)
                              ? ListView.builder(
                                  itemCount: selectedCrates.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                          "Crate: ${selectedCrates[index].crateId}"),
                                      trailing: IconButton(
                                        style: ButtonStyle(
                                          elevation:
                                              MaterialStatePropertyAll(0),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selectedCrates
                                                .remove(selectedCrates[index]);
                                          });
                                        },
                                        icon: const Icon(Icons.close),
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                )
                              : Center(child: Text('Scan a crate'))),
                    ],
                  ),
                ),
              )
              // Text(
              //   'Loaded Crates',
              //   style: TextStyle(fontSize: 20),
              // ),
              // Text(
              //   '${selectedCrates.length}/${widget.selectedCrateList.length}',
              //   style: const TextStyle(fontSize: 40),
              //   textAlign: TextAlign.center,
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.close), label: 'Cancel'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Ok'),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          switch (index) {
            case 0:
              var confirmation = await cancelConfirmationModal(
                  context: context,
                  header: "Are You Sure?",
                  message: "Are you sure you want to cancel?");
              if (confirmation) {
                Navigator.pop(context);
              }
            case 1:
              Navigator.pop(context, selectedCrates);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    BarcodeScanner.stopScanner();
  }
}

//  @override
//   void initState() {
//     super.initState();
//     BarcodeScanner.startScanner();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Title(color: Colors.white, child: Text('Scan Crate')),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   height: 250,
//                   width: 250,
//                   child: Container(
//                     decoration:
//                         BoxDecoration(borderRadius: BorderRadius.circular(20)),
//                     child: BarcodeScannerWidget(
//                       scannerType: ScannerType.barcode,
//                       onError: (e) {},
//                       onBarcodeDetected: (Barcode barcode) {
//                         scan(barcode.value);
//                       },
//                       onTextDetected: (text) {},
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           OutlinedButton(
//               onPressed: () {
//                 Navigator.pop(context, null);
//               },
//               child: const Text('Cancel'))
//         ],
//       ),
//     );
//   }
//
//   void scan(String value) {
//     for (var crate in widget.crateList) {
//       if (crate.crateId == value) {
//         Vibration.vibrate(duration: 500);
//         Navigator.pop(context, crate);
//         return;
//       }
//     }
//     Vibration.vibrate(pattern: [250, 500, 250, 500, 250, 500], amplitude: 255);
//     showError(
//         'An error occurred. Either that crate has already been included in another delivery batch, or a crate with that id does not exist',
//         context);
//     BarcodeScanner.startScanner();
//
//     return;
//   }

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
      behavior: SnackBarBehavior.floating, // Required for top positioning
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top, // Adjust for status bar
        left: 16.0,
        right: 16.0,
      ),
    ),
  );
}
