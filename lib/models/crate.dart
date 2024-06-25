import 'package:hive_flutter/hive_flutter.dart';

part 'crate.g.dart';

@HiveType(typeId: 2)
class Crate {
  @HiveField(0)
  String crateId;

  Crate(this.crateId);

  factory Crate.fromJson(Map<String, dynamic> json) {
    return Crate(json['crate_id']);
  }
}
