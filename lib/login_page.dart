// login_page.dart
import 'dart:convert';

import 'package:delivery_tracking_app/error_modal.dart';
import 'package:delivery_tracking_app/home.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
                      style: ButtonStyle(
                          shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)))),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _login();
                        }
                      },
                      child: SizedBox(
                          width: 100,
                          child: Text(
                            'Login',
                            textAlign: TextAlign.center,
                          )),
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
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON.
        final data = json.decode(response.body);

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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomePage(
          accessToken: accessKey,
        ),
      ),
    );
  }
}

class AuthenticationService {
  final TokenStorage _storage;

  AuthenticationService(this._storage);

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://108.181.201.104:80/auth/jwt/create/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        HttpService().setAccessToken(data['access']);
        _storage.write(key: 'access', value: data['access']);
        _storage.write(key: 'refresh', value: data['refresh']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
    return false;
  }
}

abstract class TokenStorage {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});

  Future<void> delete({required String key});
}

class StorageManager {
  final _storage = FlutterSecureStorage();

  Future<void> saveToken(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readToken(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }
}
