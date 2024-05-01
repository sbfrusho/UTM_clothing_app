import 'package:get/get.dart';
import 'package:shopping_app/controller/cart-model.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;

  void addToCart(CartItem item) {
    cartItems.add(item);
  }

  void removeFromCart(String index) {
    int itemIndex = int.tryParse(index) ?? -1;
    if (itemIndex >= 0 && itemIndex < cartItems.length) {
      cartItems.removeAt(itemIndex);
    }
  }

  void increaseQuantity(String index) {
    int itemIndex = int.tryParse(index) ?? -1;
    if (itemIndex >= 0 && itemIndex < cartItems.length) {
      cartItems[itemIndex].quantity = (cartItems[itemIndex].quantity ?? 1) + 1;
    }
  }

  void decreaseQuantity(String index) {
    int itemIndex = int.tryParse(index) ?? -1;
    if (itemIndex >= 0 && itemIndex < cartItems.length) {
      if (cartItems[itemIndex].quantity != null && cartItems[itemIndex].quantity! > 1) {
        cartItems[itemIndex].quantity = cartItems[itemIndex].quantity! - 1;
      }
    }
  }

  double get totalPrice {
    return cartItems.fold(0, (total, item) {
      final price = item.price ?? 0;
      final quantity = item.quantity ?? 1;
      return total + (price * quantity);
    });
  }
}
