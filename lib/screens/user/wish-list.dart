import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_shop/screens/user/my-cart-screen.dart';
import 'package:your_shop/const/app-colors.dart';
import 'package:your_shop/controller/wishlist-controller.dart';
import 'package:your_shop/models/wishlist-model.dart';
import 'package:your_shop/screens/user/all-category.dart';
import 'package:your_shop/screens/user/home-screen.dart';
import 'package:your_shop/screens/user/settings.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Future<void> _wishlistFuture;
  final WishlistController wishlistController = Get.find<WishlistController>();
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    _wishlistFuture = wishlistController.fetchWishlist();
  }

  void _showEditDialog(WishListModel item) {
    final TextEditingController timeSlotController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Time Slot'),
          content: TextField(
            controller: timeSlotController,
            decoration: InputDecoration(hintText: "Enter new time slot"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (timeSlotController.text.isNotEmpty) {
                  wishlistController.updateTimeSlot(item, timeSlotController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist' , style: TextStyle(color: Colors.white),),
        backgroundColor: AppColor().colorRed,
      ),
      body: FutureBuilder<void>(
        future: _wishlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Obx(
              () {
                if (wishlistController.wishlistItems.isEmpty) {
                  return Center(child: Text('No items in your wishlist.'));
                } else {
                  return ListView.builder(
                    itemCount: wishlistController.wishlistItems.length,
                    itemBuilder: (context, index) {
                      final item = wishlistController.wishlistItems[index];
                      return ListTile(
                        leading: Image.network(
                          item.productImages[0],
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                        title: Text(item.productName),
                        subtitle: Text('Sale Price: ${item.salePrice} RM\nTime Slot: ${item.timeSlot}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(item);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                wishlistController.removeFromWishlistById(item.productId);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
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
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
                break;
              case 1:
                // Handle the Wishlist item tap
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WishlistScreen()));
                break;
              case 2:
                // Handle the Categories item tap
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AllCategoriesScreen()));
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
                break;
              case 4:
                // Handle the Profile item tap
                Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsScreen(email: user!.email.toString(),)));
                break;
            }
          },
        ),
    );
  }
}
