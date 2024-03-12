import 'dart:convert';

import 'package:delivery_tracking_app/add_contact.dart';
import 'package:delivery_tracking_app/contact_detail.dart';
import 'package:delivery_tracking_app/form_response.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContacts();
  }

  getContacts() async {
    var response = await HttpService().get('app/contacts/');
    var decodedBody = jsonDecode(response.body);
    // setState(() {
    setState(() {
      for (var contact in decodedBody) {
        contacts.add(parseContact(contact));
      }
    });
    // });
  }

  Contact parseContact(Map<String, dynamic> contact) {
    return Contact(contact['name'], contact['login_enabled'], contact['user'],
        contact['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return GestureDetector(
            onTap: () async {
              var response = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (cxt) => ContactDetailPage(
                    contact: contact,
                  ),
                ),
              );
              if (response is FormResponse) {
                if (response.type == ResponseType.delete) {
                  setState(() {
                    contacts.remove(response.body);
                  });
                } else if (response.type == ResponseType.edit) {
                  setState(() {
                    var index = contacts.indexOf(contact);
                    contacts[index] = response.body;
                  });
                }
              }
            },
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  child: Text(contact.name[0].toUpperCase()),
                ),
                title: Text(contact.name),
                trailing: const Icon(Icons.chevron_right_sharp),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Contact newContact = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (cxt) => AddContact(),
            ),
          );
          print(newContact);
          setState(() {
            this.contacts.add(newContact);
          });
        },
        child: const Icon(Icons.add),
        shape: CircleBorder(),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class Contact {
  int id;
  String name;
  bool loginEnabled;
  Map<String, dynamic>? user;

  Contact(this.name, this.loginEnabled, this.user, this.id);
}
