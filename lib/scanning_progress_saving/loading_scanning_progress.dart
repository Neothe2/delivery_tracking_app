import 'package:delivery_tracking_app/models/crate.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'loading_scanning_progress.g.dart';

@HiveType(typeId: 5)
class LoadingScanningProgress {
  @HiveField(0)
  List<Crate> crates = [];

  LoadingScanningProgress({required this.crates});
}
