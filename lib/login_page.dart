// login_page.dart
import 'dart:convert';

import 'package:delivery_tracking_app/error_modal.dart';
import 'package:delivery_tracking_app/home.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              (loading)
                  ? const CircularProgressIndicator()
                  : OutlinedButton(
                      onPressed: () async {
                        // Validate returns true if the form is valid, otherwise false.
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a Snackbar.
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(content: Text('Processing Data')),
                          // );
                          await _login();
                          // Here you can call your login method
                        }
                      },
                      child: Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      setState(() {
        loading = true;
      });
      final response = await http.post(
        Uri.parse('http://108.181.201.104:80/auth/jwt/create/'),
        // Ensure the port is specified if needed.
        // Uri.parse('http://10.0.2.2:8000/auth/jwt/create'),
        // Ensure the port is specified if needed.
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON.
        final data = json.decode(response.body);
        // var storage = const FlutterSecureStorage();
        // await SecureStorageSingleton.instance.writeSecureData('access_token', data['access']);
        // AccessKey().key = data['access'];
        HttpService().setAccessToken(data['access']);
        navigateToHomePage(data['access']);

        // Navigate to the next screen with Navigator.pushReplacement()
      } else {
        showError(
            'The username is password is incorrect (both are case sensitive, make sure to correct your capital letters)',
            context);
        setState(() {
          loading = false;
        });
        throw Exception('Failed to load token');
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      // If any exception occurs, print it to the console and handle it.
      print('Exception occurred: $e');
      // Optionally, handle the error, e.g., through a user-friendly message.
    }
  }

  navigateToHomePage(String accessKey) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomePage(
              accessToken: accessKey,
            )));
  }
}
