// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class SecureStorageSingleton {
//   // Create a private constructor
//   SecureStorageSingleton._privateConstructor();
//
//   // The single instance of the class
//   static final SecureStorageSingleton _instance = SecureStorageSingleton._privateConstructor();
//
//   // Global access point to the instance
//   static SecureStorageSingleton get instance => _instance;
//
//   // Instance of FlutterSecureStorage
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
//
//   // Example function to write data
//   Future<void> writeSecureData(String key, String value) async {
//     await secureStorage.write(key: key, value: value);
//   }
//
//   // Example function to read data
//   Future<String?> readSecureData(String key) async {
//     print('reading $key...');
//     return await secureStorage.read(key: key);
//   }
//
// // Optionally, add methods for deleting and reading all keys if needed.
// }
