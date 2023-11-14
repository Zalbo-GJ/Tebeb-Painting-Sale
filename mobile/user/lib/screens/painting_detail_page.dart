import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:user/routes/app_routes.dart';

import '../models/painting.dart';

class PaintingDetailPage extends StatefulWidget {
  const PaintingDetailPage({Key? key}) : super(key: key);

  @override
  State<PaintingDetailPage> createState() => _PaintingDetailPageState();
}

class _PaintingDetailPageState extends State<PaintingDetailPage> {
  Painting painting = Get.arguments;
  @override
  void initState() {
    imageUrl = painting.imageLink!;
    super.initState();
  }
  late String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        child: Stack(
          fit: StackFit.loose,
          children: [
                Stack(
                  fit: StackFit.loose,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0)),
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
                  Positioned(
                    bottom: 42,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.bookmarks_outlined,
                          color:Colors.black,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    ),
                ],
              ),
                Positioned(
                  bottom: -30,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height*0.57,
                  child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        child: SingleChildScrollView(child:Padding(
                          padding: const EdgeInsets.only(left: 32.0,top: 32.0,bottom: 32.0,right: 16.0),
                          child: Column(children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Painting 1",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w800,color: Color.fromARGB(255, 6, 62, 73)),),
                                SizedBox(width: 8,)
                              ],
                            ),
                            const SizedBox(height: 10,),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Painter",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400,color:Color.fromARGB(255, 141, 141, 141) ),),
                                SizedBox(width: 8,)
                              ],
                            ),
                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              Text("Seller Rating:",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400,color:Color.fromARGB(255, 141, 141, 141) ),),
                              Wrap(
                                spacing: 0,
                                children: List.generate(
                                  5,
                                      (index) => const Icon(
                                    Icons.star_rate,
                                    color: Colors.yellow,
                                        size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                             const Text('(320 Reviews)',style: TextStyle(color: Color.fromARGB(255, 56, 62, 73),fontSize: 12),),
                            ],
                          ),
                          SizedBox(height: 10,),
                            Column(children: [
                            Container(
                              alignment:Alignment.centerLeft,
                                margin: EdgeInsets.only(top: 10,bottom: 6),
                                child: Text("Size",style: TextStyle(fontSize: 19,fontWeight: FontWeight.w600),)),
                            const Row(
                              children: [
                              Text("145cm"),
                              SizedBox(width: 5,),
                              Icon(Icons.close,size: 15,),
                              SizedBox(width: 5,),
                              Text("145cm")
                            ],
                            ),
                              Padding(
                                padding: const EdgeInsets.only(top:16.0,bottom: 6.0),
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    "Description",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 56, 62, 73),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20
                                    ),
                                  ),
                                ),
                              ),
                               Container( // Adjust the margin value as per your preference
                                child: Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor '
                                      'incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation '
                                      'ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                                  style: TextStyle(fontSize: 16.0,color: Color.fromARGB(255, 141, 141, 141),height: 1.1),
                                ),
                              ),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Total Price",style: TextStyle(color: Color.fromARGB(255, 141, 141, 141),fontSize: 18,fontWeight: FontWeight.w600),),
                                          Text("Br. 250,000.00",style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.w600),),
                                        ],
                                      ),
                                      SizedBox(
                                        key: UniqueKey(),
                                        width: MediaQuery.of(context).size.width*0.4,
                                        height: 80,
                                        child: InkWell(
                                          onTap: (){
                                            Get.toNamed(AppRoutes.clientProfilePage);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(40),
                                            ),
                                            child: const Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.bookmarks_outlined,color: Colors.white,size: 30,),
                                                  SizedBox(width: 5,),
                                                  Text(
                                                    "Save Item",
                                                    style:TextStyle(color:Colors.white, fontSize: 20),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                            ],)
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
