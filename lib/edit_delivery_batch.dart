import 'dart:convert';

import 'package:delivery_tracking_app/delivery_batches.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/searchable_list.dart';
import 'package:flutter/material.dart';

class EditDeliveryBatch extends StatefulWidget {
  final DeliveryBatch deliveryBatch;

  const EditDeliveryBatch({super.key, required this.deliveryBatch});

  @override
  State<EditDeliveryBatch> createState() => _EditDeliveryBatchState();
}

class _EditDeliveryBatchState extends State<EditDeliveryBatch> {
  List<Crate> crateList = [];
  bool cratesLoaded = false;
  List<String> selectedCrateIds = [];

  @override
  void initState() {
    super.initState();
    getCrates();
  }

  void getCrates() async {
    var response =
        await HttpService().get('app/crates/get_unallocated_crates/');
    setState(() {
      crateList.addAll(widget.deliveryBatch.crates);
      for (var crateJson in jsonDecode(response.body)) {
        crateList.add(
          parseCrate(crateJson),
        );
      }
      cratesLoaded = true;
    });
  }

  Crate parseCrate(Map<String, dynamic> crate) {
    return Crate(crate['crate_id'], crate['contents']);
  }

  @override
  Widget build(BuildContext context) {
    print(crateList);
    List<MapEntry<String, dynamic>> selectableListViewList = crateList
        .map(
          (e) => MapEntry("Id: ${e.crateId}", e),
        )
        .toList();
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
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 450,
                        child: SelectableListView(
                          checkboxes: true,
                          items: selectableListViewList,
                          preSelectedValues: widget.deliveryBatch.crates,
                          onSelectionChanged: (List<dynamic> selectionChanged) {
                            widget.deliveryBatch.crates = [];
                            for (var crate in selectionChanged) {
                              if (crate is Crate) {
                                widget.deliveryBatch.crates.add(crate);
                              }
                            }
                            selectedCrateIds = selectionChanged.map((e) {
                              return (e.crateId as String);
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.10),
                    child: OutlinedButton(
                      onPressed: () async {
                        var response = await HttpService().update(
                            'app/delivery_batches/${widget.deliveryBatch.id}/',
                            {"crates": selectedCrateIds});
                        Navigator.pop(context, widget.deliveryBatch.crates);
                        // DeliveryBatch deliveryBatch =
                        //     parseDeliveryBatch(response.body);
                      },
                      child: Text('Edit Delivery Batch'),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          : const Text('Loading...'),
    );
  }
}
