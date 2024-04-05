import 'dart:convert';

import 'package:delivery_tracking_app/add_delivery_batch.dart';
import 'package:delivery_tracking_app/delivery_batch_detail.dart';
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

    return DeliveryBatch(
      deliveryBatch['id'],
      crates,
      parseVehicle(deliveryBatch['vehicle']),
      parseCustomer(deliveryBatch['customer']),
      deliveryBatch['delivery_address'],
    );
  }

  Customer parseCustomer(Map<String, dynamic> customerJson) {
    return Customer(customerJson['id'], customerJson['name'],
        customerJson['contact_details']);
  }

  Vehicle? parseVehicle(Map<String, dynamic>? vehicleData) {
    if (vehicleData != null) {
      return Vehicle(vehicleData['id'], vehicleData['license_plate'],
          vehicleData['vehicle_type'], vehicleData['is_loaded']);
    }
    return null;
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
            onTap: () async {},
            child: GestureDetector(
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
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    child: Text(deliveryBatch.id.toString().toUpperCase()),
                  ),
                  title: Text("To: ${deliveryBatch.customer.name}"),
                  subtitle: Text(deliveryBatch.address),
                  trailing: const Icon(Icons.chevron_right_sharp),
                ),
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
}

class Crate {
  String crateId;
  String contents;

  Crate(this.crateId, this.contents);
}

class Vehicle {
  int id;
  String licensePlate;
  String type;
  bool isLoaded;

  Vehicle(this.id, this.licensePlate, this.type, this.isLoaded);
}

class DeliveryBatch {
  int id;
  List<Crate> crates;
  Vehicle? vehicle;
  Customer customer;
  String address;

  DeliveryBatch(
      this.id, this.crates, this.vehicle, this.customer, this.address);
}
