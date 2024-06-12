// // ignore_for_file: avoid_print

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:shopping_app/controller/cart-model-controller.dart';

// class CartController extends GetxController {
//   final CartModelController _cartModel = CartModelController();

//   List<CartItem> get cartItems => _cartModel.cartItems;

//   double get totalPrice => _cartModel.totalPrice;

//   void addToCart(CartItem item) {
//     _cartModel.addToCart(item);
//   }

//   void removeFromCart(String productId) {
//     _cartModel.removeFromCart(productId);
//   }

//   void updateQuantity(String productId, int newQuantity) {
//     _cartModel.updateQuantity(productId, newQuantity);
//   }

//   void clearCart() {
//     _cartModel.clearCart();
//   }

//   Future<void> placeOrder(
//       List<CartItem> cartItems,
//       double totalPrice,
//       String customerId,
//       String customerName,
//       String customerPhone,
//       String customerAddress,
//       String paymentMethod,
//       String deliveryTime) async {
//     try {
//       print("cartItems: $cartItems");
//       print("totalPrice: $totalPrice");
//       print("customerId: $customerId");
//       print("customerName: $customerName");
//       // Add order details to Firestore
//       DocumentReference orderRef =
//           await FirebaseFirestore.instance.collection('orders').add({ 
//         'customerId': customerId,
//         'customerName': customerName,
//         'customerPhone': customerPhone,
//         'customerAddress': customerAddress,
//         'paymentMethod': paymentMethod,
//         'deliveryTime': deliveryTime,
//         'totalPrice': totalPrice,
//         'status': 'Pending', // You can set initial status as 'Pending'
//         'createdAt': Timestamp.now(),
//       });
//       print("Order placed successfully");
//       // Add cart items to the order
//       for (var item in cartItems) {
//         await orderRef.collection('items').add({
//           'product_id': item.productId,
//           'product_name': item.productName,
//           'price': item.price,
//           'quantity': item.quantity,
//         });
//       }

//       // Clear the cart after placing order
//       clearCart();

//       // You can show a success message here
//     } catch (error) {
//       // Handle any errors
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shopping_app/controller/cart-model-controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartController extends GetxController {
  final CartModelController _cartModel = CartModelController();

  List<CartItem> get cartItems => _cartModel.cartItems;

  double get totalPrice => _cartModel.totalPrice;

  void addToCart(CartItem item) {
    _cartModel.addToCart(item);
  }

  void removeFromCart(String productId) {
    _cartModel.removeFromCart(productId);
  }

  void updateQuantity(String productId, int newQuantity) {
    _cartModel.updateQuantity(productId, newQuantity);
  }

  void clearCart() {
    _cartModel.clearCart();
  }

  Future<void> placeOrder(
      List<CartItem> cartItems,
      double totalPrice,
      String customerId,
      String customerName,
      String customerPhone,
      String customerAddress,
      String paymentMethod,
      String deliveryTime,
      ) async {
    try {
      // Get the current user's email
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle the case where there is no logged-in user
        throw Exception("No logged-in user");
      }
      String userEmail = user.email!;

      print("cartItems: $cartItems");
      print("totalPrice: $totalPrice");
      print("customerId: $customerId");
      print("customerName: $customerName");
      print("userEmail: $userEmail");

      // Add order details to Firestore
      DocumentReference orderRef =
          await FirebaseFirestore.instance.collection('orders').add({
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
        'paymentMethod': paymentMethod,
        'deliveryTime': deliveryTime,
        'totalPrice': totalPrice,
        'status': 'Pending', // You can set initial status as 'Pending'
        'createdAt': Timestamp.now(),
        'uniqueId': userEmail, // Add the uniqueId
      });
      print("Order placed successfully");

      // Add cart items to the order
      for (var item in cartItems) {
        await orderRef.collection('items').add({
          'product_id': item.productId,
          'product_name': item.productName,
          'price': item.price,
          'quantity': item.quantity,
        });
      }

      // Clear the cart after placing order
      clearCart();

      // You can show a success message here
    } catch (error) {
      print("Error placing order: $error");
      // Handle any errors
    }
  }
}
