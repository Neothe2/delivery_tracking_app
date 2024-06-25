import 'package:delivery_tracking_app/models/address.dart';
import 'package:delivery_tracking_app/models/crate.dart';
import 'package:delivery_tracking_app/models/customer.dart';

abstract class IDeliveryBatch {
  List<Crate> get crates;
  Customer? get customer;
  Address? get address;
}
