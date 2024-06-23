class Address {
  int id;
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
