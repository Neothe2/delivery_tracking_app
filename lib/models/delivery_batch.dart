import 'package:delivery_tracking_app/models/vehicle.dart';

import 'address.dart';
import 'crate.dart';
import 'customer.dart';

class DeliveryBatch {
  int id;
  List<Crate> crates;
  Vehicle? vehicle;
  Customer customer;
  Address address;

  DeliveryBatch(
      this.id, this.crates, this.vehicle, this.customer, this.address);
}
