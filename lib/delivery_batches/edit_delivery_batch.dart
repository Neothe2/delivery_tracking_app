import 'dart:convert';

import 'package:delivery_tracking_app/delivery_batches/select_crates_page.dart';
import 'package:delivery_tracking_app/delivery_batches/select_customer_page.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:flutter/material.dart';

import '../custom_bottom_bar.dart';
import '../error_modal.dart';
import '../models/address.dart';
import '../models/crate.dart';
import '../models/customer.dart';
import '../models/delivery_batch.dart';

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
  Customer? selectedCustomer;
  TextEditingController addressFieldController = TextEditingController();
  Address? selectedAddress;
  List<DropdownMenuItem<Address>> addressItems = [];
  bool customersLoaded = false;

  bool addClicked = false;

  @override
  void initState() {
    super.initState();
    selectedCustomer = widget.deliveryBatch.customer;
    selectedCrates = widget.deliveryBatch.crates;
    if (!widget.deliveryBatch.draft) {
      for (var address in selectedCustomer!.addresses) {
        if (address.id == widget.deliveryBatch.address!.id) {
          selectedAddress = address;
        }
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

    addressFieldController.text =
        widget.deliveryBatch.draft ? "" : widget.deliveryBatch.address!.value;
    selectedCustomerId = selectedCustomer != null
        ? selectedCustomer!.id
        : widget.deliveryBatch.draft
            ? -1
            : widget.deliveryBatch.customer!.id;
    selectedCrateIds =
        widget.deliveryBatch.crates.map((e) => e.crateId).toList();

    setState(() {
      cratesLoaded = true;
      if (selectedCustomer != null) {
        addressItems = customerList
            .firstWhere((customer) => customer.id == selectedCustomerId)
            .getAddressesAsDropdownItems();
      }

      customersLoaded = true;
    });
  }

  Crate parseCrate(Map<String, dynamic> crate) {
    return Crate(crate['crate_id']);
  }

  Future<void> _saveAsDraft() async {
    if (selectedCustomer != null ||
        selectedCrates.isNotEmpty ||
        selectedAddress != null) {
      print("Saved as draft.");
      var response = await HttpService()
          .update('app/delivery_batches/${widget.deliveryBatch.id}/', {
        "crates": selectedCrateIds,
        "customer": selectedCustomer != null ? selectedCustomerId : "",
        "delivery_address": selectedAddress != null ? selectedAddress!.id : "",
        "draft": true
      });
      if (response.statusCode == 400) {
        if (jsonDecode(response.body)['delivery_address'] != null) {
          await showError(
              jsonDecode(response.body)['delivery_address'][0], context);
        }
      }
    } else {
      print("Not saved as draft because no data.");
    }

    // var response = await HttpService().create('app/delivery_batches/', {
    //   "crates": selectedCrates.map((e) => e.crateId).toList(),
    //   "customer": selectedCustomer!.id,
    //   "delivery_address": selectedAddress!.id,
    //   "draft": true
    // });
    // if (response.statusCode == 400) {
    //   if (jsonDecode(response.body)['delivery_address'] != null) {
    //     await showError(
    //         jsonDecode(response.body)['delivery_address'][0], context);
    //   }
    // }
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
    if (widget.deliveryBatch.customer != null) {
      Customer? preselectedCustomer;
      for (var customer in customerList) {
        if (customer.id == widget.deliveryBatch.customer!.id) {
          preselectedCustomer = customer;
        }
      }
    }

    return PopScope(
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          await _saveAsDraft();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Delivery Batch'),
        ),
        resizeToAvoidBottomInset: true,
        body: cratesLoaded
            ? SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Visibility(
                          visible: (selectedCrates.isEmpty && addClicked),
                          child: const Text("Please select at least one crate.",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: OutlinedButton(
                            onPressed: () async {
                              List<Crate>? response =
                                  await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (cxt) => SelectCratesPage(
                                    crateList: crateList,
                                    initialCrates: selectedCrates,
                                  ),
                                ),
                              );

                              if (response != null) {
                                setState(() {
                                  selectedCrates = response;
                                });
                                selectedCrateIds =
                                    response.map((e) => e.crateId).toList();
                              }
                            },
                            child: const Text('Select Crates')),
                      ),
                      SizedBox(
                        width: 300,
                        child: OutlinedButton(
                            onPressed: () async {
                              List<dynamic>? response =
                                  await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (cxt) => SelectCustomerPage(
                                    customerList: customerList,
                                    initialCustomer: selectedCustomer,
                                    selectedAddress: selectedAddress,
                                  ),
                                ),
                              );

                              if (response != null) {
                                if (response[0] is Customer) {
                                  setState(() {
                                    selectedCustomer = response[0];
                                  });
                                  selectedCustomerId = response[0].id;
                                  selectedAddress = response[1];
                                }
                              }
                            },
                            child: const Text('Select Customer')),
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
                ),
              )
            : const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: BottomBar(
            primaryButtonLabel: 'Ok',
            onPrimaryButtonPressed: () async {
              if (selectedCustomerId != -1 &&
                  selectedCrateIds.isNotEmpty &&
                  selectedAddress != null) {
                var response = await HttpService().update(
                    'app/delivery_batches/${widget.deliveryBatch.id}/', {
                  "crates": selectedCrateIds,
                  "customer": selectedCustomerId,
                  "delivery_address": selectedAddress!.id,
                  "draft": false
                });

                if (response.statusCode == 400) {
                  if (jsonDecode(response.body)['delivery_address'] != null) {
                    await showError(
                        jsonDecode(response.body)['delivery_address'][0],
                        context);
                  }
                }
                print(jsonDecode(response.body));
                widget.deliveryBatch.crates = selectedCrates;
                widget.deliveryBatch.customer = selectedCustomer;
                widget.deliveryBatch.address = selectedAddress!;
                Navigator.pop(context, widget.deliveryBatch);
              }
            }),
        // bottomNavigationBar: BottomNavigationBar(
        //   items: [
        //     BottomNavigationBarItem(icon: Icon(Icons.clear), label: 'Cancel'),
        //     BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add')
        //   ],
        //   currentIndex: 1,
        //   selectedItemColor: Colors.green,
        //   unselectedItemColor: Colors.grey,
        //   onTap: (index) async {
        //     switch (index) {
        //       case 1:
        //         if (selectedCustomerId != -1 &&
        //             selectedCrateIds.isNotEmpty &&
        //             selectedAddress != null) {
        //           var response =
        //               await HttpService().create('app/delivery_batches/', {
        //             "crates": selectedCrateIds,
        //             "customer": selectedCustomerId,
        //             "delivery_address": selectedAddress!.id
        //           });
        //           if (response.statusCode == 400) {
        //             if (jsonDecode(response.body)['delivery_address'] != null) {
        //               await showError(
        //                   jsonDecode(response.body)['delivery_address'][0],
        //                   context);
        //             }
        //           }
        //           Navigator.pop(context, true);
        //         } else {
        //           setState(() {
        //             addClicked = true;
        //           });
        //           // if (selectedAddress == null) {
        //           //   final targetContext = addressKey.currentContext;
        //           //   if (targetContext != null) {
        //           //     Scrollable.ensureVisible(
        //           //       targetContext,
        //           //       duration: const Duration(milliseconds: 400),
        //           //       curve: Curves.easeInOut,
        //           //     );
        //           //   }
        //           // }
        //         }
        //
        //       case 0:
        //         bool confirmation = await confirmationModal(context: context, header: "Are you sure", message: "Are you sure you want to cancel?")
        //         Navigator.pop(context);
        //     }
        //   },
        // ),
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
