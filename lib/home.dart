import 'dart:convert';

import 'package:delivery_tracking_app/allocate_vehicle_to_delivery_batch.dart';
import 'package:delivery_tracking_app/assign_driver.dart';
import 'package:delivery_tracking_app/delivery_batches/delivery_batches.dart';
import 'package:delivery_tracking_app/driver_dash_board.dart';
import 'package:delivery_tracking_app/driver_unload_dashboard.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/login_page.dart';
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

  bool isVehicleTapped = false;

  bool loading = false;

  bool _isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
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
    listTiles = [];

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
      key: _scaffoldKey,
      appBar: AppBar(
        title: (groups.contains('driver'))
            ? Text('Hello ${user.contact.name},')
            : const Text('Home page'),
      ),
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isLoading = true; // Set loading state to true
          });
          await getGroup();
          setState(() {
            _isLoading = false; // Set loading state to false
          });
        },
        child: SingleChildScrollView(
          child: Center(
            // Center the content horizontally
            child: (!_isLoading)
                ? (driverLoaded || !groups.contains('driver'))
                    ? Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center vertically
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 50),
                          // Driver information card
                          if (groups.contains('driver'))
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SizedBox(
                                width: 260,
                                child: Container(
                                  // Add bounce effect
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.fromBorderSide(
                                      BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  transform: Matrix4.identity()
                                    ..scale(isVehicleTapped ? 0.95 : 1.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: SizedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Assigned Vehicle',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 15), // Add spacing
                                          (driver!.currentVehicle != null)
                                              ? Text(
                                                  '${driver!.currentVehicle!.type}: ${driver!.currentVehicle!.licensePlate}',
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                  ),
                                                )
                                              : Text(
                                                  "You don't have any vehicles assigned to you. \n Contact your transport allocation staff\n if this isn't supposed to happen.",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          (driver != null)
                              ? SizedBox(height: 50)
                              : SizedBox(
                                  height: 250,
                                ),

                          // Welcome message or instructions
                          SizedBox(
                            width: 260,
                            child: Text(
                              (groups.contains('driver'))
                                  ? (driverLoaded &&
                                          cratesToBeLoaded.isNotEmpty)
                                      ? (driver!.currentVehicle!.isLoaded ==
                                              false)
                                          ? "When you're ready to start loading, press the button below."
                                          : 'Click "Go to unloading page" to proceed.'
                                      : 'There is nothing in your vehicle.'
                                  : 'Hello, $username',
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          (driver != null)
                              ? SizedBox(height: 50)
                              : SizedBox(
                                  height: 300,
                                ),

                          // Action buttons
                          if (driver != null &&
                              driverLoaded &&
                              cratesToBeLoaded.isNotEmpty) ...[
                            (driver!.currentVehicle!.isLoaded == false)
                                ? SizedBox(
                                    width: 260,
                                    child: ElevatedButton(
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
                                      style: ButtonStyle(
                                          shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'Start Loading',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
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
                                    style: ButtonStyle(
                                        shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10)))),
                                    child: const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Go to Unloading Page',
                                        style: TextStyle(fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                          ],

                          if (driver != null &&
                              driverLoaded &&
                              cratesToBeLoaded.isNotEmpty &&
                              driver!.currentVehicle!.isLoaded == true)
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: OutlinedButton(
                                onPressed: () async {
                                  var loadUpdateResponse = await HttpService()
                                      .partial_update(
                                          'app/vehicles/${driver!.currentVehicle!.id}/',
                                          {"is_loaded": false});
                                  print(loadUpdateResponse.body);

                                  if (loadUpdateResponse.statusCode == 200) {
                                    var scanCratesResponse =
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
                                  }

                                  getGroup(navigate: false);
                                  //navigateToUnloadDashboard
                                },
                                style: ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)))),
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Reload Crates',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          if (driver != null)
                            (cratesToBeLoaded.isNotEmpty)
                                ? SizedBox(height: 182)
                                : (driver!.currentVehicle != null)
                                    ? SizedBox(
                                        height: 272,
                                      )
                                    : SizedBox(
                                        height: 165,
                                      ),

                          // Logout button
                          OutlinedButton(
                            onPressed: () {
                              logOut();
                            },
                            style: ButtonStyle(
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)))),
                            child: Text('Log out'),
                          ),
                          SizedBox(height: 50),
                        ],
                      )
                    : CircularProgressIndicator()
                : CircularProgressIndicator(), // Show loading indicator
          ),
        ),
      ),
      drawer: (listTiles.isNotEmpty)
          ? Drawer(
              child: ListView(
                children: [...listTiles],
              ),
            )
          : null,
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
        _scaffoldKey.currentState!.closeDrawer();
        Navigator.of(context).push(
            MaterialPageRoute(builder: (cxt) => const DeliveryBatchesPage()));
      });
    }
    if (groups.contains('transport_allocation_staff')) {
      addMenuItem('Delivery Batches', () {
        _scaffoldKey.currentState!.closeDrawer();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (cxt) => AllocateVehicleToDeliveryBatch(),
          ),
        );
      });

      addMenuItem('Assign Driver', () {
        _scaffoldKey.currentState!.closeDrawer();
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
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (cxt) => LoginPage()));
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
