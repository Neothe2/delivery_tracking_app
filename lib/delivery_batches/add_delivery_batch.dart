import 'dart:async';
import 'dart:convert';

import 'package:delivery_tracking_app/3_button_bottom_bar.dart';
import 'package:delivery_tracking_app/custom_app_bar.dart';
import 'package:delivery_tracking_app/custom_bottom_bar.dart';
import 'package:delivery_tracking_app/delivery_batches/select_crates_button.dart';
import 'package:delivery_tracking_app/delivery_batches/select_crates_page.dart';
import 'package:delivery_tracking_app/delivery_batches/select_customer_button.dart';
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
        selectedCrates,
        selectedCustomer,
        selectedAddress,
      );

      deliveryBatchDraftRepository.saveDraft(deliveryBatchDraft);

      print(await deliveryBatchDraftRepository.getAllDrafts());

      Navigator.pop(context, true);
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
      child: BackButton(),
    );
  }

  Future<void> executeTempCode() async {
    List<DeliveryBatchDraft> allDrafts =
        await deliveryBatchDraftRepository.getAllDrafts();
    print(allDrafts.length);
    var printString = '[';
    for (var draft in allDrafts) {
      for (var crate in draft.crates) {
        printString += crate.toString() + ', ';
      }
    }
    printString += ']';
    print(printString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: _buildCustomBackButton(),
        title: 'Add Delivery Batch',
      ),
      resizeToAvoidBottomInset: true,
      body: cratesLoaded
          ? SingleChildScrollView(
              child: Center(
                child: _pageWithConstraints([
                  Spacer(),
                  _buildSelectCratesButton(),
                  _buildSelectCustomerButton(),
                  Spacer(),
                ]),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  _pageWithConstraints(List<Widget> children) {
    final mediaQuery = MediaQuery.of(context);
    final appBarHeight = kToolbarHeight;
    final statusBarHeight = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height -
            appBarHeight -
            statusBarHeight -
            bottomPadding,
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(bottom: 16.0), // Add desired bottom padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }

  _buildSelectCratesButton() {
    return SelectCratesButton(
      crateList: crateList,
      selectedCrates: selectedCrates,
      addClicked: addClicked,
      onCratesSelected: (List<Crate> response) {
        setState(() {
          selectedCrates = response;
        });
        selectedCrateIds = response.map((e) => e.crateId).toList();
      },
    );
  }

  _buildSelectCustomerButton() {
    return SelectCustomerButton(
      customerList: customerList,
      selectedCustomer: selectedCustomer,
      selectedAddress: selectedAddress,
      addClicked: addClicked,
      onCustomerSelected: (Customer customer, Address address) {
        setState(() {
          selectedCustomer = customer;
          selectedAddress = address;
        });
      },
    );
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
        _saveAsDraft();
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
        // "draft": false
      });
      print(response.body);
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
  }

  @override
  void dispose() {
    super.dispose();
    selectionStreamController.close();
  }
}
