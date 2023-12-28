import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:page_transition/page_transition.dart';

import '../services/auth_controller.dart';
import '../services/profile_controller.dart';
import '../utils/colors.dart';
import 'auth_page.dart';
import 'landing_page.dart';
class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  AuthController authController = Get.put(AuthController());
  Future<void> loadUserInfo() async {
    if (authController.isAuthenticated.value) {
      ProfileController profileController = Get.put(ProfileController());
      await profileController.getAuthenticatedUser();
    }
  }
  @override
  Widget build(BuildContext context) {
    authController.checkAuthentication();
    loadUserInfo();
    return Scaffold(
      body: AnimatedSplashScreen(
        splash: Image.asset('assets/images/logo_with_name.png'),
        duration: 3000,
        curve: Curves.bounceOut,
        splashIconSize: 350,
        splashTransition: SplashTransition.scaleTransition,
        animationDuration: const Duration(milliseconds: 1500),
        backgroundColor: mainBackgroundColor,
        pageTransitionType: PageTransitionType.fade,
        nextScreen: Obx(() => !authController.isAuthenticated.value
    ? const AuthPage()
        : const LandingPage()),
    ),
    );
  }
}
