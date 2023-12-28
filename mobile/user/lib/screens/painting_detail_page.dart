import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:user/routes/app_routes.dart';
import 'package:user/utils/colors.dart';

import '../models/painting.dart';
import '../services/cart_controller.dart';

class PaintingDetailPage extends StatefulWidget {
  const PaintingDetailPage({Key? key}) : super(key: key);

  @override
  State<PaintingDetailPage> createState() => _PaintingDetailPageState();
}

class _PaintingDetailPageState extends State<PaintingDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 0;
  final CartController cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    imageUrl = painting.imageLink!;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentIndex = _tabController.index;
      });
      print(currentIndex);
    });
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Painting painting = Get.arguments;
  late String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        child: Column(
          children: [
                Stack(
                  fit: StackFit.loose,
                children: [
                  ClipRRect(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.5,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      height: 30,
                      width: 30,
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)
                      ),
                        child: IconButton(
                          padding: EdgeInsets.only(bottom: 1,left: 7),
                          icon: const Icon(
                            Icons.arrow_back_ios, // Use the less than ("<") icon
                            color:Colors.black, // Set the color to black
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                ],
              ),
                Expanded(
                  child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        child: SingleChildScrollView(child:Padding(
                          padding: EdgeInsets.only(left: 32.0,top: 32.0,bottom: 32.0,right: 16.0),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text("Painting 1",style: TextStyle(fontSize: 45,fontWeight: FontWeight.w900,color: Color.fromARGB(255, 6, 62, 73)),),
                                    Text("by Zalbo",style: TextStyle(fontSize: 24,fontFamily:'kapakana',fontWeight: FontWeight.w500,fontStyle:FontStyle.italic,color: Color.fromARGB(255, 6, 62, 73)),),

                                  ],
                                ),
                                Row(children: [
                                  painting.isLikedByUser!?Icon(Icons.favorite,color:Colors.red,size: 30,):Icon(Icons.favorite_outline,color:Colors.black,size: 30,),
                                  SizedBox(width: 1,),
                                  Icon(Icons.circle,size: 6,color: Colors.black,),
                                  SizedBox(width: 3,),
                                  Text(" 6.9k")
                                ],)
                              ],
                            ),
                            Divider(thickness: 2.5,),
                            Padding(
                              padding: EdgeInsets.only(right: 40,top: 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                    Text("Dimensions",style: TextStyle(fontSize: 20),),
                                    Text("140 X 210 cm",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold))
                                  ],),
                                  SizedBox(height: 14,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Painting Type",style: TextStyle(fontSize: 20),),
                                      Text("Oily",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold))
                                    ],),
                                  SizedBox(height: 14,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Genre",style: TextStyle(fontSize: 20),),
                                      Text("Sensational",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold))
                                    ],),
                                  SizedBox(height: 14,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Drawn On",style: TextStyle(fontSize: 20),),
                                      Text("may 15 1993",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold))
                                    ],),
                                  SizedBox(height: 14,),
                                ],
                              ),
                            ),
                            Divider(thickness: 2,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text("Description",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                                ),
                                SizedBox(width: 15,),
                                Container(
                                  child: Row(
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(right: 10),
                                          width: 2,
                                          height: 20,
                                          color: Colors.black,
                                        ),
                                      InkWell(
                                        onTap:(){ Get.toNamed(AppRoutes.clientProfilePage);},
                                        child: Container(
                                          child: Text("Artist",style: TextStyle(color: Colors.black54,fontSize: 19,fontWeight: FontWeight.normal),),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              child: Container(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor"
                                              " incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation "
                                              "ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in "
                                              "voluptate velit esse cillum dolore eu fugiat nulla pariatur. "
                                              "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
                                        ),),
                                    ),
                            ),
                            GestureDetector(
                              onTap: (){
                                cartController.addToCart(painting);
                              },
                              child: Card(
                              elevation: 8,
                              child: Container(
                                width: MediaQuery.of(context).size.width*0.5,
                                height: 50,
                                decoration: BoxDecoration(color: theme,borderRadius: BorderRadius.circular(8)),
                                child: Center(child: Text("Br. 6500.00",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
                              ),
                            ),),
                            GestureDetector(
                              onTap: (){
                                Get.toNamed(AppRoutes.cartPage);
                              },
                              child: Card(
                                elevation: 8,
                                child: Container(
                                  width: MediaQuery.of(context).size.width*0.5,
                                  height: 50,
                                  decoration: BoxDecoration(color: theme,borderRadius: BorderRadius.circular(8)),
                                  child: Center(child: Text("Cart",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
                                ),
                              ),)
                          ],),
                        ),
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 20,)
              ]
            ),
      ),
    );
  }
}
