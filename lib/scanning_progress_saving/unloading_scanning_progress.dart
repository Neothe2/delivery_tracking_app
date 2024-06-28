import 'package:delivery_tracking_app/models/crate.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'unloading_scanning_progress.g.dart';

@HiveType(typeId: 6)
class UnloadingScanningProgress {
  @HiveField(0)
  List<Crate> crates = [];
  @HiveField(1)
  int deliveryBatchId;

  UnloadingScanningProgress(
      {required this.crates, required this.deliveryBatchId});
}
