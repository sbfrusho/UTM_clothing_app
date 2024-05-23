import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shopping_app/const/app-colors.dart';
import 'package:shopping_app/controller/cart-controller.dart';
import 'package:shopping_app/models/product-model.dart';
import 'package:shopping_app/models/wishlist-model.dart';
import 'package:shopping_app/screens/user/home-screen.dart';
import 'package:shopping_app/screens/user/wish-list.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../My Cart/my_cart_view.dart';
import '../../controller/cart-model-controller.dart';
import '../../controller/wishlist-controller.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel productModel;

  ProductDetailScreen({Key? key, required this.productModel}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  CartController cartController = Get.put(CartController());
  WishlistController wishlistController = Get.put(WishlistController());
  bool isInWishlist = false;

  @override
  void initState() {
    super.initState();
    isInWishlist = wishlistController.wishlistItems
        .any((item) => item.productId == widget.productModel.productId);
  }

  Future<void> _launchWhatsApp() async {
    const String userPhoneNumber = "01781314166";
    final String whatsappUrl = "https://wa.me/$userPhoneNumber";

    try {
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  void sendWhatsAp() {
    String phoneNumber = "+880 1677-652072";
    String url = "whatsapp://send?phone= $phoneNumber";
    launchUrl(Uri.parse(url));
  }

  void addToWishlist() {
    WishListModel wishlistItem = WishListModel(
      productId: widget.productModel.productId,
      categoryId: widget.productModel.categoryId,
      productName: widget.productModel.productName,
      categoryName: widget.productModel.categoryName,
      salePrice: widget.productModel.salePrice,
      fullPrice: widget.productModel.fullPrice,
      productImages: widget.productModel.productImages,
      deliveryTime: widget.productModel.deliveryTime,
      isSale: widget.productModel.isSale,
      productDescription: widget.productModel.productDescription,
      createdAt: widget.productModel.createdAt,
      updatedAt: widget.productModel.updatedAt,
    );

    if (isInWishlist) {
      wishlistController.removeFromWishlistById(widget.productModel.productId);
    } else {
      wishlistController.addToWishlist(wishlistItem);
    }

    setState(() {
      isInWishlist = !isInWishlist;
    });

    // Upload the wishlist to Firebase for the specific user
    wishlistController.uploadWishlist("user123"); // Replace with actual user ID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor().colorRed,
        title: Text(widget.productModel.productName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: Image.network(
                widget.productModel.productImages[0],
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productModel.productName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sale Price: \$${widget.productModel.salePrice}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Full Price: \$${widget.productModel.fullPrice}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.productModel.productDescription,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: sendWhatsAp,
                    icon: Icon(FontAwesomeIcons.whatsapp),
                    label: Text("Contact Us"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      cartController.addToCart(
                        CartItem(
                          productId: widget.productModel.productId,
                          productName: widget.productModel.productName,
                          productImage: widget.productModel.productImages[0],
                          price: widget.productModel.salePrice,
                          quantity: 1,
                        ),
                      );
                      Fluttertoast.showToast(msg: "added to cart");
                    },
                    icon: Icon(Icons.add_shopping_cart),
                    label: Text("Add to Cart"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor().colorRed,
                    ),
                  ),
                  IconButton(
                    onPressed: addToWishlist,
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WishlistScreen(
                    // productModel: widget.productModel,
                    // wishListModel: WishListModel(
                    //   productId: widget.productModel.productId,
                    //   categoryId: widget.productModel.categoryId,
                    //   productName: widget.productModel.productName,
                    //   categoryName: widget.productModel.categoryName,
                    //   salePrice: widget.productModel.salePrice,
                    //   fullPrice: widget.productModel.fullPrice,
                    //   productImages: widget.productModel.productImages,
                    //   deliveryTime: widget.productModel.deliveryTime,
                    //   isSale: widget.productModel.isSale,
                    //   productDescription: widget.productModel.productDescription,
                    //   createdAt: widget.productModel.createdAt,
                    //   updatedAt: widget.productModel.updatedAt,
                    // ),
                    wishlistItems: [
                      WishListModel(
                        productId: widget.productModel.productId,
                        categoryId: widget.productModel.categoryId,
                        productName: widget.productModel.productName,
                        categoryName: widget.productModel.categoryName,
                        salePrice: widget.productModel.salePrice,
                        fullPrice: widget.productModel.fullPrice,
                        productImages: widget.productModel.productImages,
                        deliveryTime: widget.productModel.deliveryTime,
                        isSale: widget.productModel.isSale,
                        productDescription: widget.productModel.productDescription,
                        createdAt: widget.productModel.createdAt,
                        updatedAt: widget.productModel.updatedAt,
                      ),
                    ],
                  ),
                ),
              );
              break;
            case 2:
              // Handle the Categories item tap
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(),
                ),
              );
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
