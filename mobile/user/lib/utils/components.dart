import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/painting.dart';

Widget buildItemCard( BuildContext context, Painting painting){
  return Container(
    height:MediaQuery.of(context).size.height*0.54,
    child: GestureDetector(child: Column(children: [
      Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              painting.imageLink??"https://magazine.artland.com/wp-content/uploads/2022/07/van-gogh-starry-night-min.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.37,
            ),
          ),
          const  Positioned(
            top: 15,
            right: 16,
            child: Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
      SizedBox(height: 10,),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(alignment: Alignment.centerLeft,child:Text(painting.name!,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.black),)),
            Row(children: [
              Icon(Icons.star,color: Colors.black,size: 18,),
              Text("4.91")
            ],)
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Align(alignment: Alignment.centerLeft,child:Text(painting.description!,style: TextStyle(fontSize: 16,fontWeight: FontWeight.normal,color: Colors.grey[400]),)),
      ),
      SizedBox(height: 7,),
      Padding(
        padding: const EdgeInsets.only(left:8.0),
        child: Align(alignment: Alignment.centerLeft,child:Text("Br. 9,000,000"!,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.black),)),
      )
    ],),),
  ) ;
}