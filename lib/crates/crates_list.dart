import 'dart:convert';

import 'package:delivery_tracking_app/confirmation_modal.dart';
import 'package:delivery_tracking_app/crates/crates_add.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:flutter/material.dart';

import '../models/crate.dart';

class CratesListPage extends StatefulWidget {
  const CratesListPage({super.key});

  @override
  State<CratesListPage> createState() => _CratesListPageState();
}

class _CratesListPageState extends State<CratesListPage> {
  List<Crate> crates = [];
  List<Crate> filteredCrates = [];

  @override
  void initState() {
    super.initState();
    getCrates();
  }

  getCrates() async {
    crates = [];
    var response = await HttpService().get('app/crates/');
    var decodedBody = jsonDecode(response.body);
    // setState(() {
    setState(() {
      for (var crate in decodedBody) {
        crates.add(parseCrate(crate));
      }
      filteredCrates = crates;
    });
    // });
  }

  // DeliveryBatch parseDeliveryBatch(Map<String, dynamic> deliveryBatch) {
  //   List<Crate> crates = [];
  //   for (var crate in deliveryBatch['crates']) {
  //     crates.add(parseCrate(crate));
  //   }
  //
  //   return DeliveryBatch(
  //     deliveryBatch['id'],
  //     crates,
  //     parseVehicle(deliveryBatch['vehicle']),
  //     parseCustomer(deliveryBatch['customer']),
  //     parseAddress(deliveryBatch['delivery_address']),
  //   );
  // }

  // Customer parseCustomer(Map<String, dynamic> customerJson) {
  //   return Customer(
  //       customerJson['id'],
  //       customerJson['name'],
  //       customerJson['phone_number'],
  //       parseAddresses(customerJson['addresses']));
  // }
  //
  // List<Address> parseAddresses(List<dynamic> addressJsonList) {
  //   List<Address> returnList = [];
  //   for (var address in addressJsonList) {
  //     returnList.add(parseAddress(address));
  //   }
  //   return returnList;
  // }
  //
  // Address parseAddress(Map<String, dynamic> addressJson) {
  //   return Address(addressJson['id'], addressJson['value']);
  // }

  // Vehicle? parseVehicle(Map<String, dynamic>? vehicleData) {
  //   if (vehicleData != null) {
  //     return Vehicle(vehicleData['id'], vehicleData['license_plate'],
  //         vehicleData['vehicle_type'], vehicleData['is_loaded']);
  //   }
  //   return null;
  // }

  Crate parseCrate(Map<String, dynamic> crate) {
    return Crate(crate['crate_id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crates'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _searchItems(''), // Empty string for initial state
            padding: EdgeInsets.zero, // Remove padding for better alignment
            // You can customize the icon and onPressed logic here
          ),
          Container(
            width: 190,
            padding: EdgeInsets.only(right: 30),
            child: TextField(
              onChanged: (value) => _searchItems(value),
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  // Remove padding for better alignment
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  hintText: 'Search...'
                  // You can customize the border and other decorations here
                  ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          crates = [];
          await getCrates();
        },
        child: (crates.isEmpty)
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'There are no crates. Press the + button to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              )
            : ListView.builder(
                itemCount: filteredCrates.length,
                itemBuilder: (context, index) {
                  final crate = filteredCrates[index];
                  return GestureDetector(
                    onTap: () async {},
                    child: GestureDetector(
                      onTap: () async {
                        var response =
                            await navigateToDetailPage(context, crate);
                        if (response == true) {
                          crates = [];
                          getCrates();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: const Border.fromBorderSide(
                              BorderSide(color: Colors.grey),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text("ID: ${crate.crateId}"),
                            trailing: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                bool confirmation = await redConfirmationModal(
                                    context: context,
                                    header: 'Are You Sure?',
                                    message:
                                        "Are you sure you want to delete this crate?");
                                if (confirmation == true) {
                                  var response = await HttpService()
                                      .delete('app/crates/${crate.crateId}/');
                                  print(response.body);
                                  print(response.statusCode);
                                  setState(() {
                                    crates.remove(crate);
                                  });
                                  if (response.statusCode == 204 ||
                                      response.statusCode == 200) {
                                  } else {
                                    crates = [];
                                    getCrates();
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Contact newContact = await Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (cxt) => AddContact(),
          //   ),
          // );
          // print(newContact);
          // setState(() {
          //   this.contacts.add(newContact);
          // });

          var response = await navigateToAddPage(context);

          if (response == true) {
            this.crates = [];
            getCrates();
          }
        },
        child: const Icon(Icons.add),
        shape: CircleBorder(),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<dynamic> navigateToAddPage(BuildContext context) async {
    var response = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (cxt) => AddCrates(
          selectedCrateList: [],
          validate: (String crateId) {
            if (!(crates.any((element) => element.crateId == crateId))) {
              return Crate(crateId);
            }
            return null;
          },
        ),
      ),
    );

    if (response is List<Crate>) {
      var httpResponse =
          await HttpService().create('app/crates/add_multiple_crates/', {
        "crateIds": [...response.map((e) => e.crateId)]
      });
      setState(() {
        crates.addAll(response);
        if (httpResponse.statusCode != 201) {
          crates = [];
          getCrates();
        }
      });
    }
  }

  Future<dynamic> navigateToDetailPage(
      BuildContext context, Crate crate) async {
    print('Navigating to detail page');
    return true;
  }

  void _searchItems(String enteredKeyword) {
    List<Crate> results = [];
    if (enteredKeyword.isEmpty) {
      results = crates;
    } else {
      results = crates
          .where((item) =>
              item.crateId.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredCrates = results;
    });
  }
}
