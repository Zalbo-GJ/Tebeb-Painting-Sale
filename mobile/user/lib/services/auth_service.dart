import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  Future<User> loginUser({required String email,
    required String password}) async {
    try {
      var dio = Dio();
      Response response = await dio.get(
        AppUrls.userLoginUrl,
        data: jsonEncode(<String, dynamic>{
          'email': email,
          'password': password
        }),
      );
      if (response.statusCode == 200) {
        final responseBody = response.data;
        print(responseBody);
        User user = User(email: responseBody["email"],token: responseBody["token"] );
        print(user);
        return user;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<String> register(
      {required  String email,
        required String firstName,
        required String lastName,
        required String password}) async {
    try {
      var dio = Dio();

      Response response = await dio.post(AppUrls.userRegisterUrl,
          data: jsonEncode(<String, String>{
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "password": password
          }));
      print(response.statusCode.toString());
      return response.statusCode.toString();
    } catch (e) {
      throw e;
    }
  }
}