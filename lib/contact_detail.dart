import 'dart:async';

import 'package:delivery_tracking_app/edit_contact.dart';
import 'package:delivery_tracking_app/form_response.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:flutter/material.dart';

import 'contacts.dart';

class ContactDetailPage extends StatefulWidget {
  final Contact contact;

  ContactDetailPage({super.key, required this.contact});

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(
        //       Icons.delete,
        //       color: Colors.white,
        //     ),
        //     style: ButtonStyle(
        //         backgroundColor: MaterialStatePropertyAll(Colors.red)),
        //     onPressed: () async {
        //       //TODO: Manage error handling
        //       bool confirmation = await showAlertDialog(context);
        //       if (confirmation) {
        //         HttpService().delete(
        //             'app/contacts/${widget.contact.id}/delete_contact_and_user/');
        //         Navigator.pop(
        //             context, FormResponse(ResponseType.delete, widget.contact));
        //       }
        //     },
        //   )
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Card(
                child: ListTile(title: Text('Name: ${widget.contact.name}')),
              ),
            ),
            ListTile(
                title: const Text(
                  'Login Enabled',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
                leading: Checkbox(
                  value: widget.contact.loginEnabled,
                  onChanged: (value) {},
                )),
            if (widget.contact.loginEnabled)
              Card(
                child: ListTile(
                    title:
                        Text('Username: ${widget.contact.user!['username']}')),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'Delete'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_square), label: 'Edit')
        ],
        currentIndex: 1,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.red,
        onTap: (index) async {
          switch (index) {
            case 1:
              var response = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditContact(contact: widget.contact),
                ),
              );
              if (response is Contact) {
                Contact editedContact = response;
                Navigator.pop(
                    context, FormResponse(ResponseType.edit, editedContact));
              }

            case 0:
              //TODO: Manage error handling
              bool confirmation = await showAlertDialog(context);
              if (confirmation) {
                HttpService().delete(
                    'app/contacts/${widget.contact.id}/delete_contact_and_user/');
                Navigator.pop(
                    context, FormResponse(ResponseType.delete, widget.contact));
              }
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {},
      //   child: Icon(Icons.edit_square),
      //   shape: CircleBorder(),
      //   backgroundColor: Colors.deepOrangeAccent,
      //   foregroundColor: Colors.white,
      // ),
    );
  }
}

Future<bool> showAlertDialog(BuildContext context) async {
  var returnBool = false;
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {
      returnBool = false;
      Navigator.pop(context);
    },
  );
  Widget continueButton = TextButton(
    child: Text("Delete"),
    onPressed: () {
      returnBool = true;
      Navigator.pop(context);
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Are you sure?"),
    content: Text("Are you sure you want to delete this contact?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );

  return returnBool;
}
