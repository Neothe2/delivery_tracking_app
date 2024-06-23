class Crate {
  String crateId;

  Crate(this.crateId);

  factory Crate.fromJson(Map<String, dynamic> json) {
    return Crate(json['crate_id']);
  }
}
