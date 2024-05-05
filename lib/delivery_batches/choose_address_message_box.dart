import 'package:delivery_tracking_app/models/address.dart';
import 'package:flutter/material.dart';

class ChooseAddressMessageBox extends StatefulWidget {
  final Function(Address) onSelectionChanged;
  final List<Address> addressList;
  final Address? initialAddress;

  const ChooseAddressMessageBox(
      {super.key,
      required this.onSelectionChanged,
      required this.addressList,
      this.initialAddress});

  @override
  State<ChooseAddressMessageBox> createState() =>
      _ChooseAddressMessageBoxState();
}

class _ChooseAddressMessageBoxState extends State<ChooseAddressMessageBox> {
  List<Address> addressList = [];
  Address? initialAddress;
  Address? selectedAddress;

  @override
  void initState() {
    super.initState();
    addressList = widget.addressList;
    if (widget.initialAddress != null) {
      for (var address in addressList) {
        if (address.id == widget.initialAddress!.id) {
          initialAddress = address;
          selectedAddress = address;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: const Border.fromBorderSide(
          BorderSide(color: Colors.grey),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.builder(
        itemCount: addressList.length,
        itemBuilder: (context, index) {
          final address = addressList[index];
          return RadioListTile<dynamic>(
            // Use the same type as 'value'
            title: Text(
              address.value,
              style: TextStyle(color: Colors.black87),
            ),
            value: address.value,
            // Set the value from the filtered address
            groupValue: selectedAddress,
            onChanged: (dynamic value) {
              setState(() {
                selectedAddress = value;
                widget.onSelectionChanged(selectedAddress!);
              });
            },
            // Check if the current address's value matches the selectedValue
            selected:
                selectedAddress == address, // Set selected based on comparison
          );
        },
      ),
    );
  }
}
