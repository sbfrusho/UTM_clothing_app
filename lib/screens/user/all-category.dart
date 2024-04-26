// ignore_for_file: file_names, prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:shopping_app/const/app-colors.dart';

import '../../models/Category-model.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor().backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: AppColor().colorRed,
        title: Text(
          "All Categories",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: FirebaseFirestore.instance.collection("categories").get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              return GridView.builder(
                  itemCount: snapshot.data!.docs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                      childAspectRatio: 1.19),
                  itemBuilder: (context, index) {
                    CategoriesModel categoriesModel = CategoriesModel(
                        categoryId: snapshot.data!.docs[index]['categoryId'],
                        categoryImg: snapshot.data!.docs[index]['categoryImg'],
                        categoryName: snapshot.data!.docs[index]['categoryName'],
                        createdAt: snapshot.data!.docs[index]['createdAt'],
                        updatedAt: snapshot.data!.docs[index]['updatedAt']);
        
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FillImageCard(
                            width: MediaQuery.of(context).size.width * .4,
                            height: MediaQuery.of(context).size.height,
                            heightImage: MediaQuery.of(context).size.height * .10,
                            imageProvider: CachedNetworkImageProvider(
                              categoriesModel.categoryImg,
                            ),
                            title: Center(
                              child: Text(categoriesModel.categoryName),
                            ),
                          ),
                        ),
                      ],
                    );
                  });
              // return Container(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const Padding(
              //         padding: EdgeInsets.only(bottom: 20),
              //       ),
              //       SizedBox(
              //         height: MediaQuery.of(context).size.height * .2,
              //         width: MediaQuery.of(context).size.width * .8,
              //         child: SingleChildScrollView(
              //           scrollDirection: Axis.horizontal,
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //             children: snapshot.data!.docs.map((DocumentSnapshot document) {
              //               return Padding(
              //                 padding: const EdgeInsets.all(10),
              //                 child: GestureDetector(
              //                   onTap: () {
              //                     // Navigator.push(
              //                     //     context,
              //                     //     MaterialPageRoute(
              //                     //         builder: (context) => CorporateScreen()));
              //                   },
              //                   child: Column(
              //                     children: [
              //                       Image(
              //                         image: CachedNetworkImageProvider(document['categoryImg']),
              //                         height: 100.h,
              //                       ),
              //                       Text(document['categoryName']),
              //                     ],
              //                   ),
              //                 ),
              //               );
              //             }).toList(),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // );
            } else if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text("No data found"),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
