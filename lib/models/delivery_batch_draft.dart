import 'package:delivery_tracking_app/interfaces/delivery_batch_interface.dart';
import 'package:delivery_tracking_app/models/crate.dart';
import 'package:delivery_tracking_app/models/customer.dart';
import 'package:delivery_tracking_app/models/address.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'delivery_batch_draft.g.dart';

@HiveType(typeId: 1)
class DeliveryBatchDraft implements IDeliveryBatch {
  @HiveField(0)
  List<Crate> crates;
  @HiveField(1)
  Customer? customer;
  @HiveField(2)
  Address? address;

  DeliveryBatchDraft(this.crates, this.customer, this.address);
}
