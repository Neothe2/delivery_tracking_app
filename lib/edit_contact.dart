import 'dart:convert';

import 'package:delivery_tracking_app/contacts.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:flutter/material.dart';

class EditContact extends StatefulWidget {
  final Contact contact;

  const EditContact({super.key, required this.contact});

  @override
  State<EditContact> createState() => _EditContactState();
}

class _EditContactState extends State<EditContact> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late final bool initiallyLoginEnabled;

  // final _retypePasswordController = TextEditingController();

  bool _enableLogin = false;

  @override
  void initState() {
    super.initState();
    if (widget.contact.loginEnabled) {
      initiallyLoginEnabled = true;
    } else {
      initiallyLoginEnabled = false;
    }
    _nameController.text = widget.contact.name;
    _enableLogin = widget.contact.loginEnabled;
    if (_enableLogin) {
      _usernameController.text = widget.contact.user!['username'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Contact'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 8.0),
            CheckboxListTile(
              title: Text('Enable login'),
              value: _enableLogin,
              onChanged: (bool? value) {
                setState(() {
                  _enableLogin = value!;
                });
              },
            ),
            if (_enableLogin) ...[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'User name',
                ),
              ),
              SizedBox(height: 8.0),
              if (!initiallyLoginEnabled)
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
              // SizedBox(height: 8.0),
              // TextField(
              //   controller: _retypePasswordController,
              //   obscureText: true,
              //   decoration: InputDecoration(
              //     labelText: 'Retype Password',
              //   ),
              // ),
            ],
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                var response = await HttpService().update(
                    'app/contacts/${widget.contact.id}/edit_contact_and_user/',
                    {
                      'name': _nameController.text,
                      "login_enabled": _enableLogin,
                      "username": _usernameController.text,
                      "password": _passwordController.text
                    });

                Navigator.pop(context, parseContact(jsonDecode(response.body)));
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Contact parseContact(Map<String, dynamic> contact) {
    return Contact(contact['name'], contact['login_enabled'], contact['user'],
        contact['id']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    // _retypePasswordController.dispose();
    super.dispose();
  }
}
//TODO: ADD THE UPDATE PASSWORD FORM
