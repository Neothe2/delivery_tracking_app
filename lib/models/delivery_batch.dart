import 'package:delivery_tracking_app/interfaces/delivery_batch_interface.dart';
import 'package:delivery_tracking_app/models/vehicle.dart';

import 'address.dart';
import 'crate.dart';
import 'customer.dart';

class DeliveryBatch implements IDeliveryBatch {
  int id;
  List<Crate> crates = [];
  Vehicle? vehicle;
  Customer? customer;
  Address? address;
  bool draft = false;

  DeliveryBatch(this.id, this.crates, this.vehicle, this.customer, this.address,
      {this.draft = false}) {
    if (draft == false) {
      if (customer == null || address == null) {
        throw Exception("Missing vehicle, customer, or address");
      }
    }
  }

  factory DeliveryBatch.fromJson(Map<String, dynamic> json) {
    List<Crate> crates = [];
    for (var crate in json['crates']) {
      crates.add(Crate.fromJson(crate));
    }

    return DeliveryBatch(
      json['id'],
      crates,
      json['vehicle'] == null ? null : Vehicle.fromJson(json['vehicle']),
      json['customer'] == null ? null : Customer.fromJson(json['customer']),
      json['delivery_address'] == null
          ? null
          : Address.fromJson(json['delivery_address']),
    );
  }
}




// Customer parseCustomer(Map<String, dynamic> customerJson) {
//   return Customer(customerJson['id'], customerJson['name'],
//       customerJson['phone_number'], parseAddresses(customerJson['addresses']));
// }

// List<Address> parseAddresses(List<dynamic> addressJsonList) {
//   List<Address> returnList = [];
//   for (var address in addressJsonList) {
//     returnList.add(parseAddress(address));
//   }
//   return returnList;
// }

// Address parseAddress(Map<String, dynamic> addressJson) {
//   return Address(addressJson['id'], addressJson['value']);
// }

// Vehicle? parseVehicle(Map<String, dynamic>? vehicleData) {
//   if (vehicleData != null) {
//     return Vehicle(vehicleData['id'], vehicleData['license_plate'],
//         vehicleData['vehicle_type'], vehicleData['is_loaded']);
//   }
//   return null;
// }

// Crate parseCrate(Map<String, dynamic> crate) {
//   return Crate(crate['crate_id']);
// }

