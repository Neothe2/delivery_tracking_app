import 'package:delivery_tracking_app/models/vehicle.dart';

class Driver {
  int id;
  String name;
  Vehicle? currentVehicle;

  Driver(this.id, this.name, this.currentVehicle);
}
