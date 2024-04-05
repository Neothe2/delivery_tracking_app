import 'dart:convert';

import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/select_vehicle.dart';
import 'package:flutter/material.dart';

import 'add_delivery_batch.dart';
import 'delivery_batches.dart';

class AssignDriverToVehiclePage extends StatefulWidget {
  const AssignDriverToVehiclePage({super.key});

  @override
  State<AssignDriverToVehiclePage> createState() =>
      _AssignDriverToVehiclePageState();
}

class _AssignDriverToVehiclePageState extends State<AssignDriverToVehiclePage> {
  List<Driver> drivers = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDrivers();
  }

  getDrivers() async {
    var response = await HttpService().get('app/drivers/');
    var decodedBody = jsonDecode(response.body);
    // setState(() {
    setState(() {
      for (var driver in decodedBody) {
        drivers.add(parseDriver(driver));
      }
    });
    // });
  }

  Driver parseDriver(Map<String, dynamic> driver) {
    Vehicle? currentVehicle = parseVehicle(driver['current_vehicle']);

    return Driver(driver['id'], driver['contact']['name'], currentVehicle);
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
        title: const Text('Choose driver to assign vehicle to'),
      ),
      body: ListView.builder(
        itemCount: drivers.length,
        itemBuilder: (context, index) {
          final driver = drivers[index];
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
                int? preselectedVehicle = (driver.currentVehicle != null)
                    ? driver.currentVehicle!.id
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
                    'app/vehicles/$selectedVehicleId/assign_driver/',
                    {"id": driver.id},
                  );
                  if (response.statusCode == 400) {
                    //TODO: Implement error handling
                  }
                  if (response.statusCode == 200) {
                    drivers = [];
                    getDrivers();
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
                        child: Text(driver.id.toString().toUpperCase()),
                      ),
                      title: Text(driver.name),
                      subtitle: (driver.currentVehicle != null)
                          ? Text(
                              '${driver.currentVehicle!.type}: ${driver.currentVehicle!.licensePlate}')
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

class Driver {
  int id;
  String name;
  Vehicle? currentVehicle;

  Driver(this.id, this.name, this.currentVehicle);
}
