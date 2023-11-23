import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:user/utils/components.dart';

import '../services/cart_controller.dart';
import '../utils/colors.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  final CartController cartController = Get.find<CartController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 236, 236, 236),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 236, 236, 236),
          flexibleSpace: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black,size: 30,),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 50),
              ],
            ),
          ),
        ),
      ),
        body: Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Divider(thickness: 2.0,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text("My Cart",style: TextStyle(fontSize: 20),),
                    GestureDetector(onTap: (){
                       cartController.removeAll();
                    },
                      child: Text("Clear",style: TextStyle(fontSize: 16),),
                    )
                  ],),
                ),
                Container(
                  child: Column(
                    children: [
                      for(int i = 0;i<cartController.cartItems.length;i++)
                        CartItem(context, cartController.cartItems[i])
                    ],
                  ),
                ),
              ],
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Column(children: [
                  Text("Total"),
                  Text("20,000,000",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)
                ],),
                GestureDetector(
                  onTap: (){
                  },
                  child: Card(
                    elevation: 8,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.33,
                      height: 50,
                      decoration: BoxDecoration(color: theme,borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Text("Checkout",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
                    ),
                  ),)
              ],),
            )
          ],
        ),
          ),
    );
  }
}
