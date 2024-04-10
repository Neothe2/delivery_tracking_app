import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpService {
  static final HttpService _instance = HttpService._internal();
  final String _baseUrl =
      "http://192.168.68.121:8000"; // Replace with your actual base URL
  String _accessToken = ""; // Replace with your actual initial access token

  factory HttpService() {
    return _instance;
  }

  HttpService._internal();

  // Method to set the access token
  void setAccessToken(String token) {
    _accessToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'JWT $_accessToken',
      };

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return await http.get(url, headers: _headers);
  }

  Future<http.Response> getAll(String endpoint) async {
    return await get(endpoint);
  }

  Future<http.Response> create(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return await http.post(url, headers: _headers, body: json.encode(body));
  }

  Future<http.Response> update(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return await http.put(url, headers: _headers, body: json.encode(body));
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return await http.delete(url, headers: _headers);
  }
}
