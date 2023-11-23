import 'package:get/get.dart';
import 'package:user/models/painting.dart';
import 'package:user/models/painting.dart';
import 'package:user/models/painting.dart';
import 'package:user/models/painting.dart';
import 'package:user/models/painting.dart';

class CartController extends GetxController {
  RxList<Painting> cartItems = <Painting>[].obs;

  void addToCart(Painting item) {
    cartItems.add(item);
  }

  void removeFromCart(Painting item) {
    cartItems.remove(item);
  }
  void removeAll(){
    cartItems.clear();
    cartItems.refresh();
  }
}