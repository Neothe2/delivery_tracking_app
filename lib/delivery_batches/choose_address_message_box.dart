import 'package:delivery_tracking_app/colour_constants.dart';
import 'package:flutter/material.dart';

import '../models/address.dart';

class ChooseAddressMessageBox extends StatefulWidget {
  final List<Address> items;
  final List<dynamic> preSelectedValues;
  final Function(Address) onSelectionChanged;

  ChooseAddressMessageBox({
    Key? key,
    required this.items,
    required this.onSelectionChanged,
    this.preSelectedValues = const [],
  }) : super(key: key);

  @override
  _ChooseAddressMessageBoxState createState() =>
      _ChooseAddressMessageBoxState();
}

class _ChooseAddressMessageBoxState extends State<ChooseAddressMessageBox> {
  List<Address> allItems = [];
  List<dynamic> selectedValues = [];
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValues = [...widget.preSelectedValues];
    selectedValue = widget.preSelectedValues.isNotEmpty
        ? widget.preSelectedValues[0]
        : null;
    allItems = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            child: ListView.builder(
          itemCount: allItems.length,
          itemBuilder: (context, index) {
            final item = allItems[index];
            return RadioListTile<dynamic>(
              // Use the same type as 'value'
              title: Text(
                item.value,
                style: TextStyle(color: Colors.black87),
              ),
              value: item,
              // Set the value from the filtered item
              groupValue: selectedValue,
              onChanged: (dynamic value) {
                setState(() {
                  selectedValue = value;
                  widget.onSelectionChanged(selectedValue);
                });
              },
              // Check if the current item's value matches the selectedValue
              selected:
                  selectedValue == item, // Set selected based on comparison
            );
          },
        )),
        OutlinedButton(
            style: selectedValue == null
                ? ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Color(0xAA386641)),
                    foregroundColor:
                        MaterialStatePropertyAll(ColorPalette.backgroundWhite))
                : null,
            onPressed: selectedValue != null
                ? () {
                    widget.onSelectionChanged(selectedValue);
                  }
                : null,
            child: const Text("Choose Address"))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// import 'package:delivery_tracking_app/models/address.dart';
// import 'package:flutter/material.dart';
//
// class ChooseAddressMessageBox extends StatefulWidget {
//   final Function(Address) onSelectionChanged;
//   final List<Address> addressList;
//   final Address? initialAddress;
//
//   const ChooseAddressMessageBox(
//       {super.key,
//       required this.onSelectionChanged,
//       required this.addressList,
//       this.initialAddress});
//
//   @override
//   State<ChooseAddressMessageBox> createState() =>
//       _ChooseAddressMessageBoxState();
// }
//
// class _ChooseAddressMessageBoxState extends State<ChooseAddressMessageBox> {
//   List<Address> addressList = [];
//   Address? initialAddress;
//   Address? selectedAddress;
//
//   @override
//   void initState() {
//     super.initState();
//     addressList = widget.addressList;
//     if (widget.initialAddress != null) {
//       for (var address in addressList) {
//         if (address.id == widget.initialAddress!.id) {
//           initialAddress = address;
//           selectedAddress = address;
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: const Border.fromBorderSide(
//           BorderSide(color: Colors.grey),
//         ),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: addressList.length,
//               itemBuilder: (context, index) {
//                 final address = addressList[index];
//                 return RadioListTile<dynamic>(
//                   // Use the same type as 'value'
//                   title: Text(
//                     address.value,
//                     style: TextStyle(color: Colors.black87),
//                   ),
//                   value: address.value,
//                   // Set the value from the filtered address
//                   groupValue: selectedAddress,
//                   onChanged: (dynamic value) {
//                     setState(() {
//                       selectedAddress = value;
//                       widget.onSelectionChanged(selectedAddress!);
//                     });
//                   },
//                   // Check if the current address's value matches the selectedValue
//                   selected: selectedAddress ==
//                       address, // Set selected based on comparison
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
