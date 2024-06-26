import 'dart:convert';

import 'package:delivery_tracking_app/allocate_vehicle_to_delivery_batch.dart';
import 'package:delivery_tracking_app/assign_driver.dart';
import 'package:delivery_tracking_app/confirmation_modal.dart';
import 'package:delivery_tracking_app/crates/crates_list.dart';
import 'package:delivery_tracking_app/custom_app_bar.dart';
import 'package:delivery_tracking_app/delivery_batches/delivery_batches.dart';
import 'package:delivery_tracking_app/driver_dash_board.dart';
import 'package:delivery_tracking_app/driver_unload_dashboard.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:delivery_tracking_app/login_page.dart';
import 'package:delivery_tracking_app/scan_crates.dart';
import 'package:flutter/material.dart';

import 'colour_constants.dart';
import 'models/contact.dart';
import 'models/crate.dart';
import 'models/driver.dart';
import 'models/user.dart';
import 'models/vehicle.dart';

enum TruckLoadingStates { loading, unloading, finished, noTruck }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List<String> _groups = [];

  // String _username = '...';

  //Initialized an empty user to block the exception but the correct user will be loaded later.
  User user = User(0, '', Contact(0, ''), []);
  bool userLoaded = false;

  List<Widget> listTiles = [];
  Driver? driver;
  bool driverLoaded = false;
  List<Crate> cratesToBeLoaded = [];

  // bool isVehicleTapped = false;

  bool loading = false;

  bool _isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _userIsDriver => user.groups.contains('driver');

  TruckLoadingStates? get _truckLoadingState {
    if (driver != null && driverLoaded) {
      if (cratesToBeLoaded.isEmpty && driver!.currentVehicle != null)
        return TruckLoadingStates.finished;
      else if (cratesToBeLoaded.isNotEmpty && driver!.currentVehicle!.isLoaded)
        return TruckLoadingStates.unloading;
      else if (cratesToBeLoaded.isNotEmpty && !driver!.currentVehicle!.isLoaded)
        return TruckLoadingStates.loading;
      else
        return TruckLoadingStates.noTruck;
    }
  }

  // get _groups => user.groups;
  // get _username => user.username;

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
      List<String> groups = [];
      for (var group in body['groups']) {
        groups.add(group['name']);
      }
      var contactData = body['contact'];
      var contact = Contact(contactData['id'], contactData['name']);
      user = User(body['id'], body['username'], contact, groups);
      userLoaded = true;

      // _username = body['username'];
      populateMenuItems();
    });

    if (_userIsDriver) {
      await getDriver(navigate);
    }
  }

  Future<void> getDriver(bool navigate) async {
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

  _buildAppBar() {
    return CustomAppBar(
      title: (_userIsDriver) ? 'Hello ${user.contact.name},' : 'Home page',
    );
  }

  _buildBody() {
    return RefreshIndicator(
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
              ? (driverLoaded || (userLoaded && !_userIsDriver))
                  ? Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center vertically
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        // Driver information card
                        if (_userIsDriver) _buildVehicleCard(),

                        (driver != null)
                            ? const SizedBox(height: 50)
                            : const SizedBox(
                                height: 250,
                              ),

                        // Welcome message or instructions
                        if (!_userIsDriver) _buildUserGreetingMessage(),
                        if (_truckLoadingState == TruckLoadingStates.finished)
                          _buildAllDoneMessage(),
                        (driver != null)
                            ? const SizedBox(height: 50)
                            : const SizedBox(
                                height: 300,
                              ),

                        // Action buttons

                        if (_truckLoadingState == TruckLoadingStates.loading)
                          _buildGoToLoadingPageButton(),

                        if (_truckLoadingState == TruckLoadingStates.unloading)
                          _buildGoToUnloadingPageButton(),
                        if (_truckLoadingState == TruckLoadingStates.unloading)
                          _buildReloadCratesButton(),

                        if (driver != null)
                          (cratesToBeLoaded.isNotEmpty)
                              ? const SizedBox(height: 182)
                              : (driver!.currentVehicle != null)
                                  ? const SizedBox(
                                      height:
                                          100, //Spacing between login when done
                                    )
                                  : const SizedBox(
                                      height: 165,
                                    ), //spacing between logout when no truck

                        // Logout button
                        _buildLogoutButton(),
                        const SizedBox(height: 50),
                      ],
                    )
                  : const CircularProgressIndicator()
              : const CircularProgressIndicator(), // Show loading indicator
        ),
      ),
    );
  }

  _buildDrawer() {
    return (listTiles.isNotEmpty)
        ? Drawer(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      ...listTiles,
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    bool confirmation = await confirmationModal(
                        context: context,
                        header: "Are You Sure?",
                        message: "Are you sure you want to log out?");
                    if (confirmation) {
                      logOut();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(ColorPalette.greenDark),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: const Text('Log out'),
                )
              ],
            ),
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      resizeToAvoidBottomInset: true,
      body: _buildBody(),
      drawer: _buildDrawer(),
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
    listTiles.add(ListTile(
      leading: CircleAvatar(
        child: Text(user.contact.name[0]),
      ),
      title: Text(user.contact.name),
    ));
    listTiles.add(const Divider(
      height: 1,
      color: ColorPalette.greenDarker,
      thickness: 1,
      indent: 10,
      endIndent: 10,
    ));
    if (user.groups.contains('billing_staff') ||
        user.groups.contains('admin') ||
        user.groups.contains('pierr_admin')) {
      addMenuItem('Delivery Batches', () {
        _scaffoldKey.currentState!.closeDrawer();
        Navigator.of(context).push(
            MaterialPageRoute(builder: (cxt) => const DeliveryBatchesPage()));
      });
      addMenuItem('Crates', () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (cxt) => CratesListPage()));
      });
    }
    if (user.groups.contains('transport_allocation_staff') ||
        user.groups.contains('admin') ||
        user.groups.contains('pierr_admin')) {
      addMenuItem('Delivery Batches', () {
        _scaffoldKey.currentState!.closeDrawer();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (cxt) => const AllocateVehicleToDeliveryBatch(),
          ),
        );
      });

      addMenuItem('Assign Driver', () {
        _scaffoldKey.currentState!.closeDrawer();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (cxt) => const AssignDriverToVehiclePage(),
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
    var storage = SecureTokenStorage();
    storage.delete(key: 'access');
    storage.delete(key: 'refresh');
    HttpService().setAccessToken("");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (cxt) => LoginPage(
          JWTAuthenticationService(
            SecureTokenStorage(),
          ),
        ),
      ),
    );
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

  _buildVehicleCard() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: (driver!.currentVehicle != null &&
                driver!.currentVehicle!.isLoaded == true)
            ? 320
            : 260,
        child: Container(
          // Add bounce effect
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: const Border.fromBorderSide(
              BorderSide(color: Colors.grey),
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Assigned Vehicle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.fire_truck,
                        size: 50,
                        color: ColorPalette.greenDark,
                      )
                    ],
                  ),
                  const SizedBox(height: 15), // Add spacing
                  (driver!.currentVehicle != null)
                      ? Text(
                          '${driver!.currentVehicle!.licensePlate}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: ColorPalette.greenDarker),
                        )
                      : const Text(
                          "You don't have any vehicles assigned to you. \n Contact your transport allocation staff\n if this isn't supposed to happen.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildLogoutButton() {
    return OutlinedButton(
      onPressed: () async {
        bool confirmation = await confirmationModal(
            context: context,
            header: "Are You Sure?",
            message: "Are you sure you want to log out?");
        if (confirmation) {
          logOut();
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(ColorPalette.greenDark),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: const Text('Log out'),
    );
  }

  _buildReloadCratesButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: 320,
        child: OutlinedButton(
          onPressed: () async {
            var loadUpdateResponse = await HttpService().partial_update(
                'app/vehicles/${driver!.currentVehicle!.id}/',
                {"is_loaded": false});
            print(loadUpdateResponse.body);

            if (loadUpdateResponse.statusCode == 200) {
              var scanCratesResponse = await Navigator.of(context).push(
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
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)))),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                Text(
                  'Reload Crates',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Icon(Icons.refresh)
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildGoToUnloadingPageButton() {
    return SizedBox(
      width: 320,
      child: ElevatedButton(
        onPressed: () async {
          var response = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (cxt) => DriverUnloadDashBoard(
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
          backgroundColor: MaterialStatePropertyAll(ColorPalette.green),
          foregroundColor:
              MaterialStatePropertyAll(ColorPalette.backgroundWhite),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 0,
              ),
              Text(
                'Go to Unloading Page',
                style: TextStyle(fontSize: 20),
              ),
              Icon(
                Icons.play_arrow,
                size: 40,
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildGoToLoadingPageButton() {
    SizedBox(
      width: 260,
      child: ElevatedButton(
        onPressed: () async {
          var response = await Navigator.of(context).push(
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
          backgroundColor: MaterialStatePropertyAll(ColorPalette.green),
          foregroundColor:
              MaterialStatePropertyAll(ColorPalette.backgroundWhite),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 0,
              ),
              Text(
                'Start Loading',
                style: TextStyle(fontSize: 20),
              ),
              Icon(
                Icons.play_arrow,
                size: 40,
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildUserGreetingMessage() {
    return SizedBox(
      width: 260,
      child: Text(
        'Hello, ${user.username}',
        style: const TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      ),
    );
  }

  _buildAllDoneMessage() {
    return const SizedBox(
      width: 260,
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_outlined,
            size: 200,
            color: ColorPalette.green,
          ),
          Text(
            'All done!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
