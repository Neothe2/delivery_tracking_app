// import 'dart:convert';
//
// import 'package:delivery_tracking_app/http_service.dart';
// import 'package:flutter/material.dart';
//
// import 'delivery_batches.dart';
//
// class AllocateVehiclePage extends StatefulWidget {
//   const AllocateVehiclePage({super.key});
//
//   @override
//   State<AllocateVehiclePage> createState() => _AllocateVehiclePageState();
// }
//
// class _AllocateVehiclePageState extends State<AllocateVehiclePage> {
//   List<VehicleAllocation> vehicleAllocations = [];
//   bool vehiclesLoaded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     getVehicles();
//   }
//
//   getVehicles() async {
//     var vehicleAllocationsResponse =
//         await HttpService().get('app/get_subscribed_vehicles/');
//     var totalVehicleSlots = jsonDecode(vehicleAllocationsResponse.body);
//     for (var i = 0; i < totalVehicleSlots; i++) {
//       vehicleAllocations.add(VehicleAllocation(null));
//     }
//     setState(() {
//       vehiclesLoaded = true;
//     });
//   }
//
//   Vehicle? parseVehicle(Map<String, dynamic>? vehicleData) {
//     if (vehicleData != null) {
//       return Vehicle(vehicleData['id'], vehicleData['license_plate'],
//           vehicleData['vehicle_type']);
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Subscribed Vehicles'),
//       ),
//       body: (vehiclesLoaded)
//           ? ListView.builder(
//               itemCount: vehicleAllocations.length,
//               itemBuilder: (context, index) {
//                 final vehicleAllocation = vehicleAllocations[index];
//                 return GestureDetector(
//                   onTap: () async {
//                     // var response = await Navigator.of(context).push(
//                     //   MaterialPageRoute(
//                     //     builder: (cxt) => ContactDetailPage(
//                     //       contact: deliveryBatch,
//                     //     ),
//                     //   ),
//                     // );
//                     // if (response is FormResponse) {
//                     //   if (response.type == ResponseType.delete) {
//                     //     setState(() {
//                     //       contacts.remove(response.body);
//                     //     });
//                     //   } else if (response.type == ResponseType.edit) {
//                     //     setState(() {
//                     //       var index = contacts.indexOf(deliveryBatch);
//                     //       contacts[index] = response.body;
//                     //     });
//                     //   }
//                     // }
//                   },
//                   child: vehicleAllocation.isAllocated
//                       ? Card(
//                           child: ListTile(
//                             leading: ElevatedButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     vehicleAllocation.deallocateVehicle();
//                                   });
//                                 },
//                                 child: const Icon(Icons.clear)),
//                             title: Text(
//                                 "${vehicleAllocation.vehicle.type}: ${vehicleAllocation.vehicle.licensePlate}"),
//                             trailing: const Icon(Icons.chevron_right_sharp),
//                           ),
//                         )
//                       : ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               // vehicleAllocation.allocateVehicle(
//                               //   Vehicle(1, 'KLO7 AS 1234', 'truck'),
//                               // );
//                             });
//                           },
//                           child: const Text('Allocate Vehicle')),
//                 );
//               },
//             )
//           : null,
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           // Contact newContact = await Navigator.of(context).push(
//           //   MaterialPageRoute(
//           //     builder: (cxt) => AddContact(),
//           //   ),
//           // );
//           // print(newContact);
//           // setState(() {
//           //   this.contacts.add(newContact);
//           // });
//         },
//         child: const Icon(Icons.add),
//         shape: CircleBorder(),
//         backgroundColor: Colors.deepOrangeAccent,
//         foregroundColor: Colors.white,
//       ),
//     );
//   }
// }
//
// class VehicleAllocation {
//   bool _isAllocated = false;
//   Vehicle? _vehicle;
//
//   get vehicle => _vehicle;
//
//   get isAllocated => _isAllocated;
//
//   VehicleAllocation(Vehicle? vehicle) {
//     if (vehicle != null) {
//       allocateVehicle(vehicle);
//     }
//   }
//
//   allocateVehicle(Vehicle vehicle) {
//     _isAllocated = true;
//     _vehicle = vehicle;
//   }
//
//   deallocateVehicle() {
//     _isAllocated = false;
//     _vehicle = null;
//   }
// }
