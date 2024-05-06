import 'dart:async';
import 'dart:convert';

import 'package:delivery_tracking_app/custom_bottom_bar.dart';
import 'package:delivery_tracking_app/delivery_batches/select_crates_page.dart';
import 'package:delivery_tracking_app/delivery_batches/select_customer_page.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/searchable_list.dart';
import 'package:flutter/material.dart';

import '../error_modal.dart';
import '../models/address.dart';
import '../models/crate.dart';
import '../models/customer.dart';

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
  List<Crate> selectedCrates = [];
  int selectedCustomerId = -1;
  Customer? selectedCustomer;
  TextEditingController addressFieldController = TextEditingController();
  SelectableListView? selectableListView;
  Address? selectedAddress;
  bool isCustomerSelected = false;
  bool areCratesSelected = false;
  bool isAddressSelected = false;
  bool addClicked = false;
  GlobalKey addressKey = GlobalKey();
  StreamController<List<Crate>> selectionStreamController =
      StreamController<List<Crate>>();
  TextEditingController customerDropDownController = TextEditingController();

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

    List<DropdownMenuEntry<Customer>> selectableCustomerListViewList =
        customerList
            .map(
              (e) => DropdownMenuEntry(value: e, label: e.name),
            )
            .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Delivery Batch'),
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
                        child: Text("Please select at least one crate",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: OutlinedButton(
                          onPressed: () async {
                            print('Navigating to Select Crates page');
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
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Visibility(
                        visible: (selectedCustomer == null && addClicked),
                        child: const Text("Please select a customer",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: OutlinedButton(
                          onPressed: () async {
                            print('Navigating to Select Customer page');
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
          primaryButtonLabel: 'Create',
          onPrimaryButtonPressed: () async {
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
              // if (selectedAddress == null) {
              //   final targetContext = addressKey.currentContext;
              //   if (targetContext != null) {
              //     Scrollable.ensureVisible(
              //       targetContext,
              //       duration: const Duration(milliseconds: 400),
              //       curve: Curves.easeInOut,
              //     );
              //   }
              // }
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

  @override
  void dispose() {
    super.dispose();
    selectionStreamController.close();
  }
}

//                                   SelectableListView(
//                                     checkboxes: true,
//                                     items: selectableListViewList,
//                                     onSelectionChanged:
//                                         (List<dynamic> selectionChanged) {
//                                       selectedCrateIds =
//                                           selectionChanged.map((e) {
//                                         return (e.crateId as String);
//                                       }).toList();
//
//                                       setState(() {
//                                         areCratesSelected =
//                                             selectionChanged.isNotEmpty;
//                                       });
//                                     },
//                                     selectionStream:
//                                         selectionStreamController.stream,
//                                     title: 'Crates',
//                                     extraButton: ElevatedButton(
//                                       onPressed: () async {
//                                         var result =
//                                             await Navigator.of(context).push(
//                                           MaterialPageRoute(
//                                             builder: (cxt) =>
//                                                 ScanIndividualCrate(
//                                               crateList: crateList,
//                                             ),
//                                           ),
//                                         );
//
//                                         if (result is Crate) {
//                                           if (!selectedCrateIds
//                                               .contains(result.crateId)) {
//                                             // selectedCrateIds
//                                             //     .add(result.crateId);
//                                             selectionStreamController
//                                                 .add(result);
//                                           }
//                                         }
//                                       },
//                                       style: ButtonStyle(
//                                         shape: MaterialStatePropertyAll(
//                                           RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(5),
//                                           ),
//                                         ),
//                                       ),
//                                       child: const SizedBox(
//                                           width: 999,
//                                           child: Text('Tap to Scan Crate')),
//                                     ),
//                                   )
