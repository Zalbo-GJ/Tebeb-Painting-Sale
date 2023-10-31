import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../routes/app_routes.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  TextEditingController _searchController = TextEditingController();

  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.amber),
        title: Container(
          width: 300,
          height: 40,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 240, 238, 238),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
              child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                ),
                hintText: 'search for paintings',
                border: InputBorder.none),
          )),
        ),
        backgroundColor: Colors.white,
      ),
      body: Material(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            crossAxisSpacing: 50,
            mainAxisSpacing: 30,
            crossAxisCount: 2,
            childAspectRatio: 1,
            //shrinkWrap: true,
            //primary: false,
            padding: const EdgeInsets.all(10),
            children: <Widget>[
              Material(
                elevation: 15,
                borderRadius: BorderRadiusDirectional.circular(25),
                //clipBehavior: Clip.antiAliasWithSaveLayer,
                child: InkWell(
                  //splashColor: Colors.black,
                  onTap: () {
                    Get.toNamed(AppRoutes.paintingDetailsPage);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Ink.image(
                        image: const NetworkImage(
                            'https://th.bing.com/th/id/OIP.oGbkUXOEspTGsgro1fvWYgHaJ6?pid=ImgDet&rs=1'),
                        height: 150,
                        width: 100,
                        fit: BoxFit.cover,
                        //padding: const EdgeInsets.only(top: 70, left: 20),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      const Text(
                        'Painting 1 \nBr : 60k',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              Material(
                elevation: 18,
                borderRadius: BorderRadiusDirectional.circular(25),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: InkWell(
                  //splashColor: Colors.black,
                  onTap: () {
                    Get.toNamed(AppRoutes.paintingDetailsPage);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Ink.image(
                        image: const NetworkImage(
                            'https://th.bing.com/th/id/OIP.oGbkUXOEspTGsgro1fvWYgHaJ6?pid=ImgDet&rs=1'),
                        height: 150,
                        width: 100,
                        fit: BoxFit.cover,
                        //padding: const EdgeInsets.only(top: 70, left: 20),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      const Text(
                        'Painting 1 \nBr : 60k',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              Material(
                elevation: 18,
                borderRadius: BorderRadiusDirectional.circular(25),
                //clipBehavior: Clip.antiAliasWithSaveLayer,
                child: InkWell(
                  //splashColor: Colors.black,
                  onTap: () {
                    Get.toNamed(AppRoutes.paintingDetailsPage);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Ink.image(
                        image: const NetworkImage(
                            'https://th.bing.com/th/id/OIP.oGbkUXOEspTGsgro1fvWYgHaJ6?pid=ImgDet&rs=1'),
                        height: 150,
                        width: 100,
                        fit: BoxFit.cover,
                        //padding: const EdgeInsets.only(top: 70, left: 20),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      const Text(
                        'Painting 1 \nBr : 60k',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              Material(
                elevation: 18,
                borderRadius: BorderRadiusDirectional.circular(25),
                //clipBehavior: Clip.antiAliasWithSaveLayer,
                child: InkWell(
                  //splashColor: Colors.black,
                  onTap: () {
                    Get.toNamed(AppRoutes.paintingDetailsPage);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Ink.image(
                        image: const NetworkImage(
                            'https://th.bing.com/th/id/OIP.oGbkUXOEspTGsgro1fvWYgHaJ6?pid=ImgDet&rs=1'),
                        height: 150,
                        width: 100,
                        fit: BoxFit.cover,
                        //padding: const EdgeInsets.only(top: 70, left: 20),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      const Text(
                        'Painting 1 \nBr : 60k',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),



      drawer: Drawer(
        child: BackdropFilter(
          blendMode: BlendMode.srcOver,
          filter: ImageFilter.blur(
              sigmaX: 13.0, sigmaY: 13.0, tileMode: TileMode.clamp),
          child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255)
              ],
            )),
            child: ListView(
              padding: const EdgeInsets.only(top: 20, left: 20),
              children: [
                Container(
                  height: 200,
                  color: Colors.grey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 70,
                          width: 70,
                          margin: const EdgeInsets.only(
                              top: 40, left: 10, bottom: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: const Color.fromARGB(255, 255, 255, 255),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  /*profileController
                                        .authenticatedUser.value.image ??*/
                                  "https://th.bing.com/th/id/R.f702feb263901e8b2478090cffdaca57?rik=Dq616ZaLfFwy%2fA&pid=ImgRaw&r=0"),
                            ),
                          ),
                          child: Container()),
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              /*profileController
                                        .authenticatedUser.value.firstName ??
                                    " " +
                                        '${profileController.authenticatedUser.value.lastName}' ??*/
                              "Authenticated user",
                              style: TextStyle(
                                  fontSize: 25,
                                  //color: Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              /*profileController
                                        .authenticatedUser.value.username ??*/
                              "authenticated user",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                  margin: const EdgeInsets.only(right: 40),
                  decoration: const BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person,
                      //color: Colors.black,
                      size: 25,
                    ),
                    title: const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        //color: Colors.white
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.toNamed(AppRoutes.profilePage);
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.message,
                    size: 25,
                    //color: Colors.black,
                  ),
                  title: const Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      //color: Color.fromARGB(255, 0, 0, 0)
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(AppRoutes.chatPage);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.phone,
                    size: 25,
                    //color: Colors.black,
                  ),
                  title: const Text(
                    'Contact us',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    // Get.toNamed(AppRoutes.settingsPage);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.help,
                    size: 25,
                    //color: Colors.white,
                  ),
                  title: const Text(
                    'FAQ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      //color: Colors.white
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    // Get.toNamed(AppRoutes.settingsPage);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    size: 25,
                    //color: Colors.white,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      //color: Colors.white
                    ),
                  ),
                  onTap: () {
                    // ...
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "© 2023 TIBEB. All rights reserved",
                      //style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: const Icon(
                        Icons.settings,
                        size: 32,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        // Get.toNamed(AppRoutes.settingsPage);
                      },
                    ),
                    const SizedBox(
                      width: 15,
                    )
                  ],
                ),
                const SizedBox(
                  height: 60,
                )
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: GNav(
        activeColor: Colors.amber,
        gap: 8,
        iconSize: 25,
        tabBackgroundColor: const Color.fromARGB(255, 241, 241, 241),
        tabs: [
          GButton(
            icon: Icons.home_outlined,
            text: 'home',
            onPressed: () {
              Get.toNamed(AppRoutes.landingPage);
            },
          ),
          GButton(
            icon: Icons.shopping_cart_outlined,
            text: 'cart',
            onPressed: () {
              Get.toNamed(AppRoutes.cartPage);
            },
          ),
          GButton(
            icon: Icons.notifications_outlined,
            text: 'notifications',
            onPressed: () {
              Get.toNamed(AppRoutes.paintingDetailsPage);
            },
          ),
          GButton(
            icon: Icons.person_2_outlined,
            text: 'profile',
            onPressed: () {
              Get.toNamed(AppRoutes.profilePage);
            },
          ),
        ],
      ),
    );
  }
}


