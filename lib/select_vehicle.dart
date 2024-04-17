import 'dart:convert';

import 'package:delivery_tracking_app/delivery_batches.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/searchable_list.dart';
import 'package:flutter/material.dart';

class SelectVehiclePage extends StatefulWidget {
  final int? preSelectedTruckId;

  const SelectVehiclePage({super.key, this.preSelectedTruckId});

  @override
  State<SelectVehiclePage> createState() => _SelectVehiclePageState();
}

class _SelectVehiclePageState extends State<SelectVehiclePage> {
  List<Vehicle> vehicleList = [];
  bool vehiclesLoaded = false;
  int selectedVehicleId = -1;

  @override
  void initState() {
    super.initState();
    getVehicles();
  }

  void getVehicles() async {
    var response = await HttpService().get('app/vehicles/');
    setState(() {
      for (var vehicleJson in jsonDecode(response.body)) {
        vehicleList.add(
          parseVehicle(vehicleJson),
        );
      }
      vehiclesLoaded = true;
    });
  }

  Vehicle parseVehicle(Map<String, dynamic> vehicleData) {
    return Vehicle(vehicleData['id'], vehicleData['license_plate'],
        vehicleData['vehicle_type'], vehicleData['is_loaded']);
  }

  @override
  Widget build(BuildContext context) {
    print(vehicleList);
    List<MapEntry<String, dynamic>> selectableListViewList = vehicleList
        .map(
          (e) => MapEntry("${e.type}: ${e.licensePlate}", e),
        )
        .toList();

    var preselectedvalue;
    for (var vehicle in vehicleList) {
      if (vehicle.id == widget.preSelectedTruckId) {
        preselectedvalue = vehicle;
      }

      print(preselectedvalue);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Vehicle to Allocate'),
      ),
      resizeToAvoidBottomInset: true,
      body: vehiclesLoaded
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      height: 450,
                      decoration: BoxDecoration(
                        border: const Border.fromBorderSide(
                          BorderSide(color: Colors.grey),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SelectableListView(
                          checkboxes: true,
                          radioButtons: true,
                          preSelectedValues: (preselectedvalue != null)
                              ? [preselectedvalue]
                              : [],
                          items: selectableListViewList,
                          onSelectionChanged: (List<dynamic> selectionChanged) {
                            selectedVehicleId = (selectionChanged.isNotEmpty)
                                ? selectionChanged[0].id
                                : -1;
                          }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.10),
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context, selectedVehicleId);
                        // DeliveryBatch deliveryBatch =
                        //     parseDeliveryBatch(response.body);
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      child: const Text('Select Vehicle'),
                    ),
                  )
                ],
              ),
            )
          : const Text('Loading...'),
    );
  }
}
