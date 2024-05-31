import 'package:delivery_tracking_app/delivery_batches/choose_address_message_box.dart';
import 'package:flutter/material.dart';

import '../colour_constants.dart';
import '../custom_bottom_bar.dart';
import '../models/address.dart';
import '../models/customer.dart';

class SelectCustomerPage extends StatefulWidget {
  final List<Customer> customerList;
  final Customer? initialCustomer;
  final Address? selectedAddress;

  const SelectCustomerPage(
      {super.key,
      required this.customerList,
      this.initialCustomer,
      this.selectedAddress});

  @override
  State<SelectCustomerPage> createState() => _SelectCustomerPageState();
}

class _SelectCustomerPageState extends State<SelectCustomerPage> {
  Customer? selectedCustomer;
  TextEditingController customerDropDownController = TextEditingController();
  Address? selectedAddress;
  bool isCustomerSelected = false;
  bool isAddressSelected = false;
  List<Customer> customerList = [];
  Customer? initialCustomer;
  bool okClicked = false;
  bool showAddressMessageBox = false;

  @override
  void initState() {
    super.initState();
    customerList = widget.customerList;
    if (widget.initialCustomer != null) {
      for (var customer in customerList) {
        if (customer.id == widget.initialCustomer!.id) {
          initialCustomer = customer;
          selectedCustomer = initialCustomer;

          if (widget.selectedAddress != null) {
            for (var address in selectedCustomer!.addresses) {
              if (address.id == widget.selectedAddress!.id) {
                selectedAddress = widget.selectedAddress;
              }
            }
          }
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
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Visibility(
                  visible: (selectedCustomer == null && okClicked),
                  child: Text("Please select a customer",
                      style: TextStyle(color: Colors.red)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownMenu(
                  width: MediaQuery.sizeOf(context).width - 20,
                  initialSelection: initialCustomer,
                  enableSearch: true,
                  enableFilter: true,
                  controller: customerDropDownController,
                  requestFocusOnTap: true,
                  dropdownMenuEntries: selectableCustomerListViewList,
                  label: const Text("Select Customer"),
                  onSelected: (Customer? customer) {
                    selectedCustomer = (customer != null) ? customer : null;

                    setState(() {
                      isCustomerSelected = selectedCustomer != null;
                      if (selectedCustomer != null &&
                          selectedCustomer!.addresses.length > 1) {
                        selectedAddress = null;
                        showAddressMessageBox = true;
                      } else if (selectedCustomer != null) {
                        selectedAddress = selectedCustomer!.addresses[0];
                        showAddressMessageBox = false;
                      }
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Visibility(
                  visible: (selectedCustomer != null &&
                      selectedAddress == null &&
                      okClicked),
                  child: Text("Please select an Address",
                      style: TextStyle(color: Colors.red)),
                ),
              ),
              if (selectedCustomer != null)
                (showAddressMessageBox)
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          height: 450,
                          decoration: BoxDecoration(
                            border: const Border.fromBorderSide(
                              BorderSide(color: Colors.grey),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ChooseAddressMessageBox(
                              onSelectionChanged: (value) {
                                selectedAddress = value;
                                setState(() {
                                  isAddressSelected = selectedAddress != null;
                                  showAddressMessageBox = false;
                                });
                              },
                              preSelectedValues: [selectedAddress],
                              items: selectedCustomer!.addresses),
                        ),
                      )
                    : (selectedAddress != null)
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text(
                                      'Address: ${selectedAddress!.value}',
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                if (selectedCustomer!.addresses.length > 1)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedAddress = null;
                                          showAddressMessageBox = true;
                                        });
                                      },
                                      child: const Text(
                                        ("Choose another address"),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          )
                        : const Text('An unexpected issue occurred.')
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(
          primaryButtonLabel: 'Ok',
          onPrimaryButtonPressed: () {
            if (selectedCustomer != null && selectedAddress != null) {
              Navigator.pop(context, [selectedCustomer, selectedAddress]);
            }
            setState(() {
              okClicked = true;
            });
          }),
    );
  }
}
