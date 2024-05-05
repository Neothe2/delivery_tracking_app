import 'package:delivery_tracking_app/colour_constants.dart';
import 'package:delivery_tracking_app/custom_bottom_bar.dart';
import 'package:delivery_tracking_app/delivery_batches/choose_address_message_box.dart';
import 'package:flutter/material.dart';

import '../models/address.dart';
import '../models/customer.dart';

class SelectCustomerPage extends StatefulWidget {
  final List<Customer> customerList;
  final Customer? initialCustomer;

  const SelectCustomerPage(
      {super.key, required this.customerList, this.initialCustomer});

  @override
  State<SelectCustomerPage> createState() => _SelectCustomerPageState();
}

class _SelectCustomerPageState extends State<SelectCustomerPage> {
  Customer? selectedCustomer;
  TextEditingController customerDropDownController = TextEditingController();
  Address? selectedAddress;
  bool isCustomerSelected = false;
  List<Customer> customerList = [];
  Customer? initialCustomer;
  bool okClicked = false;

  @override
  void initState() {
    super.initState();
    customerList = widget.customerList;
    if (widget.initialCustomer != null) {
      for (var customer in customerList) {
        if (customer.id == widget.initialCustomer!.id) {
          initialCustomer = customer;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuEntry<Customer>> selectableCustomerListViewList =
        customerList
            .map(
              (e) => DropdownMenuEntry(value: e, label: e.name),
            )
            .toList();
    return Scaffold(
      appBar: AppBar(
        title: Title(
          color: ColorPalette.greenVibrant,
          child: const Text('Select Customer'),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 500,
            ),
            Column(
              children: [
                Visibility(
                  visible: (!isCustomerSelected && okClicked),
                  child: Text("Please select a customer",
                      style: TextStyle(color: Colors.red)),
                ),
                DropdownMenu(
                  width: 250,
                  initialSelection: initialCustomer,
                  enableSearch: true,
                  enableFilter: true,
                  controller: customerDropDownController,
                  requestFocusOnTap: true,
                  dropdownMenuEntries: selectableCustomerListViewList,
                  onSelected: (Customer? customer) {
                    selectedCustomer = (customer != null) ? customer : null;

                    setState(() {
                      isCustomerSelected = customer != null;
                      selectedAddress = null;
                    });
                  },
                ),
                if (selectedCustomer != null)
                  Row(
                    children: [
                      ChooseAddressMessageBox(
                          onSelectionChanged: (value) {
                            selectedAddress = value;
                            setState(() {
                              isCustomerSelected = selectedAddress != null;
                            });
                          },
                          addressList: selectedCustomer!.addresses),
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
          primaryButtonLabel: 'Ok',
          onPrimaryButtonPressed: () {
            if (isCustomerSelected) {
              Navigator.pop(context, [selectedCustomer]);
            }
            setState(() {
              okClicked = true;
            });
          }),
    );
  }
}
