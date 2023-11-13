import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shimmer_effect/shimmer_effect.dart';

import '../models/painting.dart';
import '../services/api_services.dart';
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
  List<Painting> paintingList = [];
  void _loadPaintings() async{
    setState(() {
      _isLoading = true;
    });
    paintingList = [];
    try {
      List<Painting>? paintings = await _apiService.getDeliveries();
      setState(() {
        paintingList = paintings!;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching paintings: $e');
    }
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

@override
  void initState() {
  _scrollBottomBarController = ScrollController();
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
    _loadPaintings();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 15.0,right: 15.0,top: 40),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width *0.8,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _searchController,
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
                            child: Icon(Icons.search,color: Colors.white,size: 18,)),
                      ),
                    ),
                    onChanged: (value) {},
                    validator: (value) {},
                  ),
                ),
                SizedBox(width: 10,),
                GestureDetector(child:
                Container(
                    padding: EdgeInsets.all(7),
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color.fromARGB(255, 123, 123, 123)),
                        borderRadius: BorderRadius.circular(40)
                    ),
                    child: Image.asset('assets/images/filter.png',)),)
              ],),
            SizedBox(height: 15,),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorPadding: EdgeInsets.only(top: 45),
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
            ),
            Divider(thickness: 0.5,),
            Expanded(
              child: SingleChildScrollView(
                  controller: _scrollBottomBarController,
                  child: Container(
                    width: double.infinity,
                    height: paintingList.isNotEmpty?(paintingList.length) * (MediaQuery.of(context).size.height*0.54):MediaQuery.of(context).size.height*2,
                    child: paintingList.isNotEmpty
                        ? ListView.separated(
                      itemCount: paintingList.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => SizedBox(height: 0), // Adjust the height as needed
                      itemBuilder: (context, index) {
                        final item = paintingList[index];
                        return buildItemCard(context,item);
                      },
                    ):ListView.builder(
                      itemCount: 5,
                      itemBuilder: (ctx, inx) => const PaintingSkeleton(),
                    ),
                  )
              ),
            ),
          ],
        ),
      ),
      Center(child: Text("wish list Page")),
      Center(child: Text("notification page"),),
      Center(child: Text("Account page"),)
    ];
    return Scaffold(
      key:_globalkey,
      body: widgetOptions[_currentIndex],
      bottomNavigationBar: Container(
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
      baseColor: Color(0xFF6eded0).withOpacity(.3),
      highlightColor: Color(0xFF6eded0),
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
          color: Color(0xFF6eded0).withOpacity(.3),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Color(0xffd9d9d9).withAlpha(100),
      ),
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
                        'width': 60,
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
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


