import 'dart:ui';

import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:shimmer_effect/shimmer_effect.dart';
import 'package:user/screens/edit_profile_page.dart';
import 'package:user/screens/profile_page.dart';
import 'package:user/screens/wish_list_page.dart';

import '../models/painting.dart';
import '../services/api_services.dart';
import '../services/painting_controller.dart';
import '../utils/colors.dart';
import '../utils/components.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();

  late ScrollController _scrollBottomBarController;

  BottomDrawerController bottomDrawerController = BottomDrawerController();
  final ValueNotifier<bool> _isPanelOpenNotifier = ValueNotifier<bool>(false);
  bool _show = false;

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

  final GlobalKey<ScaffoldState> _globalkey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool isLiked = false;

  void _searchPaintings() async{
    if(_searchController.text == ""){
      _paintingController.fetchPaintings();
      return;
    }
    _paintingController.searchPainting(_searchController.text);
  }

  void showBottomBar() {
    setState(() {
      _show = true;
    });
  }
  void hideBottomBar() {
    setState(() {
      _show = false;
    });
  }

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Painting> paintingList = [];

@override
  void initState() {
  _scrollBottomBarController = _paintingController.scrollController;
  _scrollBottomBarController.addListener(() {
    if (_scrollBottomBarController.position.userScrollDirection ==
        ScrollDirection.forward){
      showBottomBar();
    }
    else{
      hideBottomBar();
    }
  });
  _tabController = TabController(length: 5, vsync: this);
   setState(() {
     _isLoading = true;
   });
    super.initState();
  }

  RangeValues _selectedRange = RangeValues(10000, 70000);
  int _selectedNumber = 0;
  final List<String> paintingTypes = [
    'Oil Painting',
    'Watercolor Painting',
    'Acrylic Painting',
    'Pastel Painting',
    'Charcoal Drawing',
    'Ink Drawing',
    'Digital Painting',
    'Gouache Painting',
    'Mixed Media Painting',
    'Impressionist Painting',
    'Abstract Painting',
    'Realistic Painting',
  ];
  List<String> selectedItems = [];

  final PaintingController _paintingController = Get.find<PaintingController>();

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0,right: 15.0,top: 10),
            child: Column(
              children: [
                SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width *0.8,
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _searchController,
                          onFieldSubmitted: (String value){
                            _searchPaintings();
                          },
                          keyboardType: TextInputType.text,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: mainBackgroundColor,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color.fromARGB(255, 235, 235, 235), width: 2.0),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            contentPadding: const EdgeInsets.all(10),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            border: InputBorder.none,
                            hintText: 'Search for paintings',
                            hintStyle: TextStyle(color: Colors.grey),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),border: Border.all(color: Colors.white),color: Color(0xFFD7B894)),
                                  child: IconButton(icon:Icon(Icons.search,size: 18,),color: Colors.white, onPressed: () {
                                    _searchPaintings();
                      },)),
                            ),
                          ),
                          onChanged: (value) {},
                          validator: (value) {},
                        ),
                      ),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap:() {
                            bottomDrawerController.open();
                            _isPanelOpenNotifier.value = true;
                         },
                        child: Container(
                          padding: EdgeInsets.all(7),
                          width: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Color.fromARGB(255, 123, 123, 123)),
                              borderRadius: BorderRadius.circular(40)
                          ),
                          child: Image.asset('assets/images/filter.png',)),)
                    ],),
                ),
                SizedBox(height: 15,),
                TabBar(
                    controller: _tabController,
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    indicatorColor: const Color.fromARGB(255, 0, 0, 0),
                    unselectedLabelColor: Colors.grey,
                    labelColor: Colors.black,
                    labelStyle: const TextStyle(fontSize: 12.0,),  //For Selected tab
                    unselectedLabelStyle: const TextStyle(fontSize: 12.0),
                    tabs: [
                      Tab(
                        child: Container(
                          child: Column(
                            children: [
                              Icon(Icons.whatshot,),
                              Text("Hottest"),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          child: Column(
                            children: [
                              Icon(Icons.brush),
                              Text("Renaissance"),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          child: Column(
                            children: [
                              Icon(Icons.hotel_class_sharp,),
                              Text("Rococo",),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          child: Column(
                            children: [
                              Icon(Icons.favorite),
                              Text("Romanticism"),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          child: Column(
                            children: [
                              Icon(Icons.local_florist_rounded),
                              Text("Impressionism"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),Obx(() {
                  return _paintingController.isLoading.value == true && _isLoading
                      ? Expanded(
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (ctx, inx) => const PaintingSkeleton(),
                    ),
                  )
                      : Expanded(
                    child: ListView.builder(
                      controller: _paintingController.scrollController,
                        itemCount: _paintingController.paintings.length + 1,
                        itemBuilder: (ctx, index) {
                          if (index < _paintingController.paintings.length) {
                            final thumbnailUrl = _paintingController.paintings[index].imageLink;
                            _isLoading = false;
                            final isDefaultThumbnail =
                                thumbnailUrl == "default.jpg";
                            return PaintingCard(painting: _paintingController.paintings[index],);
                          } else {
                            print("executing else statement");
                            if (index == _paintingController.paintings.length &&
                                !_paintingController.reachedEndOfList && !_paintingController.searchMode) {
                              // Display CircularProgressIndicator under the last card
                              return Center(child: CircularProgressIndicator());
                            } else {
                              return Container(); // Return an empty container otherwise
                            }
                          }
                        }),
                  );
                }),
                // Expanded(
                //   child: SingleChildScrollView(
                //             controller: _scrollBottomBarController,
                //             physics: const BouncingScrollPhysics(),
                //             child: Container(
                //               width: double.infinity,
                //               height: paintingList.isNotEmpty?(paintingList.length) * (MediaQuery.of(context).size.height*0.5):MediaQuery.of(context).size.height*2 + 55,
                //               child: paintingList.isNotEmpty
                //                   ? ListView.separated(
                //                 itemCount: paintingList.length,
                //                 physics: NeverScrollableScrollPhysics(),
                //                 shrinkWrap: true,
                //                 separatorBuilder: (context, index) => SizedBox(height: 10), // Adjust the height as needed
                //                 itemBuilder: (context, index) {
                //                   final item = paintingList[index];
                //                   return PaintingCard(painting: item);
                //                 },
                //               ):Column(children: [
                //                 for(int i = 0;i<5;i++)
                //                   PaintingSkeleton()
                //
                //               ],)
                //             )
                //         ),
                // ),
              ],
            ),
          ),
          Positioned.fill(
            top: 40,
            child: BottomDrawer(
              cornerRadius: 30,
            controller: bottomDrawerController,
            body: SingleChildScrollView(
              child: GestureDetector(
                onTap: (){

                },
                child: Container(
                    padding: EdgeInsets.all(25),
                  width: MediaQuery.of(context).size.width,
                  child: Column(children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child:Text("Price Range",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)
                    ),
                    SizedBox(height: 20,),
                    Container(
                        alignment: Alignment.centerLeft,
                        child:Text("Prices include VAT",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 17),)
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Range",style:TextStyle(color: Colors.grey,fontSize: 18)),
                        Text('Br.100 - Br.100000',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),)
                      ],
                    ),
                    RangeSlider(
                      values: _selectedRange,
                      activeColor: Color.fromARGB(255, 235, 87, 87),
                      min: 0,
                      max: 100000,
                      onChanged: (RangeValues newRange) {
                        setState(() {
                          _selectedRange = newRange;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Expanded(
                           child: Container(
                             padding: EdgeInsets.all(10),
                             decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color: Colors.white,border:Border.all(color: Colors.black)),
                             height: 75,
                             child: Column(children: [
                               Container(alignment: Alignment.centerLeft,child:Text("Minimum",style: TextStyle(color:Colors.grey),)),
                               Container(alignment: Alignment.centerLeft,child:Text("Br.${_selectedRange.start.toInt()}",style: TextStyle(color:Colors.black,fontSize: 20),)),
                             ],),
                           ),
                         ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          width: 20,
                          height: 2,
                          color: Colors.black,
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),color: Colors.white,border:Border.all(color: Colors.black)),
                            height: 75,
                            child: Column(children: [
                              Container(alignment: Alignment.centerLeft,child:Text("maximum",style: TextStyle(color:Colors.grey),)),
                              Container(alignment: Alignment.centerLeft,child:Text("Br.${_selectedRange.end.toInt()}",style: TextStyle(color:Colors.black,fontSize: 20),)),
                            ],),
                          ),
                        ),
                    ],),
                    SizedBox(height: 20,),
                    Container(
                        alignment: Alignment.centerLeft,
                        child:Text("Seller Rating",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)
                    ),
                    SizedBox(height: 15,),
                    Container(
                        alignment: Alignment.centerLeft,
                        child:Text("Stars rated",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 17),)
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(onTap: (){
                          setState(() {
                            _selectedNumber = 0;
                          });
                        },
                        child:Container(
                          width: 60,
                          decoration: BoxDecoration(
                            border:Border.all(color: Colors.black),
                            color: _selectedNumber == 0
                                ? Colors.black
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          padding: EdgeInsets.all(6.0),
                          child: Center(
                            child: Text(
                              "Any",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: _selectedNumber == 0
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        )),
                        for (int number = 1; number <= 5; number++)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedNumber = number;
                              });
                            },
                            child: Container(
                              width: 50,
                              decoration: BoxDecoration(
                                border:Border.all(color: Colors.black),
                                color: _selectedNumber == number
                                    ? Colors.black
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              padding: EdgeInsets.all(6.0),
                              child: Center(
                                child: Text(
                                  number.toString(),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: _selectedNumber == number
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 40,),
                    Container(
                        alignment: Alignment.centerLeft,
                        child:Text("Painting Type",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio:
                        10.0, // Adjust this value to change the aspect ratio of the checkboxes
                      ),
                      itemCount: paintingTypes.length, // Replace 'choices' with your list of choices
                      itemBuilder: (context, index) {
                        return Theme(
                          data: ThemeData(
                              unselectedWidgetColor: Colors.white,
                              checkboxTheme: CheckboxThemeData(
                                  fillColor:
                                  MaterialStateProperty.all(
                                      Colors.white))),
                          child: CheckboxListTile(
                            checkColor: Colors.white,
                            activeColor: Colors.black,
                            controlAffinity: ListTileControlAffinity.trailing,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              paintingTypes[index],
                              style: TextStyle(color: Colors.black,fontSize: 14),
                            ),
                            value:selectedItems.contains(paintingTypes[index])
                                ? true
                                : false,
                            onChanged: (newValue) {
                              setState(() {
                                if (newValue == true) {
                                  selectedItems.add(paintingTypes[index]);
                                } else {
                                  selectedItems.remove(paintingTypes[index]);
                                }
                                print(selectedItems);
                              },
                              );
                            }
                        ),
                    );
                    },
                    ),
                    SizedBox(height: 10,),
                    Divider(thickness: 2.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Clear all",style: TextStyle(decoration: TextDecoration.underline,),),
                        GestureDetector(
                          onTap: (){

                          },
                          child: Card(
                            elevation: 2,
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.3,
                              height: 35,
                              decoration: BoxDecoration(color: Colors.black87,borderRadius: BorderRadius.circular(4)),
                              child: Center(child: Text("Show Results",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
                            ),
                          ),),
                      ],
                    )
                  ],)
                ),
              ),
            ),
            color: Color.fromARGB(255, 253, 253, 253), headerHeight: 10, drawerHeight: 1000, header: Container(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: (){
              
                  }, icon: Icon(Icons.cancel_outlined)),
                  Text("Filter",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                  SizedBox(width: 50,)
                ],
              ),
            ),
          ),)
        ],
      ),
      WishListPage(),
      Center(child: Text("notification page"),),
      ProfilePage()
    ];
    return Scaffold(
      key:_globalkey,
      body: widgetOptions[_currentIndex],
      bottomNavigationBar: AnimatedContainer(
        duration: Duration(seconds: 2),
        curve: Curves.easeInOut,
        child: Container(
        height: _show?60:0,
        width: MediaQuery.of(context).size.width,
        child: _show
            ?Container(
                        decoration: BoxDecoration(color: Colors.red), // Set the background color
                        child: Theme(
              data: Theme.of(context).copyWith(
                  canvasColor: Color(0xFFD7B894),),
              child: BottomNavigationBar(
                onTap: _onTabTapped,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.explore_outlined, color: Colors.black),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border, color: Colors.black),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notification_important_outlined, color: Colors.black),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline, color: Colors.black),
                    label: '',
                  ),
                ],
              ),
                        ),
            )
            : Container(
          height: 1,
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
        ),
        )
      ),
    );
  }
}

