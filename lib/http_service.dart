import 'dart:convert';

import 'package:delivery_tracking_app/debug_mode.dart';
import 'package:delivery_tracking_app/login_page.dart';
import 'package:http/http.dart' as http;

class HttpService {
  static final HttpService _instance = HttpService._internal();
  final String _baseUrl = debugMode
      ? 'http://10.0.2.2:81'
      : "http://108.181.201.104:81"; // Replace with your actual base URL
  String _accessToken = ""; // Replace with your actual initial access token

  factory HttpService() {
    return _instance;
  }

  HttpService._internal();

  // Method to set the access token
  void setAccessToken(String token) {
    _accessToken = token;
  }

  get baseUrl => _baseUrl;

  get headers => _headers;

  Future<Map<String, String>> get _headers async {
    var accessToken = await SecureTokenStorage().read(key: 'access');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'JWT $accessToken',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return await http.get(url, headers: await _headers);
  }

  Future<http.Response> getAll(String endpoint) async {
    return await get(endpoint);
  }

  Future<http.Response> create(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return await http.post(url,
        headers: await _headers, body: json.encode(body));
  }

  Future<http.Response> update(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return await http.put(
      url,
      headers: await _headers,
      body: json.encode(body),
    );
  }

  Future<http.Response> partial_update(
      String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return await http.patch(
      url,
      headers: await _headers,
      body: json.encode(body),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return await http.delete(url, headers: await _headers);
  }
}
