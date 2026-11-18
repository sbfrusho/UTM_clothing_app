import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/product_model.dart';

enum CartAddResult { added, increased, outOfStock, limitReached, sizeRequired }

/// Session-wide cart (in memory; persisted per user in Sprint 6).
class CartViewModel extends GetxController {
  final RxList<CartItemModel> items = <CartItemModel>[].obs;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  double get total => items.fold(0, (sum, i) => sum + i.total);
  bool get isEmpty => items.isEmpty;

  /// Distinct sellers in the cart (orders record all of them).
  List<String> get sellerIds => items
      .map((i) => i.sellerEmail)
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AuthService>()) {
      // Never carry a cart over to another account.
      ever(Get.find<AuthService>().user, (user) {
        if (user == null) clear();
      });
    }
  }

  /// Units of [productId] across all sizes (they share one stock counter).
  int quantityOf(String productId) => items
      .where((i) => i.productId == productId)
      .fold(0, (sum, i) => sum + i.quantity);

  CartAddResult add(ProductModel product, {String size = ''}) {
    if (!product.inStock) return CartAddResult.outOfStock;
    if (product.requiresSize && size.isEmpty) return CartAddResult.sizeRequired;
    if (quantityOf(product.id) >= product.stock) {
      return CartAddResult.limitReached;
    }

    final key = CartItemModel.keyFor(product.id, size);
    final index = items.indexWhere((i) => i.key == key);
    if (index >= 0) {
      items[index].quantity++;
      items.refresh();
      return CartAddResult.increased;
    }
    items.add(CartItemModel.fromProduct(product, size: size));
    return CartAddResult.added;
  }

  /// Returns false when stock does not allow another unit.
  bool increment(String key) {
    final index = items.indexWhere((i) => i.key == key);
    if (index < 0) return false;
    final item = items[index];
    if (quantityOf(item.productId) >= item.maxQuantity) return false;
    item.quantity++;
    items.refresh();
    return true;
  }

  void decrement(String key) {
    final index = items.indexWhere((i) => i.key == key);
    if (index < 0) return;
    if (items[index].quantity <= 1) {
      items.removeAt(index);
    } else {
      items[index].quantity--;
      items.refresh();
    }
  }

  void remove(String key) => items.removeWhere((i) => i.key == key);

  void clear() => items.clear();
}
