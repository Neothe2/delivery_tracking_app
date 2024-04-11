import 'dart:convert';

import 'package:delivery_tracking_app/allocate_vehicle_to_delivery_batch.dart';
import 'package:delivery_tracking_app/assign_driver.dart';
import 'package:delivery_tracking_app/delivery_batches.dart';
import 'package:delivery_tracking_app/driver_dash_board.dart';
import 'package:delivery_tracking_app/driver_unload_dashboard.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/scan_crates.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final accessToken;

  const HomePage({super.key, required this.accessToken});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> groups = [];
  String username = '...';
  late User user;
  List<ListTile> listTiles = [];
  Driver? driver;
  bool driverLoaded = false;
  List<Crate> cratesToBeLoaded = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getGroup();
    //navigateToUnloadDashBoard();
  }

  Future<void> getGroup({bool navigate = true}) async {
    // groups = [];
    // // username = '...';
    // // // user = null;
    // listTiles = [];
    // // driver = null;
    // driverLoaded = false;
    cratesToBeLoaded = [];

    var response = await HttpService().get('auth/users/me/');
    var body = jsonDecode(response.body);

    setState(() {
      print(body);
      for (var group in body['groups']) {
        groups.add(group['name']);
      }
      var contactData = body['contact'];
      var contact = Contact(contactData['id'], contactData['name']);
      user = User(body['id'], body['username'], contact);

      username = body['username'];
      populateMenuItems();
    });

    if (groups.contains('driver')) {
      var driverResponse =
          await HttpService().get('app/drivers/get_driver_of_user/');
      var driverData = jsonDecode(driverResponse.body);
      driver = Driver(driverData['id'], driverData['contact']['name'],
          parseVehicle(driverData['current_vehicle']));
      if (driver!.currentVehicle != null) {
        var cratesResponse = await HttpService().get(
            'app/vehicles/${driver!.currentVehicle!.id}/get_crates_of_vehicle/');
        var cratesData = jsonDecode(cratesResponse.body);
        for (var crate in cratesData) {
          cratesToBeLoaded.add(Crate(crate['crate_id']));
        }
      }
      setState(() {
        driverLoaded = true;
      });
      if (navigate) {
        await navigateToUnloadDashboard();
      }
    }
  }

  navigateToUnloadDashboard() async {
    if (driverLoaded &&
        driver!.currentVehicle != null &&
        driver!.currentVehicle!.isLoaded == true) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (cxt) => DriverUnloadDashBoard(driver: driver!),
        ),
      );

      setState(() {
        driverLoaded = false;
      });
      await getGroup(navigate: false);
    }
  }

  Vehicle? parseVehicle(Map<String, dynamic>? vehicleData) {
    if (vehicleData != null) {
      return Vehicle(vehicleData['id'], vehicleData['license_plate'],
          vehicleData['vehicle_type'], vehicleData['is_loaded']);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (groups.contains('driver'))
            ? Text('Hello ${user.contact.name}')
            : const Text('Home page'),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: (driverLoaded || !groups.contains('driver'))
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  // ignore: prefer_const_constructors
                  if (groups.contains('driver'))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (driverLoaded)
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Assigned Vehicle',
                                          style: TextStyle(
                                              fontSize: 20,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: (driver!.currentVehicle !=
                                                  null)
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    '${driver!.currentVehicle!.type}: ${driver!.currentVehicle!.licensePlate}',
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        TextStyle(fontSize: 25),
                                                  ),
                                                )
                                              : const Text(
                                                  "You don't have any vehicles assigned to you. \n Contact your transport allocation staff\n if this isn't supposed to happen.",
                                                  textAlign: TextAlign.center,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const Text('Loading...'),
                      ],
                    ),
                  SizedBox(
                    height: 150,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      (!groups.contains('driver'))
                          ? Expanded(
                              child: Text(
                              'Hello, $username',
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ))
                          : Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50.0, vertical: 20),
                                child: (driver != null &&
                                        driverLoaded &&
                                        cratesToBeLoaded.isNotEmpty)
                                    ? (driverLoaded &&
                                            driver!.currentVehicle != null &&
                                            driver!.currentVehicle!.isLoaded ==
                                                false)
                                        ? Text(
                                            "When you're ready to start loading, press the start loading button",
                                            textAlign: TextAlign.center,
                                          )
                                        : const Text(
                                            'Click "Go to unloading page"')
                                    : const Text(
                                        'There is nothing in your vehicle',
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                            ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          if (driver != null &&
                              driverLoaded &&
                              cratesToBeLoaded.isNotEmpty)
                            (driverLoaded &&
                                    driver!.currentVehicle != null &&
                                    driver!.currentVehicle!.isLoaded == false)
                                ? OutlinedButton(
                                    style: ButtonStyle(
                                        // MaterialStatePropertyAll(Colors.white),
                                        // foregroundColor:
                                        //     MaterialStatePropertyAll(
                                        //         Colors.blue),
                                        shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10)))),
                                    onPressed: () async {
                                      var response =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (cxt) => ScanCratesPage(
                                            title: 'Load Crates',
                                            afterScanningFinished: () {
                                              afterScanningFinished();
                                            },
                                            crateList: cratesToBeLoaded,
                                          ),
                                        ),
                                      );

                                      getGroup();
                                      //navigateToUnloadDashboard
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Start Loading',
                                        style: TextStyle(fontSize: 50),
                                      ),
                                    ))
                                : OutlinedButton(
                                    style: ButtonStyle(
                                        // MaterialStatePropertyAll(Colors.white),
                                        // foregroundColor:
                                        //     MaterialStatePropertyAll(
                                        //         Colors.blue),
                                        shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10)))),
                                    onPressed: () async {
                                      var response =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (cxt) =>
                                              DriverUnloadDashBoard(
                                            driver: driver!,
                                          ),
                                        ),
                                      );
                                      setState(() {
                                        driverLoaded = false;
                                      });
                                      await getGroup(navigate: false);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Go to \nunloading page',
                                        style: TextStyle(fontSize: 40),
                                        textAlign: TextAlign.center,
                                      ),
                                    ))
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 150,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          OutlinedButton(
                              onPressed: () {
                                logOut();
                              },
                              child: Text('Log out'))
                        ],
                      )
                    ],
                  ),
                ],
              )
            : const Text('Loading...'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [...listTiles],
        ),
      ),
    );
  }

  populateMenuItems() {
    // if (groups.contains('admin')) {
    //   addMenuItem('Contacts', () {
    //     print('Navigating to contacts');
    //     Navigator.of(context)
    //         .push(MaterialPageRoute(builder: (context) => ContactsPage()));
    //   });
    // }
    if (groups.contains('billing_staff')) {
      addMenuItem('Delivery Batches', () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (cxt) => DeliveryBatchesPage()));
      });
    }
    if (groups.contains('transport_allocation_staff')) {
      addMenuItem('Delivery Batches', () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (cxt) => AllocateVehicleToDeliveryBatch(),
          ),
        );
      });

      addMenuItem('Assign Driver', () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (cxt) => AssignDriverToVehiclePage(),
          ),
        );
      });
    }
  }

  addMenuItem(String text, VoidCallback callback) {
    var listTile = ListTile(
      title: Text(text),
      onTap: callback,
    );
    listTiles.add(listTile);
  }

  logOut() {
    HttpService().setAccessToken("");
    Navigator.pop(context);
  }

  void driverDashBoard() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const DriverDashBoard()));
  }

  afterScanningFinished() async {
    var loadResponse = await HttpService()
        .update('app/vehicles/${driver!.currentVehicle!.id}/load_vehicle/', {});
    if (loadResponse.statusCode == 200) {
      Navigator.pop(context);
    }
  }
}

class User {
  int id;
  String username;
  Contact contact;

  User(this.id, this.username, this.contact);
}

class Contact {
  int id;
  String name;

  Contact(this.id, this.name);
}
