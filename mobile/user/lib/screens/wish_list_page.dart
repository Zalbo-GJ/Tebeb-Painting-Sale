import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../models/painting.dart';
import '../routes/app_routes.dart';
import '../services/api_services.dart';
import '../utils/colors.dart';
import '../utils/components.dart';
import 'landing_page.dart';

class WishListPage extends StatefulWidget {
  const WishListPage({super.key});

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage>with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();

  BottomDrawerController bottomDrawerController = BottomDrawerController();
  final ValueNotifier<bool> _isPanelOpenNotifier = ValueNotifier<bool>(false);

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
  List<Painting> paintingList = [];

  void _loadPaintings() async{
    setState(() {
      _isLoading = true;
    });
    paintingList = [];
    try {
      List<Painting>? paintings = await _apiService.getPaintings();
      setState(() {
        paintingList = paintings!;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching paintings: $e');
    }
  }
  void _searchPaintings() async{
    setState(() {
      _isLoading = true;
    });
    paintingList = [];
    try {
      if(_searchController.text == ''){
        List<Painting>? paintings = await _apiService.searchPainting(" ");
        setState(() {
          paintingList = paintings!;
          _isLoading = false;
        });
      }
      List<Painting>? paintings = await _apiService.searchPainting(_searchController.text);
      setState(() {
        paintingList = paintings!;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching paintings: $e');
    }
  }
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    _loadPaintings();
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
  @override
  Widget build(BuildContext context) {
    return Stack(
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
              ),
              Expanded(
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      height: 320.0 * ((paintingList.length/2).round()),
                      child:paintingList.isNotEmpty
                            ? GridView.count(
                            childAspectRatio: 0.64,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 20,
                            physics: ScrollPhysics(),
                            crossAxisCount: 2,
                            children: List.generate(paintingList.length, (index) {
                              return WishListCard(painting: paintingList[index]);
                            }),
                          )
                            : Column(
                          children: [
                            for (int i = 0; i < 5; i++) PaintingSkeleton(),
                          ],
                        ),
                      ),
                    )
                ),
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
    );
  }
}
