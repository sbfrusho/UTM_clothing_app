import 'package:get/get.dart';
import 'package:shopping_app/My%20Cart/my_cart_view.dart';
import 'package:shopping_app/controller/cart-model.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;

  addToCart(CartItem item) {
    cartItems.add(item);
    CartScreen(cartItems: cartItems);
    print(cartItems.length);
  }

  removeFromCart(CartItem item) {
    cartItems.remove(item);
  }
}
