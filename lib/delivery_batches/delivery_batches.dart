import 'dart:convert';

import 'package:delivery_tracking_app/delivery_batches/add_delivery_batch.dart';
import 'package:delivery_tracking_app/delivery_batches/delivery_batch_detail.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/models/delivery_batch_draft.dart';
import 'package:delivery_tracking_app/repositories/hive_delivery_batch_draft_repository.dart';
import 'package:flutter/material.dart';

import '../models/address.dart';
import '../models/crate.dart';
import '../models/customer.dart';
import '../models/delivery_batch.dart';
import '../models/vehicle.dart';

class DeliveryBatchesPage extends StatefulWidget {
  const DeliveryBatchesPage({super.key});

  @override
  State<DeliveryBatchesPage> createState() => _DeliveryBatchesPageState();
}

class _DeliveryBatchesPageState extends State<DeliveryBatchesPage> {
  List<DeliveryBatch> deliveryBatches = [];
  List<DeliveryBatchDraft> deliveryBatchDrafts = [];

  @override
  void initState() {
    super.initState();
    getDeliveryBatches();
    _getDeliveryBatchDrafts();
  }

  getDeliveryBatches() async {
    deliveryBatches = [];
    var response = await HttpService().get('app/delivery_batches/');
    var decodedBody = jsonDecode(response.body);
    setState(() {
      for (var deliveryBatch in decodedBody) {
        deliveryBatches.add(DeliveryBatch.fromJson(deliveryBatch));
      }
    });
  }

  _getDeliveryBatchDrafts() async {
    var drafts = await HiveDeliveryBatchDraftRepository().getAllDrafts();
    setState(() {
      deliveryBatchDrafts = drafts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Batches'),
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            await getDeliveryBatches();
          },
          child: (deliveryBatches.isEmpty)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'There are no delivery batches. Press the + button to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                )
              : ListView(children: [
                  Column(
                    children: [
                      ..._buildDraftList(),
                      ..._buildDeliveryBatchList(),
                    ],
                  ),
                ])

          // ListView.builder(
          //     itemCount: deliveryBatches.length,
          //     itemBuilder: (context, index) {
          //       final deliveryBatch = deliveryBatches[index];

          //       return                 },
          //   ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var response = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (cxt) => AddDeliveryBatch(),
            ),
          );

          if (response == true) {
            this.deliveryBatches = [];
            getDeliveryBatches();
          }
        },
        child: const Icon(Icons.add),
        shape: CircleBorder(),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
      ),
    );
  }

  List<Widget> _buildDeliveryBatchList() {
    return [
      for (var deliveryBatch in deliveryBatches)
        GestureDetector(
          onTap: () async {
            var response = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (cxt) => DeliveryBatchDetail(
                  deliveryBatch: deliveryBatch,
                ),
              ),
            );
            if (response == true) {
              deliveryBatches = [];
              getDeliveryBatches();
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
                leading: CircleAvatar(
                  foregroundColor: Colors.white,
                  child: Text(deliveryBatch.id.toString().toUpperCase()),
                ),
                title: Text(
                    "${deliveryBatch.draft ? "{DRAFT}" : ""}To: ${deliveryBatch.draft ? "NONE" : deliveryBatch.customer!.name}"),
                subtitle: Text(deliveryBatch.draft
                    ? "NONE"
                    : deliveryBatch.address!.value),
                trailing: const Icon(Icons.chevron_right_sharp),
              ),
            ),
          ),
        )
    ];
  }

  List<Widget> _buildDraftList() {
    return [
      for (var draft in deliveryBatchDrafts)
        GestureDetector(
          onTap: () async {
            print("Navigating to draft detail page...");
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
                child: _buildDraftListTile(draft)),
          ),
        )
    ];
  }

  ListTile _buildDraftListTile(DeliveryBatchDraft draft) {
    String customerName =
        draft.customer != null ? draft.customer!.name : "NONE";
    String address = draft.address != null ? draft.address!.value : "NONE";

    return ListTile(
      leading: CircleAvatar(
        foregroundColor: Colors.white,
        child: Text("D"),
      ),
      title: Text("{DRAFT} To: ${customerName}"),
      subtitle: Text(address),
      trailing: const Icon(Icons.chevron_right_sharp),
    );
  }
}
