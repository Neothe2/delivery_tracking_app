class Vehicle {
  int id;
  String licensePlate;
  String type;
  bool isLoaded;

  Vehicle(this.id, this.licensePlate, this.type, this.isLoaded);

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(json['id'], json['license_plate'], json['vehicle_type'],
        json['is_loaded']);
  }
}
