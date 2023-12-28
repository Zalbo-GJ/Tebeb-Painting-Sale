import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:user/routes/app_routes.dart';

import '../models/painting.dart';
import '../services/painting_controller.dart';

class PaintingCard extends StatefulWidget {
  final Painting painting;

  PaintingCard({super.key, required this.painting});

  @override
  State<PaintingCard> createState() => _PaintingCardState();
}

class _PaintingCardState extends State<PaintingCard> {
  bool isLiked = false;
  final PaintingController _paintingController = Get.find<PaintingController>();
  @override
  void initState() {
    isLiked = widget.painting.isLikedByUser!;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Get.toNamed(AppRoutes.paintingDetailsPage,arguments: widget.painting);
      },
      child: Card(
        elevation: 4,
        color: Colors.white,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                widget.painting.imageLink??"https://magazine.artland.com/wp-content/uploads/2022/07/van-gogh-starry-night-min.jpg",
                fit: BoxFit.cover,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(alignment: Alignment.centerLeft,child:Text(widget.painting.name!,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.black),)),
                IconButton(onPressed: (){
                  setState(() {
                    isLiked = !isLiked;
                  });
                  _paintingController.updatePaintingStatus(widget.painting.id!, isLiked);
                },
                    icon: Icon(isLiked?Icons.favorite:Icons.favorite_border,color: isLiked?Colors.red:Colors.black,))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 35.0),
            child: Align(alignment: Alignment.centerLeft,child:Text("by "+"van gogh"!,style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal,fontStyle:FontStyle.italic,color: Colors.grey[400]),)),
          ),
          SizedBox(height: 7,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: Align(alignment: Alignment.centerLeft,child:Text("Br. 9,000,000",style: TextStyle(fontSize: 14,fontWeight: FontWeight.normal,color: Colors.black),)),
              ),
              Row(children: [
                Icon(Icons.star_rate_rounded,color: Colors.black,size: 20,),
                SizedBox(width: 10,),
                Text("4.91"),
                SizedBox(width: 10,)
              ],)
            ],
          ),
          SizedBox(height: 15,)
        ],),
      ),) ;
  }
}

class WishListCard extends StatefulWidget {
  final Painting painting;

  WishListCard({super.key, required this.painting});

  @override
  _WishListCardState createState() => _WishListCardState();
}

class _WishListCardState extends State<WishListCard> {
  bool isLiked = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Get.toNamed(AppRoutes.paintingDetailsPage,arguments: widget.painting);
      },
      child: Card(
        elevation: 4,
        color: Colors.white,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                widget.painting.imageLink??"https://magazine.artland.com/wp-content/uploads/2022/07/van-gogh-starry-night-min.jpg",
                fit: BoxFit.cover,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Align(alignment: Alignment.centerLeft,child:Text(widget.painting.name!,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.black),))),
                IconButton(onPressed: (){
                  setState(() {
                    isLiked = !isLiked;
                  });
                },
                    icon: Icon(isLiked?Icons.favorite:Icons.favorite_border,color: isLiked?Colors.red:Colors.black,size: 22,))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 35.0),
            child: Align(alignment: Alignment.centerLeft,child:Text("by "+"van gogh"!,style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal,fontStyle:FontStyle.italic,color: Colors.grey[400]),)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: Align(alignment: Alignment.centerLeft,child:Text("Br. 9,000,000",style: TextStyle(fontSize: 14,fontWeight: FontWeight.normal,color: Colors.black),)),
              ),
              Row(children: [
                Icon(Icons.star_rate_rounded,color: Colors.black,size: 20,),
                SizedBox(width: 10,),
                Text("4.91"),
                SizedBox(width: 10,)
              ],)
            ],
          ),
        ],),
      ),) ;
  }
}

Widget CartItem(BuildContext context,Painting painting){
  return Container(
    margin: EdgeInsets.all(8),
    width:MediaQuery.of(context).size.width,
    child: Card(
      elevation: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    painting.imageLink??"https://magazine.artland.com/wp-content/uploads/2022/07/van-gogh-starry-night-min.jpg",
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(painting.name!,style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold),),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                      padding: EdgeInsets.all(8),
                      child: Text("by vanGough",style: TextStyle(fontSize: 13,fontWeight: FontWeight.normal),)),
                  Row(children: [
                    Icon(Icons.star_rate_rounded,color: Colors.black,size: 20,),
                    SizedBox(width: 10,),
                    Text("4.91"),
                  ],)
                ],
              )
            ],
          ),
          Text("Br. 9,000,000")
        ],
      ),
    ),
  );
}
