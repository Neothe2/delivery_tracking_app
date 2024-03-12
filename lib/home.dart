import 'dart:convert';

import 'package:delivery_tracking_app/contacts.dart';
import 'package:delivery_tracking_app/delivery_batches.dart';
import 'package:delivery_tracking_app/driver_dash_board.dart';
import 'package:delivery_tracking_app/http_service.dart';
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
  List<ListTile> listTiles = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getGroup();
  }

  Future<void> getGroup() async {
    var response = await HttpService().get('auth/users/me/');
    var body = jsonDecode(response.body);
    setState(() {
      print(body);
      for (var group in body['groups']) {
        groups.add(group['name']);
      }
      username = body['username'];
      populateMenuItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Text(
                'Hello, $username',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      driverDashBoard();
                    },
                    child: Text(
                      'Open Menu',
                    ),
                  ),
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
      ),
      drawer: Drawer(
        child: ListView(
          children: [...listTiles],
        ),
      ),
    );
  }

  populateMenuItems() {
    if (groups.contains('admin')) {
      addMenuItem('Contacts', () {
        print('Navigating to contacts');
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ContactsPage()));
      });
    }
    if (groups.contains('billing_staff')) {
      addMenuItem('Delivery Batches', () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (cxt) => DeliveryBatchesPage()));
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
}
