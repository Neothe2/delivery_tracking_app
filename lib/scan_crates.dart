import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    progressBarValueForOneUnit = 1 / widget.crateList.length;
    setState(() {
      remainingCrates = [...widget.crateList];
    });
  }

  scan() {
    String crateId = crateIdTextController.value.text;
    crateIdTextController.text = '';
    Crate? scannedCrate = getCrateByIdOrNull(crateId, remainingCrates);
    if (scannedCrate == null) {
      scannedCrate = getCrateByIdOrNull(crateId, scannedCrates);
      if (scannedCrate == null) {
        setState(() {
          correctionText = 'Incorrect Crate';
          return;
        });
      } else {
        setState(() {
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 70.0, vertical: 10),
              child: TextField(
                controller: crateIdTextController,
                decoration: InputDecoration(labelText: "Crate ID"),
              ),
            ),
            OutlinedButton(
                onPressed: () {
                  scan();
                },
                child: const Text('Enter')),
            const SizedBox(
              height: 50,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  correctionText,
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              '${scannedCrates.length}/${widget.crateList.length}',
              style: TextStyle(fontSize: 40),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: (remainingCrates.isNotEmpty)
                  ? LinearProgressIndicator(
                      value: progressBarValueForOneUnit * scannedCrates.length,
                      minHeight: 50,
                      borderRadius: BorderRadius.circular(15),
                    )
                  : OutlinedButton(
                      onPressed: () {
                        widget.afterScanningFinished();
                      },
                      child: const Text('Finish')),
            )
          ],
        ),
      ),
    );
  }
}
