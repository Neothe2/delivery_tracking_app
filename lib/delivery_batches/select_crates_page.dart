import 'dart:async';

import 'package:delivery_tracking_app/colour_constants.dart';
import 'package:delivery_tracking_app/custom_app_bar.dart';
import 'package:delivery_tracking_app/custom_bottom_bar.dart';
import 'package:flutter/material.dart';

import '../crates_list_widget.dart';
import '../models/crate.dart';

class SelectCratesPage extends StatefulWidget {
  final List<Crate> initialCrates;
  final List<Crate> crateList;

  const SelectCratesPage(
      {super.key, this.initialCrates = const [], required this.crateList});

  @override
  State<SelectCratesPage> createState() => _SelectCratesPageState();
}

class _SelectCratesPageState extends State<SelectCratesPage> {
  bool areCratesSelected = false;
  bool okClicked = false;
  StreamController<List<Crate>> selectionStreamController =
      StreamController<List<Crate>>();
  List<Crate> crateList = [];
  List<Crate> selectedCrates = [];

  @override
  void initState() {
    super.initState();
    crateList = widget.crateList;
    if (widget.initialCrates.isNotEmpty) {
      for (var initialCrate in widget.initialCrates) {
        for (var crate in crateList) {
          if (initialCrate.crateId == crate.crateId) {
            selectedCrates.add(crate);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Select Crates',
      ),

      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Visibility(
              visible: (!areCratesSelected && okClicked),
              child: const Text(
                "Please select at least one crate",
                style: TextStyle(color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: const Border.fromBorderSide(
                      BorderSide(color: Colors.grey),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        height: 400,
                        child: CratesListWidget(
                            initialCrates: widget.initialCrates,
                            selectionStream: selectionStreamController.stream,
                            validateCrate: (String crateId) {
                              for (var crate in crateList) {
                                if (crate.crateId == crateId) {
                                  return crate;
                                }
                              }
                              return null;
                            },
                            onSelectionChanged: (List<Crate> crateList) {
                              // selectedCrateIds =
                              //     crateList.map((e) => e.crateId).toList();
                              selectedCrates = crateList;

                              setState(() {
                                areCratesSelected = crateList.isNotEmpty;
                              });
                            },
                            scanCratePressed: () async {
                              // var result = await Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (cxt) => ScanCratesForAdd(
                              //       selectedCrateList: selectedCrates,
                              //       validate: (String crateId) {
                              //         for (var crate in crateList) {
                              //           if (crate.crateId == crateId) {
                              //             return crate;
                              //           }
                              //         }
                              //         return null;
                              //       },
                              //     ),
                              //   ),
                              // );

                              // if (result is List<Crate>) {
                              // selectionStreamController.add(result);
                              // selectedCrateIds.add(result.crateId);
                              // return result;
                              // }
                            }),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        primaryButtonLabel: 'Ok',
        onPrimaryButtonPressed: () {
          Navigator.pop(context, selectedCrates);
        },
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.close), label: 'Cancel'),
      //     BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Ok'),
      //   ],
      //   currentIndex: 1,
      //   selectedItemColor: Colors.green,
      //   unselectedItemColor: Colors.grey,
      //   onTap: (index) async {
      //     switch (index) {
      //       case 0:
      //         var confirmation = await cancelConfirmationModal(
      //             context: context,
      //             header: "Are You Sure?",
      //             message: "Are you sure you want to cancel?");
      //         if (confirmation) {
      //           Navigator.pop(context);
      //         }
      //       case 1:
      //         Navigator.pop(context, selectedCrates);
      //     }
      //   },
      // ),
    );
  }
}
