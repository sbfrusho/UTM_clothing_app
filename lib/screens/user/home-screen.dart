import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/screens/auth-ui/welcome-screen.dart';

import '../../widgets/Categories.dart';
import '../../widgets/slider-image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        leading: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async{
              // Handle logout
              await _auth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
            },
          ),],
        backgroundColor: AppColor().colorRed,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: const Color.fromARGB(255, 248, 246, 242),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.mic),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(30),
              //   child: SingleChildScrollView(
              //     scrollDirection: Axis.horizontal,
              //     child: Container(
              //       height: MediaQuery.of(context).size.height * .3, // Adjust height according to your needs
              //       width: MediaQuery.of(context).size.width,
              //       child: GridView.builder(
              //         scrollDirection: Axis.horizontal,
              //         itemCount:
              //             10, // Replace itemCount with your actual number of images
              //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //           crossAxisCount:
              //               1, // Adjust crossAxisCount according to your needs
              //           mainAxisSpacing: 10, // Adjust spacing as needed
              //         ),
              //         itemBuilder: (BuildContext context, int index) {
              //           // Replace Image.network with your image widget
              //           return Image(
              //             image: AssetImage(
              //                 'assets/utm.jpeg' ,),
              //                 height: 20.h,
              //                 width: 20.w, // Replace image path with your actual image path
              //             fit: BoxFit
              //                 .cover, // Adjust the fit property according to your needs
              //           );
              //         },
              //       ),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(10),
                // child: SliderImage(imageUrl: "assets/Tshirt/utm_tshirt_1.jpg",),
                child: Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        viewportFraction: 1,
                      ),
                      items: const [
                        SliderImage(
                          imageUrl: "assets/Tshirt/utm_tshirt_1.jpg",
                        ),
                        SliderImage(
                          imageUrl: "assets/Tshirt/image.png",
                        ),
                        SliderImage(
                          imageUrl: "assets/Tshirt/tshirt2.jpeg",
                        ),
                        SliderImage(
                          imageUrl: "assets/Corporate/key.png",
                        ),
                        SliderImage(
                          imageUrl: "assets/Cap/cap1.jpeg",
                        ),
                        SliderImage(
                          imageUrl: "assets/Cap/cap2.png",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Categories(),

              SizedBox(
                height: 20.h,
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                // child: SliderImage(imageUrl: "assets/Tshirt/utm_tshirt_1.jpg",),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 30, bottom: 20),
                      child: Text("Recommended for you"),
                    ),
                    CarouselSlider(
                      options: CarouselOptions(
                        viewportFraction: 1,
                      ),
                      items: const [
                        SliderImage(
                          imageUrl: "assets/Tshirt/utm_tshirt_1.jpg",
                        ),
                        SliderImage(
                          imageUrl: "assets/Tshirt/image.png",
                        ),
                        SliderImage(
                          imageUrl: "assets/Tshirt/tshirt2.jpeg",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Set the initial index of the selected item
        selectedItemColor: Colors.red, // Set the color of the selected item
        unselectedItemColor:
            Colors.grey, // Set the color of the unselected items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle the tap event for each item
          switch (index) {
            case 0:
              // Handle the Home item tap
              break;
            case 1:
              // Handle the Wishlist item tap
              break;
            case 2:
              // Handle the Categories item tap
              break;
            case 3:
              // Handle the Cart item tap
              break;
            case 4:
              // Handle the Profile item tap
              break;
          }
        },
      ),
    );
  }
}
