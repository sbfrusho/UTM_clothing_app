import 'package:get/get.dart';
import 'cart-model.dart';

class CartController extends GetxController {
  final CartModel _cartModel = CartModel();

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
}

