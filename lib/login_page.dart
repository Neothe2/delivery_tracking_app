// login_page.dart
import 'dart:convert';

import 'package:delivery_tracking_app/debug_mode.dart';
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

  Widget build1(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     backgroundColor: ColorPalette.greenVibrant,
      //     title: Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Text('Login'),
      //       ],
      //     )),
      body: Column(
        children: [
          Expanded(
            child: const Image(
              image: AssetImage('assets/images/appIcon.png'),
              width: 200,
              height: 200,
            ),
          ),
          Expanded(
            flex: 5,
            child: Form(
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
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
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
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xffD1CDC7),
                                    offset: Offset(6, 6),
                                    blurRadius: 16),
                                BoxShadow(
                                    color: Color(0xFFffffff),
                                    offset: Offset(-6, -6),
                                    blurRadius: 16)
                              ],
                            ),
                            child: OutlinedButton(
                              style: ButtonStyle(
                                shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
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
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Prevents content from being obscured by system UI
        child: Center(
          child: SingleChildScrollView(
            // Allows scrolling if content exceeds screen height
            child: Padding(
              padding: const EdgeInsets.all(24.0), // Consistent padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Logo Container
                  SizedBox(
                    height: 150, // Adjust height as needed
                    child: Center(
                      child: Image.asset('assets/images/appIcon.png',
                          width: 100, height: 100), // Replace with your logo
                    ),
                  ),
                  const SizedBox(height: 48), // Spacing between logo and form
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _usernameController,
                          decoration:
                              const InputDecoration(labelText: 'Username'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24), // Spacing between fields
                        TextFormField(
                          controller: _passwordController,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 36), // Spacing before button
                        (loading)
                            ? const CircularProgressIndicator()
                            : Container(
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                    color: Color(0xffd1cdc7),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ], borderRadius: BorderRadius.circular(999)),
                                child: OutlinedButton(
                                  style: ButtonStyle(
                                    elevation: MaterialStatePropertyAll(0),
                                    minimumSize: MaterialStatePropertyAll(
                                      Size(180, 50),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      await _login();
                                    }
                                  },
                                  child: const Text('Login'),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
            'The username or password is incorrect (both are case sensitive, make sure to correct your capital letters)',
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
        debugMode
            ? Uri.parse('http://10.0.2.2:81/auth/jwt/refresh')
            : Uri.parse('http://108.181.201.104:81/auth/jwt/refresh'),
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
      debugMode
          ? Uri.parse('http://10.0.2.2:81/auth/jwt/create')
          : Uri.parse('http://108.181.201.104:81/auth/jwt/create/'),
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
