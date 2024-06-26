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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Visibility(
            visible: (selectedCrates.isEmpty && addClicked),
            child: const Text("Please select at least one crate",
                style: TextStyle(color: Colors.red)),
          ),
        ),
        SizedBox(
          width: 300,
          child: OutlinedButton(
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
            child: const Text('Select Crates'),
          ),
        ),
      ],
    );
  }
}
