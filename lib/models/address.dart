import 'package:hive_flutter/hive_flutter.dart';

part 'address.g.dart';

@HiveType(typeId: 4)
class Address {
  @HiveField(0)
  int id;
  @HiveField(1)
  String value;

  Address(this.id, this.value);

  @override
  operator ==(other) =>
      other is Address && other.id == id && other.value == value;

  @override
  int get hashCode => Object.hash(id, value);

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(json['id'], json['value']);
  }
}
