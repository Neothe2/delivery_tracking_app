import 'dart:async';
import 'dart:convert';

import 'package:delivery_tracking_app/3_button_bottom_bar.dart';
import 'package:delivery_tracking_app/custom_bottom_bar.dart';
import 'package:delivery_tracking_app/delivery_batches/select_crates_page.dart';
import 'package:delivery_tracking_app/delivery_batches/select_customer_page.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/models/delivery_batch.dart';
import 'package:delivery_tracking_app/models/delivery_batch_draft.dart';
import 'package:delivery_tracking_app/repositories/hive_delivery_batch_draft_repository.dart';
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

enum SaveStates { discard, cancel, saveAsDraft, save }

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
  var deliveryBatchDraftRepository = HiveDeliveryBatchDraftRepository();

  bool get _everythingFilledIn => (selectedCustomer != null &&
      selectedCrates.isNotEmpty &&
      selectedAddress != null);

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
    var anyOneThingFilledIn = selectedCustomer != null ||
        selectedCrates.isNotEmpty ||
        selectedAddress != null;

    if (anyOneThingFilledIn) {
      var selectedCrateIds = selectedCrates.map((e) => e.crateId).toList();
      var deliveryBatchDraft = DeliveryBatchDraft(
        selectedCrateIds,
        selectedCustomer?.id,
        selectedAddress?.id,
      );

      deliveryBatchDraftRepository.saveDraft(deliveryBatchDraft);

      print(await deliveryBatchDraftRepository.getAllDrafts());

      Navigator.pop(context);
    } else {
      print("Not saved as draft because no data.");
    }
  }

  Future<SaveStates> askSaveConfirmation() async {
    // Use a completer to handle the result of the dialog
    // final completer = Completer<SaveStates>();
    var response = await showDialog(
      context: context, // Assuming you have a navigatorKey
      builder: (context) => AlertDialog(
        title: const Text('Save Confirmation'),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, SaveStates.discard),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, SaveStates.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, SaveStates.saveAsDraft),
            child: const Text('Save As Draft'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, SaveStates.save),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (response == null) {
      return SaveStates.cancel;
    } else {
      return response;

      // Return the completed state
    }
  }

  _buildCustomBackButton() {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }

        SaveStates saveState = await askSaveConfirmation();

        print(saveState);

        switch (saveState) {
          case SaveStates.discard:
            // TODO: show confirmation modal for discard
            Navigator.pop(context);

          case SaveStates.cancel:
            await executeTempCode();
            return;

          case SaveStates.saveAsDraft:
            await _saveAsDraft();

          case SaveStates.save:
            await _save();
        }
      },
      child: BackButton(
        color: Colors.blueAccent,
      ),
    );
  }

  Future<void> executeTempCode() async {
    // await deliveryBatchDraftRepository.clearAll();
    List<DeliveryBatchDraft> allDrafts =
        await deliveryBatchDraftRepository.getAllDrafts();
    print(allDrafts.length);
    for (var draft in allDrafts) {
      print(draft.crateIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _buildCustomBackButton(),
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
        await _save();
        Navigator.pop(context, true);
      },
      secondaryButtonLabel: 'Save As Draft',
      onSecondaryButtonPressed: () {
        print("save as draft button clicked");
      },
      secondaryButtonIcon: Icons.save,
    );
  }

  Future<void> _save() async {
    if (_everythingFilledIn) {
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
      Navigator.pop(context);
    } else {
      setState(() {
        addClicked = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    selectionStreamController.close();
  }
}
