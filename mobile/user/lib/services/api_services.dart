import 'package:dio/dio.dart';

import '../models/painting.dart';
import '../utils/constants.dart';

class ApiService{
  Future<List<Painting>?> getDeliveries() async {
    try {
      var dio = Dio();
      Response response;
        String url = AppUrls.paintingBaseUrl;
        response = await dio.get(url);
        if(response.statusCode == 200){
          final paintingData =  response.data as List<dynamic>;
          List<Painting> paintings = paintingData.map((e) => Painting.fromJson(e)).toList();
          return paintings;
        }
    }
    catch(e){
      print(e);
    }
  }
  Future<List<Painting>?> searchDelivery(String query) async {
    try {
      var dio = Dio();
      Response response;
      String url = AppUrls.paintingSearchUrl + query;
      response = await dio.get(url);
      if(response.statusCode == 200){
        final paintingData =  response.data as List<dynamic>;
        List<Painting> paintings = paintingData.map((e) => Painting.fromJson(e)).toList();
        return paintings;
      }
    }
    catch(e){
      print(e);
    }
  }
}