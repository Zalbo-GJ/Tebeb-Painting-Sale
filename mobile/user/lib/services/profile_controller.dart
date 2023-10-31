import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../models/user.dart';
import 'local_storage.dart';

class ProfileController extends GetxController {
  Rx<User> authenticatedUser = Rx<User>(User());
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
  }

  final localStorage =
      LocalStorage(flutterSecureStorage: FlutterSecureStorage()).obs;
  Future<void> getAuthenticatedUser() async {
    authenticatedUser.value = await localStorage.value.readUserInfo();
  }

}