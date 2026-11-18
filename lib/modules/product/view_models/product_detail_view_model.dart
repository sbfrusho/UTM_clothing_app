import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/catalog/product_filter.dart';
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
  final RxList<ProductModel> related = <ProductModel>[].obs;
  final scrollController = ScrollController();

  /// Sizes in wearing order (S, M, L…), whatever order the admin saved.
  List<String> get sizes => CatalogFacets.sortSizes(product.value.sizes);

  bool get isWishlisted => _wishlist.isWishlisted(product.value.id);
  Set<String> get wishlistedIds => _wishlist.ids;
  void toggleRelatedWishlist(ProductModel p) => _wishlist.toggle(p);
  bool get canContactSupport => AppConfig.supportWhatsApp.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    if (product.value.sizes.length == 1) {
      selectedSize.value = product.value.sizes.first;
    }
    _refresh();
    _loadRelated();
  }

  Future<void> _loadRelated() async {
    try {
      final id = product.value.id;
      final list = await _catalog.related(product.value);
      if (product.value.id == id) related.assignAll(list);
    } on AppException {
      // Optional section.
    }
  }

  /// Full-screen, zoomable gallery starting at the visible image.
  void openGallery() {
    if (product.value.images.isEmpty) return;
    Get.toNamed<void>(
      AppRoutes.productGallery,
      arguments: GalleryArgs(product.value.images, imageIndex.value),
    );
  }

  /// Shows another product from "You may also like" on this same page,
  /// so the back stack does not grow without bound.
  void openRelated(ProductModel other) {
    product.value = other;
    imageIndex.value = 0;
    selectedSize.value = other.sizes.length == 1 ? other.sizes.first : '';
    related.clear();
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
    _refresh();
    _loadRelated();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _refresh() async {
    try {
      final id = product.value.id;
      final fresh = await _catalog.fetchProduct(id);
      if (fresh != null && product.value.id == id) product.value = fresh;
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
        AppSnackbar.action(
          'Added to cart',
          product.value.name,
          actionLabel: 'View cart',
          onAction: goToCart,
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

class GalleryArgs {
  const GalleryArgs(this.images, this.initialIndex);

  final List<String> images;
  final int initialIndex;
}
