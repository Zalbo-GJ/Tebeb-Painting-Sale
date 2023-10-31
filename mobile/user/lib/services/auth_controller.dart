import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../routes/app_routes.dart';
import 'auth_service.dart';
import 'local_storage.dart';

class AuthController extends GetxController {
  final authService = AuthService().obs;
  Rx<LocalStorage> localStorage =
      LocalStorage(flutterSecureStorage: FlutterSecureStorage()).obs;
  final RxBool isAuthenticated = false.obs;
  final RxBool isRegistered = false.obs;
  final RxBool isVerified = false.obs;
  final RxString statusMessage = ''.obs;

  void checkAuthentication() async {
    final hasToken = await localStorage.value.readFromStorage('Token');

    if (hasToken != '') {
      isAuthenticated.value = true;
    } else {
      isAuthenticated.value = true;
    }
  }

  void logout() {
    localStorage.value.deleteFromStorage("Token");
    isAuthenticated.value = false;
    Get.toNamed(AppRoutes.authPage);
  }

  Future<void> loginUser(
      {required String email,
        required String password}) async {
    try {
      final user = await authService.value
          .loginUser(email: email, password: password);
      localStorage.value.writeToStorage("Token", user.token!.toString());

      localStorage.value.storeUserInfo(
          email: user.email.toString(),
          // image: user.image.toString(),
          name: user.name.toString(), image: '');

      isAuthenticated.value = true;
    } catch (e) {
      if (e is DioException) {
        var message = e.response!.data['message'].toString();

        statusMessage.value = message;
      }
      isAuthenticated.value = false;
    }
  }

  Future<void> register(
      {required String email,
        required String name,
        required String password}) async {
    try {
      String statusCode = await authService.value.register(
          email: email,
          name: name,
          password: password);

      if (statusCode == '200') {
        isRegistered.value = true;
        statusMessage.value =
        "User $email Registration was Successful. Verify your email!";
      } else {
        isRegistered.value = false;
      }
    } catch (e) {
      if (e is DioException) {
        var message = e.response!.data['message'].toString();

        statusMessage.value = message;
      }
      isAuthenticated.value = false;
      isRegistered.value = false;
    }
  }
}