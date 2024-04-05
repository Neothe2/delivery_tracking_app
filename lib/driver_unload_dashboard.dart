import 'dart:convert';

import 'package:delivery_tracking_app/add_delivery_batch.dart';
import 'package:delivery_tracking_app/assign_driver.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/scan_crates.dart';
import 'package:flutter/material.dart';

import 'delivery_batches.dart';

class DriverUnloadDashBoard extends StatefulWidget {
  final Driver driver;

  const DriverUnloadDashBoard({super.key, required this.driver});

  @override
  State<DriverUnloadDashBoard> createState() => _DriverUnloadDashBoardState();
}

class _DriverUnloadDashBoardState extends State<DriverUnloadDashBoard> {
  List<DeliveryBatch> deliveryBatches = [];
  bool batchesLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeliveryBatches();
  }

  getDeliveryBatches() async {
    var response = await HttpService()
        .get('app/vehicles/${widget.driver.currentVehicle!.id}/');
    var decodedBody = jsonDecode(response.body);
    // setState(() {
    deliveryBatches = [];
    for (var deliveryBatch in decodedBody['delivery_batches']) {
      deliveryBatches.add(parseDeliveryBatch(deliveryBatch));
    }
    setState(() {
      batchesLoaded = true;
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
        title: Text('Select batch to unload'),
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
                    builder: (cxt) => ScanCratesPage(
                      crateList: deliveryBatch.crates,
                      title: "Unload crates from delivery batch",
                      afterScanningFinished: () async {
                        var unloadResponse = await HttpService().update(
                          'app/vehicles/${widget.driver.currentVehicle!.id}/unload_delivery_batch/',
                          {"id": deliveryBatch.id},
                        );
                        if (unloadResponse.statusCode == 200) {
                          getDeliveryBatches();
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
                if (response == true) {
                  setState(() {
                    deliveryBatches = [];
                  });
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

// class Crate {
//   String crateId;
//   String contents;
//
//   Crate(this.crateId, this.contents);
// }
//
// class Vehicle {
//   int id;
//   String licensePlate;
//   String type;
//
//   Vehicle(this.id, this.licensePlate, this.type);
// }
//
// class DeliveryBatch {
//   int id;
//   List<Crate> crates;
//   Vehicle? vehicle;
//   Customer customer;
//   String address;
//
//   DeliveryBatch(
//       this.id, this.crates, this.vehicle, this.customer, this.address);
// }