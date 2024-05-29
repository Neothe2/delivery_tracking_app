import 'package:flutter/material.dart';

import 'address.dart';

class Customer {
  int id;
  String name;
  String contactDetails;
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
}
