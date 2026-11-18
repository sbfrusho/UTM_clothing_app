import 'package:get/get.dart';
import 'package:your_shop/controller/cart-controller.dart';
import 'package:your_shop/controller/wishlist-controller.dart';

/// App-wide dependencies that live for the whole session.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CartController(), permanent: true);
    Get.put(WishlistController(), permanent: true);
  }
}
