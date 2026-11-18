import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../cart/view_models/cart_view_model.dart';
import '../../shell/view_models/shell_view_model.dart';
import '../../wishlist/view_models/wishlist_view_model.dart';

class ProductDetailViewModel extends GetxController {
  ProductDetailViewModel(
    this._catalog,
    this._cart,
    this._wishlist,
    ProductModel initial,
  ) : product = initial.obs;

  final CatalogRepository _catalog;
  final CartViewModel _cart;
  final WishlistViewModel _wishlist;

  /// Starts with the list's copy and is refreshed for live stock/price.
  final Rx<ProductModel> product;
  final RxString selectedSize = ''.obs;
  final RxInt imageIndex = 0.obs;

  bool get isWishlisted => _wishlist.isWishlisted(product.value.id);
  bool get canContactSupport => AppConfig.supportWhatsApp.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    if (product.value.sizes.length == 1) {
      selectedSize.value = product.value.sizes.first;
    }
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final fresh = await _catalog.fetchProduct(product.value.id);
      if (fresh != null) product.value = fresh;
    } on AppException {
      // Keep showing the cached copy.
    }
  }

  void selectSize(String size) => selectedSize.value = size;

  void toggleWishlist() => _wishlist.toggle(product.value);

  void addToCart() {
    final result = _cart.add(product.value, size: selectedSize.value);
    switch (result) {
      case CartAddResult.added:
      case CartAddResult.increased:
        Get.snackbar(
          'Added to cart',
          product.value.name,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          mainButton: TextButton(
            onPressed: goToCart,
            child: const Text('View cart'),
          ),
        );
      case CartAddResult.sizeRequired:
        AppSnackbar.info('Please choose a size first.', title: 'Select size');
      case CartAddResult.outOfStock:
        AppSnackbar.error('This product is out of stock.');
      case CartAddResult.limitReached:
        AppSnackbar.info(
          'You already have all ${product.value.stock} available in your cart.',
          title: 'Stock limit',
        );
    }
  }

  void goToCart() {
    Get.until((route) => route.settings.name == AppRoutes.shell);
    Get.find<ShellViewModel>().goTo(ShellTab.cart);
  }

  Future<void> contactSupport() async {
    final text = Uri.encodeComponent(
      'Hi, I have a question about "${product.value.name}".',
    );
    final uri = Uri.parse(
      'https://wa.me/${AppConfig.supportWhatsApp}?text=$text',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) AppSnackbar.error('Could not open WhatsApp.');
  }
}
