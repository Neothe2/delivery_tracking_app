// login_page.dart
import 'dart:convert';

import 'package:delivery_tracking_app/error_modal.dart';
import 'package:delivery_tracking_app/home.dart';
import 'package:delivery_tracking_app/http_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  final AuthenticationService authenticationService;

  const LoginPage(this.authenticationService, {super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  refresh() async {
    bool response = await widget.authenticationService.refreshIfPossible();
    if (response != false) {
      navigateToHomePage();
    }
  }

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
      bool success = await widget.authenticationService.login(
          _usernameController.value.text, _passwordController.value.text);

      if (success) {
        // If server returns an OK response, parse the JSON.
        // final data = json.decode(response.body);
        //
        // HttpService().setAccessToken(data['access']);
        navigateToHomePage();

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

  navigateToHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }
}

abstract interface class AuthenticationService {
  Future<bool> login(String username, String password);

  Future<bool> refreshIfPossible();
}

class JWTAuthenticationService implements AuthenticationService {
  final TokenStorage _storage;

  JWTAuthenticationService(this._storage);

  @override
  Future<bool> refreshIfPossible() async {
    String? refreshToken = await _storage.read(key: 'refresh');
    if (refreshToken != null) {
      final response = await http.post(
        Uri.parse('http://108.181.201.104/auth/jwt/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(
          {"refresh": refreshToken},
        ),
      );
      if (response.statusCode == 200) {
        _storage.write(
            key: 'access', value: json.decode(response.body)['access']);
        return true;
      }
    }
    return false;
  }

  Future<bool> login(String username, String password) async {
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
  }
}

abstract interface class TokenStorage {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});

  Future<void> delete({required String key});
}

class SecureTokenStorage implements TokenStorage {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }
}