class SkeletonElement extends StatelessWidget {
  const SkeletonElement({
    super.key,
    required this.isMarginForAll,
    required this.dimensions,
    required this.colors,
  });

  final bool isMarginForAll;
  final Map<String, double> dimensions;
  final Map<String, Color> colors;

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      baseColor: shimmerEffectBase1.withOpacity(.3),
      highlightColor: shimmerEffectHighlight1,
      child: Container(
        margin: isMarginForAll
            ? EdgeInsets.all(dimensions['margin_all']!)
            : EdgeInsets.fromLTRB(
          dimensions['margin_left'] ?? 0,
          dimensions['margin_top'] ?? 0,
          dimensions['margin_right'] ?? 0,
          dimensions['margin_bottom'] ?? 0,
        ),
        width: dimensions['width'],
        height: dimensions['height'],
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(dimensions['radius'] ?? 0),
          color: shimmerEffectBase1.withOpacity(.3),
        ),
      ),
    );
  }
}

class PaintingSkeleton extends StatelessWidget {
  const PaintingSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      height: MediaQuery.of(context).size.height*0.4,
      child: Card(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonElement(
                  isMarginForAll: true,
                  dimensions: {
                    'width': MediaQuery.of(context).size.width * .8,
                    'height': MediaQuery.of(context).size.height * .23,
                    'margin_all': 10,
                    'radius': 8,
                  },
                  colors: {
                    'base': shimmerEffectBase2,
                    'highlight': shimmerEffectHighlight2,
                  },
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonElement(
                        isMarginForAll: false,
                        dimensions: {
                          'width': 150,
                          'height': 25,
                          'radius': 4,
                          'margin_bottom': 5
                        },
                        colors: {
                          'base': Colors.amber,
                          'highlight': shimmerEffectHighlight1,
                        },
                      ),
                      SkeletonElement(
                        isMarginForAll: false,
                        dimensions: {
                          'width': 40,
                          'height': 25,
                          'radius': 4,
                          'margin_bottom': 5
                        },
                        colors: {
                          'base': shimmerEffectBase1,
                          'highlight': shimmerEffectHighlight1,
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonElement(
                        isMarginForAll: false,
                        dimensions: const {
                          'width': 100,
                          'height': 15,
                          'radius': 4,
                          'margin_bottom': 5
                        },
                        colors: {
                          'base': shimmerEffectBase1,
                          'highlight': shimmerEffectHighlight1,
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonElement(
                        isMarginForAll: false,
                        dimensions: {
                          'width': 100,
                          'height': 15,
                          'radius': 4,
                          'margin_bottom': 5
                        },
                        colors: {
                          'base': shimmerEffectBase1,
                          'highlight': shimmerEffectHighlight1,
                        },
                      ),
                      Row(
                        children: [
                          SkeletonElement(
                            isMarginForAll: false,
                            dimensions: {
                              'width': 40,
                              'height': 24,
                              'radius': 4,
                              'margin_bottom': 5
                            },
                            colors: {
                              'base': shimmerEffectBase1,
                              'highlight': shimmerEffectHighlight1,
                            },
                          ),
                          SizedBox(width: 8,),
                          SkeletonElement(
                            isMarginForAll: false,
                            dimensions: {
                              'width': 40,
                              'height': 24,
                              'radius': 4,
                              'margin_bottom': 5
                            },
                            colors: {
                              'base': shimmerEffectBase1,
                              'highlight': shimmerEffectHighlight1,
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


