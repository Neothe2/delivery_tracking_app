import 'dart:convert';

import 'package:delivery_tracking_app/http_service.dart';
import 'package:flutter/material.dart';

class DeliveryBatchesPage extends StatefulWidget {
  const DeliveryBatchesPage({super.key});

  @override
  State<DeliveryBatchesPage> createState() => _DeliveryBatchesPageState();
}

class _DeliveryBatchesPageState extends State<DeliveryBatchesPage> {
  List<DeliveryBatch> deliveryBatches = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeliveryBatches();
  }

  getDeliveryBatches() async {
    var response = await HttpService().get('app/delivery_batches/');
    var decodedBody = jsonDecode(response.body);
    // setState(() {
    setState(() {
      for (var deliveryBatch in decodedBody) {
        deliveryBatches.add(parseDeliveryBatch(deliveryBatch));
      }
    });
    // });
  }

  DeliveryBatch parseDeliveryBatch(Map<String, dynamic> deliveryBatch) {
    List<Crate> crates = [];
    for (var crate in deliveryBatch['crates']) {
      crates.add(parseCrate(crate));
    }
    return DeliveryBatch(deliveryBatch['id'], crates);
  }

  Crate parseCrate(Map<String, dynamic> crate) {
    return Crate(crate['crate_id'], crate['contents']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Batches'),
      ),
      body: ListView.builder(
        itemCount: deliveryBatches.length,
        itemBuilder: (context, index) {
          final deliveryBatch = deliveryBatches[index];
          return GestureDetector(
            onTap: () async {
              // var response = await Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (cxt) => ContactDetailPage(
              //       contact: deliveryBatch,
              //     ),
              //   ),
              // );
              // if (response is FormResponse) {
              //   if (response.type == ResponseType.delete) {
              //     setState(() {
              //       contacts.remove(response.body);
              //     });
              //   } else if (response.type == ResponseType.edit) {
              //     setState(() {
              //       var index = contacts.indexOf(deliveryBatch);
              //       contacts[index] = response.body;
              //     });
              //   }
              // }
            },
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  child: Text(deliveryBatch.id.toString().toUpperCase()),
                ),
                title: Text("Batch #${deliveryBatch.id}"),
                trailing: const Icon(Icons.chevron_right_sharp),
              ),
            ),
          );
        },
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
        },
        child: const Icon(Icons.add),
        shape: CircleBorder(),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class Crate {
  String crateId;
  String contents;

  Crate(this.crateId, this.contents);
}

class DeliveryBatch {
  int id;
  List<Crate> crates;

  DeliveryBatch(this.id, this.crates);
}
