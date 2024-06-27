import 'package:delivery_tracking_app/delivery_batches/select_crates_page.dart';
import 'package:delivery_tracking_app/models/crate.dart';
import 'package:flutter/material.dart';

class SelectCratesButton extends StatelessWidget {
  final List<Crate> crateList;
  final List<Crate> selectedCrates;
  final bool addClicked;
  final Function(List<Crate>) onCratesSelected;

  const SelectCratesButton({
    Key? key,
    required this.crateList,
    required this.selectedCrates,
    required this.addClicked,
    required this.onCratesSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Visibility(
            visible: (selectedCrates.isEmpty && addClicked),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                "Please select at least one crate",
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          OutlinedButton(
            onPressed: () async {
              List<Crate>? response = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (cxt) => SelectCratesPage(
                    crateList: crateList,
                    initialCrates: selectedCrates,
                  ),
                ),
              );

              if (response != null) {
                onCratesSelected(response);
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              shadowColor: Colors.black.withOpacity(0.1),
              elevation: 5,
            ),
            child: const Text(
              'Select Crates',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
