import 'dart:async';
import 'dart:convert';

import 'package:delivery_tracking_app/3_button_bottom_bar.dart';
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
import 'package:http/src/response.dart';

class AddDeliveryBatch extends StatefulWidget {
  const AddDeliveryBatch({super.key});

  @override
  State<AddDeliveryBatch> createState() => _AddDeliveryBatchState();
}

class _AddDeliveryBatchState extends State<AddDeliveryBatch> {
  //Field Initializations
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
    //Get all unallocated crates and all customers
    Response response = await getUnallocatedCratesHttp();
    Response customerResponse = await getAllCustomersHttp();

    fillCratesFromJson(response);

    fillCustomerFromJson(customerResponse);

    setState(() {
      cratesLoaded = true;
    });
  }

  Future<Response> getAllCustomersHttp() async {
    var customerResponse = await HttpService().get('app/customers/');
    return customerResponse;
  }

  Future<Response> getUnallocatedCratesHttp() async {
    var response =
        await HttpService().get('app/crates/get_unallocated_crates/');
    return response;
  }

  void fillCustomerFromJson(Response customerResponse) {
    for (var customerJson in jsonDecode(customerResponse.body)) {
      customerList.add(Customer.fromJson(customerJson));
    }
  }

  void fillCratesFromJson(Response response) {
    for (var crateJson in jsonDecode(response.body)) {
      crateList.add(
        Crate.fromJson(crateJson),
      );
    }
  }

  //TODO: refactor
  Future<void> _saveAsDraft() async {
    if (selectedCustomer != null ||
        selectedCrates.isNotEmpty ||
        selectedAddress != null) {
      print("Saved as draft.");
      var response = await HttpService().create('app/delivery_batches/', {
        "crates": selectedCrates.map((e) => e.crateId).toList(),
        "customer": selectedCustomer != null ? selectedCustomer!.id : "",
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

    List<DropdownMenuEntry<Customer>> selectableCustomerListViewList =
        customerList
            .map(
              (e) => DropdownMenuEntry(value: e, label: e.name),
            )
            .toList();
    return PopScope(
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          // await _saveAsDraft();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Delivery Batch'),
        ),
        resizeToAvoidBottomInset: true,
        body: cratesLoaded
            ? SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ..._buildSelectCratesButton(),
                      ..._buildSelectCustomerButton(),
                    ],
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  _buildSelectCratesButton() {
    return [
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
              List<Crate>? response = await Navigator.of(context).push(
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
                selectedCrateIds = response.map((e) => e.crateId).toList();
              }
            },
            child: const Text('Select Crates')),
      )
    ];
  }

  _buildSelectCustomerButton() {
    return [
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
            List<dynamic>? response = await Navigator.of(context).push(
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
          child: const Text('Select Customer'),
        ),
      ),
    ];
  }

  _buildBottomNavigationBar() {
    return ThreeButtonBottomBar(
      primaryButtonLabel: 'Create',
      onPrimaryButtonPressed: () async {
        if (selectedCustomer != null &&
            selectedCrates.isNotEmpty &&
            selectedAddress != null) {
          var response = await HttpService().create('app/delivery_batches/', {
            "crates": selectedCrates.map((e) => e.crateId).toList(),
            "customer": selectedCustomer!.id,
            "delivery_address": selectedAddress!.id,
            "draft": false
          });
          if (response.statusCode == 400) {
            if (jsonDecode(response.body)['delivery_address'] != null) {
              await showError(
                  jsonDecode(response.body)['delivery_address'][0], context);
            }
          }
          Navigator.pop(context, true);
        } else {
          setState(() {
            addClicked = true;
          });
        }
      },
      secondaryButtonLabel: 'Save As Draft',
      onSecondaryButtonPressed: () {
        print("save as draft button clicked");
      },
      secondaryButtonIcon: Icons.save,
    );
  }

  @override
  void dispose() {
    super.dispose();
    selectionStreamController.close();
  }
}
