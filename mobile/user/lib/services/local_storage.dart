import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';

class LocalStorage {
  final FlutterSecureStorage flutterSecureStorage;

  LocalStorage({required this.flutterSecureStorage});

  Future<String> readFromStorage(String key) async {
    final String data = await flutterSecureStorage.read(key: key) ?? "";

    return data;
  }

  Future<void> writeToStorage(String key, String value) async {
    await flutterSecureStorage.write(key: key, value: value);
    return;
  }

  Future<void> storeUserInfo({
    required String email,
    required String image,
    required String name,
  }) async {
    writeToStorage("email", email);
    writeToStorage("image", image);
    writeToStorage("name", name);
  }

  Future<User> readUserInfo() async {
    String email = await readFromStorage(
      "email",
    );

    String token = await readFromStorage(
      "Token",
    );
    String image = await readFromStorage(
      "image",
    );
    String name = await readFromStorage(
      "name",
    );
    var userData = {
      "email": email,
      'image': image,
      'token': token,
      'name': name,
    };

    print(userData);
    return User.fromJson(userData);
  }

  Future<void> deleteFromStorage(String key) async {
    await flutterSecureStorage.delete(
      key: key,
    );
    return;
  }
}