import 'dart:ui';

class AppUrls {
  static var userBaseUrl = "https://user-management-ms-gb1c.onrender.com/api/users";
  static var userLoginUrl = '${userBaseUrl}/login';
  static var userRegisterUrl = '${userBaseUrl}/register';
  static var paintingBaseUrl = 'https://painting-ms.onrender.com/api/paint';
  static var paintingSearchUrl = '${paintingBaseUrl}/name/';
}
TextStyle? boldText = TextStyle(fontWeight: FontWeight.bold,fontSize: 18);
