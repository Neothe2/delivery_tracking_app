import 'package:hive_flutter/hive_flutter.dart';
part 'delivery_batch_draft.g.dart';

@HiveType(typeId: 1)
class DeliveryBatchDraft {
  @HiveField(0)
  List<String> crateIds;
  @HiveField(1)
  int? customerId;
  @HiveField(2)
  int? addressId;

  DeliveryBatchDraft(this.crateIds, this.customerId, this.addressId);
}
