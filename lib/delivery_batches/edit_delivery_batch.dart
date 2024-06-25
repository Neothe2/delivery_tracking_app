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
import 'package:http/src/response.dart';

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
  List<DropdownMenuItem<Address>> addressDropdownItems = [];
  bool customersLoaded = false;

  bool addClicked = false;

  @override
  void initState() {
    super.initState();
    selectedCustomer = widget.deliveryBatch.customer;
    selectedCrates = widget.deliveryBatch.crates;
    initializeSelectedAddress();

    getCrates();
  }

  void initializeSelectedAddress() {
    for (var address in selectedCustomer!.addresses) {
      if (address.id == widget.deliveryBatch.address.id) {
        selectedAddress = address;
      }
    }
  }

  void getCrates() async {
    Response response = await getUnallocatedCratesHttp();
    Response customerResponse = await getAllCustomersHttp();

    InitializeCrateList(response);

    InitializeCustomerList(customerResponse);

    initializeAddressFieldControllerText();

    InitializeSelectedCustomerId();

    initializeSelectedCrateIds();

    setState(() {
      cratesLoaded = true;
      initializeAddressDropdownItems();
      customersLoaded = true;
    });
  }

  void initializeAddressDropdownItems() {
    if (selectedCustomer != null) {
      addressDropdownItems = customerList
          .firstWhere((customer) => customer.id == selectedCustomerId)
          .getAddressesAsDropdownItems();
    }
  }

  void initializeSelectedCrateIds() {
    selectedCrateIds =
        widget.deliveryBatch.crates.map((e) => e.crateId).toList();
  }

  void InitializeSelectedCustomerId() {
    selectedCustomerId = selectedCustomer != null
        ? selectedCustomer!.id
        : widget.deliveryBatch.customer != null
            ? widget.deliveryBatch.customer.id
            : -1;
  }

  void initializeAddressFieldControllerText() {
    addressFieldController.text = widget.deliveryBatch.address == null
        ? ""
        : widget.deliveryBatch.address.value;
  }

  void InitializeCustomerList(Response customerResponse) {
    for (var customerJson in jsonDecode(customerResponse.body)) {
      customerList.add(Customer.fromJson(customerJson));
    }
  }

  void InitializeCrateList(Response response) {
    for (var crate in widget.deliveryBatch.crates) {
      crateList.add(crate);
    }

    for (var crateJson in jsonDecode(response.body)) {
      crateList.add(
        Crate.fromJson(crateJson),
      );
    }
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
  }

  @override
  Widget build(BuildContext context) {
    print(crateList);
    createSelectableListViewList();

    createSelectableCustomerListViewList();

    getPreselectedCrates();
    getPreselectedCustomer();

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
                      ..._buildSelectCrateButton(),
                      ..._buildSelectCustomerButton(),
                    ],
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  void getPreselectedCustomer() {
    if (widget.deliveryBatch.customer != null) {
      Customer? preselectedCustomer;
      for (var customer in customerList) {
        if (customer.id == widget.deliveryBatch.customer.id) {
          preselectedCustomer = customer;
        }
      }
    }
  }

  void getPreselectedCrates() {
    List<Crate> preselectedCrates = [];
    for (var selectedCrate in widget.deliveryBatch.crates) {
      for (var crate in crateList) {
        if (crate.crateId == selectedCrate.crateId) {
          preselectedCrates.add(crate);
        }
      }
    }
  }

  void createSelectableCustomerListViewList() {
    List<MapEntry<String, dynamic>> selectableCustomerListViewList =
        customerList
            .map(
              (e) => MapEntry(e.name, e),
            )
            .toList();
  }

  void createSelectableListViewList() {
    List<MapEntry<String, dynamic>> selectableListViewList = crateList
        .map(
          (e) => MapEntry("Id: ${e.crateId}", e),
        )
        .toList();
  }

  _buildSelectCrateButton() {
    return [
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
            List<Crate>? response = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (cxt) => SelectCratesPage(
                  crateList: crateList,
                  //TODO: Might become a bug
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
          child: const Text('Select Crates'),
        ),
      ),
    ];
  }

  _buildSelectCustomerButton() {
    return [
      SizedBox(
        width: 300,
        child: OutlinedButton(
          onPressed: () async {
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

  _buildBottomBar() {
    return BottomBar(
      primaryButtonLabel: 'Ok',
      onPrimaryButtonPressed: () async {
        if (selectedCustomerId != -1 &&
            selectedCrateIds.isNotEmpty &&
            selectedAddress != null) {
          var response = await HttpService()
              .update('app/delivery_batches/${widget.deliveryBatch.id}/', {
            "crates": selectedCrateIds,
            "customer": selectedCustomerId,
            "delivery_address": selectedAddress!.id,
            "draft": false
          });

          if (response.statusCode == 400) {
            if (jsonDecode(response.body)['delivery_address'] != null) {
              await showError(
                  jsonDecode(response.body)['delivery_address'][0], context);
            }
          }
          print(jsonDecode(response.body));
          widget.deliveryBatch.crates = selectedCrates;
          widget.deliveryBatch.customer = selectedCustomer;
          widget.deliveryBatch.address = selectedAddress!;
          Navigator.pop(context, widget.deliveryBatch);
        }
      },
    );
  }
}

// class Customer {
//   int id;
//   String name;
//   String contactDetails;
//
//   Customer(this.id, this.name, this.contactDetails);
// }
