import 'dart:convert';

import 'package:delivery_tracking_app/colour_constants.dart';
import 'package:delivery_tracking_app/custom_app_bar.dart';
import 'package:delivery_tracking_app/delivery_batch_list_item.dart';
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

  _fetchAllData() async {
    await getDeliveryBatches();
    await _getDeliveryBatchDrafts();
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
      appBar: CustomAppBar(
        title: 'Delivery Batches',
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add your onPressed code here!
            },
          ),
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            await _fetchAllData();
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
            await _fetchAllData();
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
        DeliveryBatchListItem(
          deliveryBatch: deliveryBatch,
          onTap: () async {
            var response = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (cxt) => DeliveryBatchDetail(
                  deliveryBatch: deliveryBatch,
                  isDraft: false,
                ),
              ),
            );
            await getDeliveryBatches();
          },
        )
    ];
  }

  List<Widget> _buildDraftList() {
    return [
      for (var draft in deliveryBatchDrafts)
        GestureDetector(
          onTap: () async {
            var response = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (cxt) => DeliveryBatchDetail(
                  deliveryBatch: draft,
                  isDraft: true,
                ),
              ),
            );
            await _getDeliveryBatchDrafts();
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
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        child: Text(
          "D",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        "{DRAFT} To: ${customerName}",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        address,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right_sharp, color: Colors.teal),
    );
  }
}
