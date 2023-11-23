import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user/routes/app_routes.dart';
import 'package:user/utils/colors.dart';
import 'package:user/utils/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(body: Column(children: [
      Container(
        height: MediaQuery.of(context).size.height*0.08+MediaQuery.of(context).size.height * 0.22,
        child: Stack(
          fit: StackFit.loose,
          children: [
          Container(
            decoration: BoxDecoration(
              color: theme,
            ),
            height: screenHeight *0.22,
            child: Padding(
              padding: const EdgeInsets.only(top:30.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  IconButton(onPressed: (){
                  }, icon: Icon(Icons.arrow_back_ios)),
                    Text("Profile",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    IconButton(onPressed: (){
                    }, icon: Icon(Icons.notifications)),
                  ],),
              ),
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).size.height*0.11,
              left: 0,
              right: 0,
              child: buildImage()
          ),
        ],),
      ),
      GestureDetector(
        onTap: (){
          Get.toNamed(AppRoutes.profilePage);
        },
        child: Card(
        elevation: 2,
        child: Container(
          width: MediaQuery.of(context).size.width*0.3,
          height: 35,
          decoration: BoxDecoration(color: Colors.black87,borderRadius: BorderRadius.circular(4)),
          child: Center(child: Text("Edit Profile",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
        ),
      ),),
      Container(
        margin: EdgeInsets.only(top: 20),
        height: 35,
        width: screenWidth,
        decoration: BoxDecoration(color: Color.fromARGB(255, 246, 246, 246)),
        child: Container(
          alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 25),
            child: Text("Tibeb Headlines",style:TextStyle(fontWeight: FontWeight.w800,fontSize: 16)),
      ),
      ),
      buildLinks(context, "Popular", null, () { }),
      buildLinks(context, "Trending", null, () { }),
      buildLinks(context, "Today", null, () { }),

      Container(
        margin: EdgeInsets.only(top: 20),
        height: 35,
        width: screenWidth,
        decoration: BoxDecoration(color: Color.fromARGB(255, 246, 246, 246)),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 25),
          child: Text("Content",style:TextStyle(fontWeight: FontWeight.w800,fontSize: 16)),
        ),
      ),
      buildLinks(context, "Favorite", Icons.favorite_border, () { }),
      buildLinks(context, "Subscription", Icons.subscriptions_outlined, () { }),

      Container(
        margin: EdgeInsets.only(top: 20),
        height: 35,
        width: screenWidth,
        decoration: BoxDecoration(color: Color.fromARGB(255, 246, 246, 246)),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 25),
          child: Text("Preferences",style:TextStyle(fontWeight: FontWeight.w800,fontSize: 16)),
        ),
      ),
      buildLinks(context, "Language", Icons.translate_outlined, () { }),
      buildLinks(context, "Darkmode", Icons.dark_mode_outlined, () { }),
    ],),);
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
              radius: MediaQuery.of(context).size.height*0.08,
              child: ClipOval(
                child: Image.network(image),
              )
          ),
        ),
      ),
    );
  }
  Widget buildLinks(BuildContext context,String label,IconData? icon,VoidCallback ontap){
       return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8),
         child: GestureDetector(
           onTap: ontap,
           child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Padding(
               padding: const EdgeInsets.only(left:8.0),
               child: Row(
                 children: [
                   icon == null?SizedBox(width: 0,):Padding(
                     padding: const EdgeInsets.only(right:13.0),
                     child: Icon(icon),
                   ),
                   Text(label,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                 ],
               ),
             ),
             Icon(Icons.arrow_forward_ios,size: 18,)
           ],
         ),),
       );
  }
}
