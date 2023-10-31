import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:user/routes/app_routes.dart';

import '../utils/colors.dart';

class ClientProfile extends StatefulWidget {
  const ClientProfile({Key? key}) : super(key: key);

  @override
  State<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
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
  String backUrl = "https://i.ibb.co/7nGpWFf/photo-2023-01-19-20-32-55.jpg";
  List<String> paintings = ["https://www.shutterstock.com/shutterstock/photos/2259644567/display_1500/stock-photo-abstract-colorful-oil-acrylic-painting-of-bird-and-spring-flower-modern-art-paintings-brush-2259644567.jpg",
  "https://media.cnn.com/api/v1/images/stellar/prod/190430171751-mona-lisa.jpg?q=w_2000,c_fill/f_webp",
  "https://magazine.artland.com/wp-content/uploads/2022/07/van-gogh-starry-night-min.jpg",
  "https://t3.ftcdn.net/jpg/02/73/22/74/360_F_273227473_N0WRQuX3uZCJJxlHKYZF44uaJAkh2xLG.webp",
  "https://cdn.shopify.com/s/files/1/0047/4231/6066/files/The_Creation_of_Adam_by_Michelangelo_Buonarroti_1511_800x.jpg",
  "https://cdn.shopify.com/s/files/1/0047/4231/6066/files/The_Last_Supper_by_Leonardo_da_Vinci_1495_1498_800x.jpg",
    "https://cdn.shopify.com/s/files/1/0047/4231/6066/files/Girl_with_a_Pearl_Earring_by_Johannes_Vermeer_1665_800x.jpg"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*0.1+MediaQuery.of(context).size.height * 0.27,
              child: Stack(
                  fit: StackFit.loose,
                  children: [
                    Stack(
                      fit: StackFit.loose,
                      children: [
                        ClipRRect(
                          child: Image.network(
                            backUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.27,
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios, // Use the less than ("<") icon
                              color: Colors.white, // Set the color to black
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height*0.135,
                      left: 0,
                      right: 0,
                      child: buildImage()
                    ),
                  ]
              ),
            ),
            Text("Nebil Mesfin",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
            Container(
              width: MediaQuery.of(context).size.width*0.7,
              padding: const EdgeInsets.all(8.0),
              child: const Center(child:Text('"This stage is beneath my talent, but I shall elevate it."',style: TextStyle(fontStyle: FontStyle.italic,fontSize: 15),textAlign: TextAlign.center,)),
            ),
            Container(
              width: MediaQuery.of(context).size.width*0.7,
              padding: const EdgeInsets.only(top:8.0),
              child: const Center(child:Text('37K',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),
            ),
            Container(
              width: MediaQuery.of(context).size.width*0.7,
              child: const Center(child:Text("3.5 Star reviews",style: TextStyle(fontStyle: FontStyle.italic,fontSize: 15),textAlign: TextAlign.center,)),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: const Color.fromARGB(255, 215, 184, 148),
              labelStyle: const TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold,color: Colors.black),  //For Selected tab
              unselectedLabelStyle: const TextStyle(fontSize: 16.0,fontWeight: FontWeight.normal,color: Colors.black12),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              tabs: const [
                Tab(
                  child: Text("Painting",style: TextStyle(color: Colors.black),),
                ),
                Tab(
                  child: Text('Contact Info',style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: currentIndex == 0?150.0*((paintings.length/3).ceil()):170,
              child: TabBarView(
                controller: _tabController,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150.0*((paintings.length/3).ceil()),
                    child: GridView.count(
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 10,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      children: List.generate(paintings.length, (index) {
                        return InkWell(
                          onTap: (){
                            Get.toNamed(AppRoutes.paintingDetailsPage);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              paintings[index],
                              fit: BoxFit.cover, // Adjust the height to fit the container
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                 Padding(
                   padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 40.0),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                     buildContactInfo(context, "Email", "nebilpaintings@gmail.com"),
                     buildContactInfo(context, "Phone Number", "+251923599260"),
                     buildContactInfo(context, "Artist Name", "Petrichor"),
                   ],),
                 )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget buildImage() {
   String image = "https://i.ibb.co/QQdbCzs/20230830-145110.jpg";
    return ClipOval(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            radius: MediaQuery.of(context).size.height*0.1,
            child: ClipOval(
              child: Image.network(image),
            )
          ),
        ),
      ),
    );
  }
  Widget buildContactInfo(BuildContext context,String label,String value){
    return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(flex:1,child: Text(label,style: const TextStyle(fontWeight: FontWeight.bold),)),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 7),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:  Color.fromARGB(255, 155, 148, 148),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Text(value,style: TextStyle(color: Color.fromARGB(255, 155, 148, 148)),),
                ),
              ),
            ],
          );
  }
}