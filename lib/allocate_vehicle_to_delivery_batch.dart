import 'dart:convert';

import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/select_vehicle.dart';
import 'package:flutter/material.dart';

import 'add_delivery_batch.dart';
import 'delivery_batches.dart';

class AllocateVehicleToDeliveryBatch extends StatefulWidget {
  const AllocateVehicleToDeliveryBatch({super.key});

  @override
  State<AllocateVehicleToDeliveryBatch> createState() =>
      _AllocateVehicleToDeliveryBatchState();
}

class _AllocateVehicleToDeliveryBatchState
    extends State<AllocateVehicleToDeliveryBatch> {
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
            child: GestureDetector(
              onTap: () async {
                int? preselectedVehicle = (deliveryBatch.vehicle != null)
                    ? deliveryBatch.vehicle!.id
                    : null;
                var selectedVehicleId = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (cxt) {
                      return SelectVehiclePage(
                          preSelectedTruckId: preselectedVehicle);
                    },
                  ),
                );
                if (selectedVehicleId != null && selectedVehicleId != -1) {
                  var response = await HttpService().create(
                    'app/vehicles/$selectedVehicleId/assign_delivery_batch/',
                    {"id": deliveryBatch.id},
                  );
                  if (response.statusCode == 400) {
                    //TODO: Implement error handling
                  }
                  if (response.statusCode == 200) {
                    deliveryBatches = [];
                    getDeliveryBatches();
                  }
                }
              },
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        child: Text(deliveryBatch.id.toString().toUpperCase()),
                      ),
                      title: Text("To: ${deliveryBatch.address}"),
                      subtitle: (deliveryBatch.vehicle != null)
                          ? Text(
                              '${deliveryBatch.vehicle!.type}: ${deliveryBatch.vehicle!.licensePlate}')
                          : const Text('No vehicle assigned'),
                      trailing: const Icon(Icons.chevron_right_sharp),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
