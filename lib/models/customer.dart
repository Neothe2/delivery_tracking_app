import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'address.dart';

part 'customer.g.dart';

@HiveType(typeId: 3)
class Customer {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String contactDetails;
  @HiveField(3)
  List<Address> addresses;

  Customer(this.id, this.name, this.contactDetails, this.addresses);

  //TODO: This isn't the responsibility of the customer class
  List<DropdownMenuItem<Address>> getAddressesAsDropdownItems() {
    var list = addresses.map((address) {
      return DropdownMenuItem<Address>(
        value: address,
        child: Text(address.value),
      );
    }).toList();

    return list;
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    List<Address> addresses = [];
    for (var addressJson in json['addresses']) {
      addresses.add(Address.fromJson(addressJson));
    }
    return Customer(json['id'], json['name'], json['phone_number'], addresses);
  }
}
