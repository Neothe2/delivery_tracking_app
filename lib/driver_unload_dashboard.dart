import 'dart:convert';

import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/proof_of_delivery/proof_of_delivery.dart';
import 'package:delivery_tracking_app/scan_crates.dart';
import 'package:flutter/material.dart';

import 'models/address.dart';
import 'models/crate.dart';
import 'models/customer.dart';
import 'models/delivery_batch.dart';
import 'models/driver.dart';
import 'models/vehicle.dart';

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

    if (deliveryBatches.isEmpty) {
      await finishUnloading();
      Navigator.pop(context);
    }

    setState(() {
      batchesLoaded = true;
    });
    // });
  }

  finishUnloading() async {
    var response = await HttpService().update(
        'app/vehicles/${widget.driver.currentVehicle!.id}/unload_vehicle/', {});
    // if (response.statusCode == 200) {
    //   Navigator.pop(context);
    // }
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
        title: const Text('Select batch to unload'),
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
                      builder: (cxt) => ScanCratesPage(
                        crateList: deliveryBatch.crates,
                        title: "Unload crates from delivery batch",
                        afterScanningFinished: () async {
                          await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (cxt) => ProofOfDeliveryPage(),
                            ),
                          );
                          // var unloadResponse = await HttpService().update(
                          //   'app/vehicles/${widget.driver.currentVehicle!.id}/unload_delivery_batch/',
                          //   {"id": deliveryBatch.id},
                          // );
                          // if (unloadResponse.statusCode == 200) {
                          //   await getDeliveryBatches();
                          // }
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
                        // backgroundColor: Colors.lightBlue,
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
