import 'dart:convert';

import 'package:delivery_tracking_app/delivery_batches/add_delivery_batch.dart';
import 'package:delivery_tracking_app/delivery_batches/delivery_batch_detail.dart';
import 'package:delivery_tracking_app/http_service.dart';
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

  @override
  void initState() {
    super.initState();
    getDeliveryBatches();
  }

  getDeliveryBatches() async {
    deliveryBatches = [];
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
      parseAddress(deliveryBatch['delivery_address']),
    );
  }

  Customer parseCustomer(Map<String, dynamic> customerJson) {
    return Customer(
        customerJson['id'],
        customerJson['name'],
        customerJson['phone_number'],
        parseAddresses(customerJson['addresses']));
  }

  List<Address> parseAddresses(List<dynamic> addressJsonList) {
    List<Address> returnList = [];
    for (var address in addressJsonList) {
      returnList.add(parseAddress(address));
    }
    return returnList;
  }

  Address parseAddress(Map<String, dynamic> addressJson) {
    return Address(addressJson['id'], addressJson['value']);
  }

  Vehicle? parseVehicle(Map<String, dynamic>? vehicleData) {
    if (vehicleData != null) {
      return Vehicle(vehicleData['id'], vehicleData['license_plate'],
          vehicleData['vehicle_type'], vehicleData['is_loaded']);
    }
    return null;
  }

  Crate parseCrate(Map<String, dynamic> crate) {
    return Crate(crate['crate_id']);
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
        child: ListView.builder(
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
                      title: Text("To: ${deliveryBatch.customer.name}"),
                      subtitle: Text(deliveryBatch.address.value),
                      trailing: const Icon(Icons.chevron_right_sharp),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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
