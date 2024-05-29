import 'package:delivery_tracking_app/colour_constants.dart';
import 'package:delivery_tracking_app/models/crate.dart';
import 'package:delivery_tracking_app/scan_crates_to_add.dart';
import 'package:flutter/material.dart';

class CratesListWidget extends StatefulWidget {
  final Function(String value) validateCrate; // Should return Crate or null
  final Function(List<Crate>) onSelectionChanged;
  final Function() scanCratePressed; //Should return Crate
  final Stream<List<Crate>> selectionStream;
  final List<Crate> initialCrates;

  const CratesListWidget({
    super.key,
    required this.validateCrate,
    required this.onSelectionChanged,
    required this.scanCratePressed,
    required this.selectionStream,
    this.initialCrates = const [],
  });

  @override
  State<CratesListWidget> createState() => _CratesListWidgetState();
}

class _CratesListWidgetState extends State<CratesListWidget> {
  List<Crate> crates = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    crates = [...widget.initialCrates];
    widget.selectionStream.listen((event) {
      // List<Crate> cratesToAdd = [];
      // for (var crate in event) {
      //   if (!crates.contains(crate)) {
      //     cratesToAdd.add(crate);
      //   }
      // }
      setState(() {
        crates = event;
        widget.onSelectionChanged(crates);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: const Text(
            'Crates:',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
          ),
          title: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search',
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
                onPressed: () async {
                  // Crate? response = await widget.scanCratePressed();
                  var result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (cxt) => ScanCratesForAdd(
                        selectedCrateList: crates,
                        validate: widget.validateCrate,
                      ),
                    ),
                  );
                  if (result is List) {
                    setState(() {
                      crates = [...result];
                      widget.onSelectionChanged(crates);
                    });
                  }
                },
                child: const Text('Scan Crate')),
            SizedBox(
              width: 5,
            ),
            OutlinedButton(
              onPressed: () async {
                Crate? response =
                    widget.validateCrate(searchController.value.text);
                if (response != null) {
                  bool confirmation =
                      await crateAddConfirmationModal(context: context);
                  if (confirmation) {
                    if (!crates.contains(response)) {
                      searchController.clear();
                      setState(() {
                        crates.add(response);

                        widget.onSelectionChanged(crates);
                      });
                    }
                  }
                } else {
                  await crateNotFoundModal(context: context);
                }
              },
              child: const Text('Search'),
            ),
            SizedBox(
              width: 25,
            )
          ],
        ),
        Expanded(
          child: crates.isNotEmpty
              ? ListView.builder(
                  itemCount: crates.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text("Crate: ${crates[index].crateId}"),
                      trailing: IconButton(
                        style: ButtonStyle(
                          elevation: MaterialStatePropertyAll(0),
                        ),
                        onPressed: () {
                          setState(() {
                            crates.remove(crates[index]);
                          });
                          widget.onSelectionChanged(crates);
                        },
                        icon: const Icon(Icons.close),
                        color: Colors.red,
                      ),
                    );
                  },
                )
              : const Text(
                  'Search for a crate to add or scan the crate QR code',
                  textAlign: TextAlign.center,
                ),
        ),
      ],
    );
  }
}

Future<bool> crateAddConfirmationModal({
  required BuildContext context,
}) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xff9DC183),
        title: const Text('Crate found'),
        content: const Text("Do you want to add the crate?"),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: const ButtonStyle(
                foregroundColor:
                    MaterialStatePropertyAll(ColorPalette.greenDarkest)),
          ),
          ElevatedButton(
            child: const Text('Add Crate'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: const ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll(ColorPalette.greenDarker),
                foregroundColor:
                    MaterialStatePropertyAll(ColorPalette.backgroundWhite)),
          ),
        ],
      );
    },
  );
  return result ?? false; // Handle null case by returning false
}

crateNotFoundModal({
  required BuildContext context,
}) async {
  await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xffFFCDD2),
        title: const Text('Crate not found'),
        content: const Text("The crate you searched for could not be found."),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red),
                foregroundColor:
                    MaterialStatePropertyAll(ColorPalette.backgroundWhite)),
          ),
        ],
      );
    },
  );
}
