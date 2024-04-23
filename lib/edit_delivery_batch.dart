import 'dart:convert';

import 'package:delivery_tracking_app/delivery_batches.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/searchable_list.dart';
import 'package:flutter/material.dart';

import 'add_delivery_batch.dart';

class EditDeliveryBatch extends StatefulWidget {
  final DeliveryBatch deliveryBatch;

  const EditDeliveryBatch({super.key, required this.deliveryBatch});

  @override
  State<EditDeliveryBatch> createState() => _EditDeliveryBatchState();
}

class _EditDeliveryBatchState extends State<EditDeliveryBatch> {
  List<Crate> crateList = [];
  List<Customer> customerList = [];
  bool cratesLoaded = false;
  List<String> selectedCrateIds = [];
  List<Crate> selectedCrates = [];
  int selectedCustomerId = -1;
  late Customer selectedCustomer;
  TextEditingController addressFieldController = TextEditingController();
  Address? selectedAddress;
  List<DropdownMenuItem<Address>> addressItems = [];
  bool customersLoaded = false;

  @override
  void initState() {
    super.initState();
    selectedCustomer = widget.deliveryBatch.customer;
    selectedCrates = widget.deliveryBatch.crates;
    for (var address in selectedCustomer.addresses) {
      if (address.id == widget.deliveryBatch.address.id) {
        selectedAddress = address;
      }
    }
    getCrates();
  }

  void getCrates() async {
    var response =
        await HttpService().get('app/crates/get_unallocated_crates/');
    var customerResponse = await HttpService().get('app/customers/');

    for (var crate in widget.deliveryBatch.crates) {
      crateList.add(crate);
    }

    for (var crateJson in jsonDecode(response.body)) {
      crateList.add(
        parseCrate(crateJson),
      );
    }

    for (var customerJson in jsonDecode(customerResponse.body)) {
      customerList.add(parseCustomer(customerJson));
    }

    addressFieldController.text = widget.deliveryBatch.address.value;
    selectedCustomerId = widget.deliveryBatch.customer.id;
    selectedCrateIds =
        widget.deliveryBatch.crates.map((e) => e.crateId).toList();

    setState(() {
      cratesLoaded = true;

      addressItems = customerList
          .firstWhere((customer) => customer.id == selectedCustomerId)
          .getAddressesAsDropdownItems();
      customersLoaded = true;
    });
  }

  Crate parseCrate(Map<String, dynamic> crate) {
    return Crate(crate['crate_id']);
  }

  @override
  Widget build(BuildContext context) {
    print(crateList);
    List<MapEntry<String, dynamic>> selectableListViewList = crateList
        .map(
          (e) => MapEntry("Id: ${e.crateId}", e),
        )
        .toList();

    List<MapEntry<String, dynamic>> selectableCustomerListViewList =
        customerList
            .map(
              (e) => MapEntry(e.name, e),
            )
            .toList();

    List<Crate> preselectedCrates = [];
    for (var selectedCrate in widget.deliveryBatch.crates) {
      for (var crate in crateList) {
        if (crate.crateId == selectedCrate.crateId) {
          preselectedCrates.add(crate);
        }
      }
    }

    Customer? preselectedCustomer;
    for (var customer in customerList) {
      if (customer.id == widget.deliveryBatch.customer.id) {
        preselectedCustomer = customer;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Delivery Batch'),
      ),
      resizeToAvoidBottomInset: true,
      body: cratesLoaded
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
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
                            child: SelectableListView(
                              checkboxes: true,
                              preSelectedValues: preselectedCrates,
                              items: selectableListViewList,
                              onSelectionChanged:
                                  (List<dynamic> selectionChanged) {
                                selectedCrates = selectionChanged
                                    .map((e) => (e as Crate))
                                    .toList();
                                selectedCrateIds = selectionChanged.map((e) {
                                  return (e.crateId as String);
                                }).toList();
                              },
                              title: 'Crates',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
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
                            child: SelectableListView(
                              checkboxes: true,
                              radioButtons: true,
                              preSelectedValues: preselectedCustomer != null
                                  ? [preselectedCustomer]
                                  : [],
                              items: selectableCustomerListViewList,
                              onSelectionChanged:
                                  (List<dynamic> selectionChanged) {
                                selectedCustomer = (selectionChanged.isNotEmpty)
                                    ? selectionChanged[0]
                                    : null;
                                selectedCustomerId =
                                    (selectionChanged.isNotEmpty)
                                        ? selectionChanged[0].id
                                        : -1;

                                setState(() {
                                  selectedAddress = null;
                                });
                              },
                              title: 'Customer',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (customersLoaded)
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: const Border.fromBorderSide(
                            BorderSide(color: Colors.grey),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<Address>(
                            isExpanded: true,
                            hint: Text("Select Delivery Address"),
                            value: selectedAddress,
                            items: (selectedCustomerId != -1)
                                ? addressItems
                                : [
                                    DropdownMenuItem(
                                        value: null,
                                        child: Text("Select customer first"))
                                  ],
                            onChanged: (value) {
                              setState(() {
                                selectedAddress = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  // Padding(
                  //   padding: const EdgeInsets.all(10.10),
                  //   child: Container(
                  //     alignment: Alignment.bottomCenter,
                  //     child: OutlinedButton(
                  //       onPressed: () async {
                  //         if (selectedCustomerId != -1 &&
                  //             selectedCrateIds.isNotEmpty) {
                  //           var response = await HttpService().create(
                  //               'app/delivery_batches/', {
                  //             "crates": selectedCrateIds,
                  //             "customer": selectedCustomerId
                  //           });
                  //           Navigator.pop(context, true);
                  //         }
                  //         // DeliveryBatch deliveryBatch =
                  //         //     parseDeliveryBatch(response.body);
                  //       },
                  //       child: Text('Add Delivery Batch'),
                  //       style: ButtonStyle(
                  //         shape: MaterialStateProperty.all(
                  //           RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10.0),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            )
          : const Text('Loading...'),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.clear), label: 'Cancel'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Confirm')
        ],
        currentIndex: 1,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          switch (index) {
            case 1:
              if (selectedCustomerId != -1 &&
                  selectedCrateIds.isNotEmpty &&
                  selectedAddress != null) {
                var response = await HttpService().update(
                    'app/delivery_batches/${widget.deliveryBatch.id}/', {
                  "crates": selectedCrateIds,
                  "customer": selectedCustomerId,
                  "delivery_address": selectedAddress!.id
                });
                print(jsonDecode(response.body));
                widget.deliveryBatch.crates = selectedCrates;
                widget.deliveryBatch.customer = selectedCustomer;
                widget.deliveryBatch.address = selectedAddress!;
                Navigator.pop(context, widget.deliveryBatch);
              }

            case 0:
              Navigator.pop(context);
          }
        },
      ),
    );
  }

  Customer parseCustomer(Map<String, dynamic> customerJson) {
    return Customer(
        customerJson['id'],
        customerJson['name'],
        customerJson['phone_number'],
        parseAddresses(customerJson['addresses']));
  }

  List<Address> parseAddresses(List<dynamic> addressJsonList) {
    List<Address> returnList = [];
    for (var address in addressJsonList) {
      returnList.add(parseAddress(address));
    }
    return returnList;
  }

  Address parseAddress(Map<String, dynamic> addressJson) {
    return Address(addressJson['id'], addressJson['value']);
  }
}

// class Customer {
//   int id;
//   String name;
//   String contactDetails;
//
//   Customer(this.id, this.name, this.contactDetails);
// }
