import 'dart:ui';

class AppUrls {
  static var userBaseUrl = "http://192.168.1.8:8081/api/users";
  static var userLoginUrl = '${userBaseUrl}/login';
  static var paintingBaseUrl = 'https://painting-ms.onrender.com/api/paint';
  static var paintingSearchUrl = '${paintingBaseUrl}/name/';
}
TextStyle? boldText = TextStyle(fontWeight: FontWeight.bold,fontSize: 18);
