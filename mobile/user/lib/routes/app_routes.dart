import 'package:get/get.dart';
import 'package:user/screens/client_profile.dart';

import '../screens/auth_page.dart';
import '../screens/cart_page.dart';
import '../screens/chat_page.dart';
import '../screens/landing_page.dart';
import '../screens/painting_detail_page.dart';
import '../screens/profile_page.dart';
import '../screens/splash_screen.dart';


class AppRoutes {
  static const String home = '/';
  static const String authPage = '/auth';
  static const String landingPage = '/landingPage';
  static const String paintingDetailsPage = '/paintingDetailsPage';
  static const String profilePage = '/profilePage';
  static const String clientProfilePage = '/clientProfilePage';
  static const String cartPage = '/cartPage';
  static const String chatPage = '/chatPage';

  static final List<GetPage> pages = [
    GetPage(name: home, page: () =>  SplashScreen()),
    GetPage(name: authPage, page: () => const AuthPage()),
    GetPage(name: landingPage, page: () => const LandingPage()),
    GetPage(name: paintingDetailsPage, page: () => const PaintingDetailPage()),
    GetPage(name: clientProfilePage, page: () => const ClientProfile()),
    GetPage(name: profilePage, page: () => const ProfilePage()),
    GetPage(name: cartPage, page: () => const CartPage()),
    GetPage(name: chatPage, page: () => const ChatPage()),
  ];
}
