import 'dart:convert';

import 'package:delivery_tracking_app/delivery_batches.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/scan_invividual_crate.dart';
import 'package:delivery_tracking_app/searchable_list.dart';
import 'package:flutter/material.dart';

import 'error_modal.dart';

class AddDeliveryBatch extends StatefulWidget {
  const AddDeliveryBatch({super.key});

  @override
  State<AddDeliveryBatch> createState() => _AddDeliveryBatchState();
}

class _AddDeliveryBatchState extends State<AddDeliveryBatch> {
  List<Crate> crateList = [];
  List<Customer> customerList = [];
  bool cratesLoaded = false;
  List<String> selectedCrateIds = [];
  int selectedCustomerId = -1;
  TextEditingController addressFieldController = TextEditingController();
  SelectableListView? selectableListView;
  Address? selectedAddress;
  bool isCustomerSelected = false;
  bool areCratesSelected = false;
  bool isAddressSelected = false;
  bool addClicked = false;
  GlobalKey addressKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    getCrates();
  }

  void getCrates() async {
    var response =
        await HttpService().get('app/crates/get_unallocated_crates/');
    var customerResponse = await HttpService().get('app/customers/');

    for (var crateJson in jsonDecode(response.body)) {
      crateList.add(
        parseCrate(crateJson),
      );
    }

    for (var customerJson in jsonDecode(customerResponse.body)) {
      customerList.add(parseCustomer(customerJson));
    }

    setState(() {
      cratesLoaded = true;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Delivery Batch'),
      ),
      resizeToAvoidBottomInset: true,
      body: cratesLoaded
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Visibility(
                    visible: (!areCratesSelected && addClicked),
                    child: Text("Please select a crate",
                        style: TextStyle(color: Colors.red)),
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
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  selectableListView = SelectableListView(
                                    checkboxes: true,
                                    items: selectableListViewList,
                                    onSelectionChanged:
                                        (List<dynamic> selectionChanged) {
                                      selectedCrateIds =
                                          selectionChanged.map((e) {
                                        return (e.crateId as String);
                                      }).toList();

                                      setState(() {
                                        areCratesSelected =
                                            selectionChanged.isNotEmpty;
                                      });
                                    },
                                    title: 'Crates',
                                    extraButton: ElevatedButton(
                                      onPressed: () async {
                                        var result =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (cxt) =>
                                                ScanIndividualCrate(
                                              crateList: crateList,
                                            ),
                                          ),
                                        );

                                        if (result is Crate) {
                                          if (!selectedCrateIds
                                              .contains(result.crateId)) {
                                            // selectedCrateIds
                                            //     .add(result.crateId);
                                            selectableListView!
                                                .selectionStreamController
                                                .add(result);
                                          }
                                        }
                                      },
                                      style: ButtonStyle(
                                        shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      ),
                                      child: const SizedBox(
                                          width: 999,
                                          child: Text('Tap to Scan Crate')),
                                    ),
                                  );

                                  return selectableListView!;
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: (!isCustomerSelected && addClicked),
                    child: Text("Please select a customer",
                        style: TextStyle(color: Colors.red)),
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
                              items: selectableCustomerListViewList,
                              onSelectionChanged:
                                  (List<dynamic> selectionChanged) {
                                selectedCustomerId =
                                    (selectionChanged.isNotEmpty)
                                        ? selectionChanged[0].id
                                        : -1;

                                setState(() {
                                  isCustomerSelected =
                                      selectionChanged.isNotEmpty;
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
                  Visibility(
                    visible: (!isAddressSelected && addClicked),
                    child: Text("Please select an address",
                        style: TextStyle(color: Colors.red)),
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<Address>(
                          key: addressKey,
                          isExpanded: true,
                          hint: Text("Select Delivery Address"),
                          value: selectedAddress,
                          items: (selectedCustomerId != -1)
                              ? customerList
                                  .firstWhere((customer) =>
                                      customer.id == selectedCustomerId)
                                  .getAddressesAsDropdownItems()
                              : [
                                  DropdownMenuItem(
                                      value: null,
                                      child: Text("Select customer first"))
                                ],
                          onChanged: (value) {
                            setState(() {
                              selectedAddress = value;
                              isAddressSelected = value != null;
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
          : Center(child: const CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.clear), label: 'Cancel'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add')
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
                var response =
                    await HttpService().create('app/delivery_batches/', {
                  "crates": selectedCrateIds,
                  "customer": selectedCustomerId,
                  "delivery_address": selectedAddress!.id
                });
                if (response.statusCode == 400) {
                  if (jsonDecode(response.body)['delivery_address'] != null) {
                    await showError(
                        jsonDecode(response.body)['delivery_address'][0],
                        context);
                  }
                }
                Navigator.pop(context, true);
              } else {
                setState(() {
                  addClicked = true;
                });
                if (selectedAddress == null) {
                  final targetContext = addressKey.currentContext;
                  if (targetContext != null) {
                    Scrollable.ensureVisible(
                      targetContext,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                }
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
        parseAddresses((customerJson['addresses'])));
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

class Customer {
  int id;
  String name;
  String contactDetails;
  List<Address> addresses;

  Customer(this.id, this.name, this.contactDetails, this.addresses);

  List<DropdownMenuItem<Address>> getAddressesAsDropdownItems() {
    var list = addresses.map((address) {
      return DropdownMenuItem<Address>(
        value: address,
        child: Text(address.value),
      );
    }).toList();

    return list;
  }
}

class Address {
  int id;
  String value;

  Address(this.id, this.value);

  @override
  operator ==(other) =>
      other is Address && other.id == id && other.value == value;

  @override
  int get hashCode => Object.hash(id, value);
}
