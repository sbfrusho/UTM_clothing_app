import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/wishlist_item_model.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';

/// Session-wide wishlist, shared by product cards and the wishlist tab.
class WishlistViewModel extends GetxController {
  WishlistRepository get _repo => Get.find<WishlistRepository>();
  AuthService get _auth => Get.find<AuthService>();

  final RxList<WishlistItemModel> items = <WishlistItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    ever(_auth.user, (_) => load());
    load();
  }

  bool isWishlisted(String productId) =>
      items.any((i) => i.productId == productId);

  Future<void> load() async {
    final email = _auth.email;
    if (email == null) {
      items.clear();
      return;
    }
    isLoading.value = true;
    error.value = null;
    try {
      items.assignAll(await _repo.fetch(email));
    } on AppException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggle(ProductModel product) async {
    if (isWishlisted(product.id)) {
      await remove(product.id);
    } else {
      items.add(WishlistItemModel.fromProduct(product));
      await _persist();
    }
  }

  Future<void> remove(String productId) async {
    items.removeWhere((i) => i.productId == productId);
    await _persist();
  }

  /// Opens the live product (wishlist entries are snapshots).
  Future<void> open(WishlistItemModel item) async {
    try {
      final product = await Get.find<CatalogRepository>().fetchProduct(
        item.productId,
      );
      if (product == null) {
        AppSnackbar.info('This product is no longer available.');
        return;
      }
      Get.toNamed(AppRoutes.productDetail, arguments: product);
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    }
  }

  Future<void> _persist() async {
    final email = _auth.email;
    if (email == null) return;
    try {
      await _repo.save(email, items.toList());
    } on AppException catch (e) {
      AppLogger.error('Wishlist save failed', e);
      AppSnackbar.error(e.message);
    }
  }
}
