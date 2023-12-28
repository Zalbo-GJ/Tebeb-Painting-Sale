import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:user/routes/app_routes.dart';
import 'package:user/screens/splash_screen.dart';
import 'package:user/services/cart_controller.dart';
import 'package:user/services/painting_controller.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: AppRoutes.home,
      getPages: AppRoutes.pages,
      initialBinding: AppBindings(),
      title: 'TIBEB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF pro'
      ),
      home: SplashScreen(),
    );
  }
}
class AppBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<CartController>(CartController());
    Get.put<PaintingController>(PaintingController());
  }
}
