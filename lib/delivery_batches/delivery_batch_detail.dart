import 'package:delivery_tracking_app/delivery_batches/edit_delivery_batch.dart';
import 'package:delivery_tracking_app/searchable_list.dart';
import 'package:flutter/material.dart';

import '../http_service.dart';
import '../models/crate.dart';
import '../models/delivery_batch.dart';
import '../interfaces/delivery_batch_interface.dart'; // Import the interface

class DeliveryBatchDetail extends StatefulWidget {
  IDeliveryBatch deliveryBatch; // Use the interface
  bool isDraft;

  DeliveryBatchDetail(
      {super.key, required this.deliveryBatch, required this.isDraft});

  @override
  State<DeliveryBatchDetail> createState() => _DeliveryBatchDetailState();
}

class _DeliveryBatchDetailState extends State<DeliveryBatchDetail> {
  bool cratesLoaded = true;

  @override
  Widget build(BuildContext context) {
    // var cratesList = [
    //   Crate('a', 'contents1'),
    //   Crate('b', 'contents2'),
    //   Crate('c', 'contents3'),
    //   Crate('d', 'contents4'),
    //   Crate('e', 'contents5'),
    //   Crate('e', 'contents5'),
    //   Crate('e', 'contents5'),
    //   Crate('e', 'contents5'),
    //   Crate('e', 'contents5'),
    //   Crate('e', 'contents5'),
    //   Crate('e', 'contents5'),
    //   Crate('e', 'contents5'),
    //   Crate('e', 'contents5'),
    //   Crate('e', 'contents5'),
    //   Crate('f', 'contents5'),
    // ];

    return Scaffold(
        appBar: AppBar(
          title: const Text('Delivery Batch Detail'),
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: cratesLoaded
              ? Column(
                  children: [
                    _buildCratesCard(),
                    _buildCustomerCard(),
                    if (!widget.isDraft) _buildVehicleCard(),
                    _buildDeliveryAddressCard()
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar());
  }

  _buildVehicleCard() {
    //If we are building the vehicle card, then the IDeliveryBatch will always be a DeliveryBatch
    if (widget.deliveryBatch is DeliveryBatch) {
      DeliveryBatch deliveryBatch = widget.deliveryBatch as DeliveryBatch;
      return Padding(
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
            child: Column(
              children: [
                Text(
                  'Assigned Vehicle',
                  style: TextStyle(
                      fontSize: 20, decoration: TextDecoration.underline),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  constraints: BoxConstraints(minWidth: 999),
                  child: (deliveryBatch.vehicle != null)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${deliveryBatch.vehicle!.type}: ${deliveryBatch.vehicle!.licensePlate}',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Text(
                          'No vehicles are currently assigned to this delivery batch',
                          textAlign: TextAlign.center,
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  _buildDeliveryAddressCard() {
    return Padding(
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
          child: Column(
            children: [
              Text(
                'Delivery Address',
                style: TextStyle(
                    fontSize: 20, decoration: TextDecoration.underline),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                constraints: BoxConstraints(minWidth: 999),
                child: _buildAddressDisplayText(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildAddressDisplayText() {
    return Text(widget.deliveryBatch.address != null
        ? widget.deliveryBatch.address!.value
        : 'No address assigned');
  }

  _buildCustomerCard() {
    return Padding(
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
          child: Column(
            children: [
              const Text(
                'Customer',
                style: TextStyle(
                    fontSize: 20, decoration: TextDecoration.underline),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                constraints: BoxConstraints(minWidth: 999),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildCustomerNameText(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildCustomerNameText() {
    var customerName = widget.deliveryBatch.customer != null
        ? '${widget.deliveryBatch.customer!.name}: ${widget.deliveryBatch.customer!.contactDetails}'
        : 'No customer assigned';
    return Text(
      customerName,
      textAlign: TextAlign.center,
    );
  }

  _buildCratesCard() {
    List<MapEntry<String, dynamic>> selectableListViewList =
        _getSelectableCratesList();
    return Padding(
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
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 400,
              child: SelectableListView(
                checkboxes: false,
                items: selectableListViewList,
                onSelectionChanged: (List<dynamic> selectionChanged) {
                  for (var crate in selectionChanged) {
                    if (crate is Crate) {
                      print(crate.crateId);
                    }
                  }
                },
                title: 'Crates',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<String, dynamic>> _getSelectableCratesList() {
    List<MapEntry<String, dynamic>> selectableListViewList = widget
        .deliveryBatch.crates
        .map((e) => MapEntry("Id: ${e.crateId}", e))
        .toList();
    return selectableListViewList;
  }

  _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'Delete'),
        BottomNavigationBarItem(icon: Icon(Icons.edit_square), label: 'Edit')
      ],
      currentIndex: 1,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.red,
      onTap: (index) async {
        switch (index) {
          case 1:
            setState(() {
              cratesLoaded = false;
            });
            var response = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (cxt) => EditDeliveryBatch(
                  deliveryBatch: widget.deliveryBatch,
                  isDraft: widget.isDraft,
                ),
              ),
            );

            setState(() {
              if (response is IDeliveryBatch) {
                widget.deliveryBatch = response;
              }

              cratesLoaded = true;
            });

          case 0:
            //   await HttpService()
            //       .delete('app/delivery_batches/${widget.deliveryBatch.id}/');
            Navigator.pop(context, true);
            print("Navigating to edit page...");
        }
      },
    );
  }
}
