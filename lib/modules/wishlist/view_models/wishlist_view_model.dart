import 'dart:async';

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
import '../../cart/view_models/cart_view_model.dart';
import '../../shell/view_models/shell_view_model.dart';

/// Session-wide wishlist (`users/{uid}/wishlist`), shared by every product
/// card and the Saved tab. Toggles apply instantly and sync in the
/// background; the stream keeps devices in step.
class WishlistViewModel extends GetxController {
  WishlistViewModel({
    WishlistRepository? repository,
    CatalogRepository? catalog,
    AuthService? auth,
  }) : _repoOverride = repository,
       _catalogOverride = catalog,
       _authOverride = auth;

  final WishlistRepository? _repoOverride;
  final CatalogRepository? _catalogOverride;
  final AuthService? _authOverride;

  WishlistRepository get _repo =>
      _repoOverride ?? Get.find<WishlistRepository>();
  CatalogRepository get _catalog =>
      _catalogOverride ?? Get.find<CatalogRepository>();
  AuthService get _auth => _authOverride ?? Get.find<AuthService>();

  final RxList<WishlistItemModel> items = <WishlistItemModel>[].obs;

  /// Live catalogue data for saved items (price, stock), by product id.
  final RxMap<String, ProductModel> live = <String, ProductModel>{}.obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  /// True once [live] reflects the catalogue, so a missing entry means
  /// the product was removed (not merely still loading).
  final RxBool liveLoaded = false.obs;

  StreamSubscription<List<WishlistItemModel>>? _sub;
  String? _uid;

  /// Local toggles not yet confirmed by the stream (item = added,
  /// null = removed), so an early snapshot cannot flicker a heart.
  final Map<String, WishlistItemModel?> _pending = {};

  @override
  void onInit() {
    super.onInit();
    ever(_auth.user, (user) => _bind(user?.uid));
    _bind(_auth.uid);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  /// Read inside an `Obx` to subscribe; for lazily built lists.
  Set<String> get ids => items.map((i) => i.productId).toSet();

  int get count => items.length;

  bool isWishlisted(String productId) =>
      items.any((i) => i.productId == productId);

  Future<void> _bind(String? uid) async {
    if (uid == _uid) return;
    await _sub?.cancel();
    _uid = uid;
    items.clear();
    live.clear();
    liveLoaded.value = false;
    _pending.clear();
    error.value = null;
    if (uid == null) return;

    isLoading.value = true;
    final email = _auth.email;
    if (email != null) await _repo.migrateLegacy(uid: uid, email: email);
    if (_uid != uid) return; // signed out meanwhile

    _sub = _repo
        .watch(uid)
        .listen(
          (stored) {
            items.assignAll(applyPending(stored, _pending));
            isLoading.value = false;
            _refreshLive();
          },
          onError: (Object e, StackTrace st) {
            AppLogger.error('Wishlist stream failed', e, st);
            error.value = AppException.from(e).message;
            isLoading.value = false;
          },
        );
  }

  /// Overlays unconfirmed local toggles on a stream snapshot and forgets
  /// the ones the snapshot already reflects. Pure; unit tested.
  static List<WishlistItemModel> applyPending(
    List<WishlistItemModel> stored,
    Map<String, WishlistItemModel?> pending,
  ) {
    bool has(String id) => stored.any((i) => i.productId == id);
    pending.removeWhere((id, item) => has(id) == (item != null));
    final next = [
      for (final item in pending.values) ?item,
      ...stored.where((i) => !pending.containsKey(i.productId)),
    ];
    return next;
  }

  /// Pull-to-refresh: newest prices and stock from the server.
  Future<void> load() => _refreshLive(fromServer: true);

  Future<void> _refreshLive({bool fromServer = false}) async {
    if (items.isEmpty) return;
    try {
      final all = await _catalog.allProducts(refresh: fromServer);
      final wanted = ids;
      live.assignAll({
        for (final p in all)
          if (wanted.contains(p.id)) p.id: p,
      });
      liveLoaded.value = true;
    } on AppException catch (e) {
      AppLogger.error('Wishlist refresh skipped', e);
    }
  }

  // ----- edits ----------------------------------------------------------------

  Future<void> toggle(ProductModel product) async {
    if (isWishlisted(product.id)) {
      await remove(product.id);
    } else {
      final item = WishlistItemModel.fromProduct(product);
      _pending[product.id] = item;
      items.insert(0, item);
      live[product.id] = product;
      await _run(() => _repo.add(_uid!, item), product.id);
    }
  }

  Future<void> remove(String productId) async {
    final index = items.indexWhere((i) => i.productId == productId);
    if (index < 0) return;
    final removed = items.removeAt(index);
    _pending[productId] = null;
    final ok = await _run(() => _repo.remove(_uid!, productId), productId);
    if (ok) {
      AppSnackbar.action(
        'Removed from saved',
        removed.name,
        actionLabel: 'Undo',
        onAction: () => _restore(removed, index),
      );
    }
  }

  Future<void> _restore(WishlistItemModel item, int index) async {
    if (isWishlisted(item.productId)) return;
    _pending[item.productId] = item;
    items.insert(index.clamp(0, items.length), item);
    await _run(() => _repo.add(_uid!, item), item.productId);
  }

  Future<bool> _run(Future<void> Function() op, String productId) async {
    if (_uid == null) return false;
    try {
      await op();
      return true;
    } on AppException catch (e) {
      _pending.remove(productId);
      AppSnackbar.error(e.message);
      return false;
    }
  }

  // ----- navigation -----------------------------------------------------------

  /// Opens the live product (wishlist entries are snapshots).
  Future<void> open(WishlistItemModel item) async {
    try {
      final product =
          live[item.productId] ?? await _catalog.fetchProduct(item.productId);
      if (product == null) {
        AppSnackbar.info('This product is no longer available.');
        return;
      }
      Get.toNamed<void>(AppRoutes.productDetail, arguments: product);
    } on AppException catch (e) {
      AppSnackbar.error(e.message);
    }
  }

  /// Adds straight to the cart when no size choice is needed, otherwise
  /// opens the product to pick one.
  void moveToCart(WishlistItemModel item) {
    final product = live[item.productId];
    if (product == null || !product.inStock) {
      AppSnackbar.info('This product is not available right now.');
      return;
    }
    if (product.sizes.length > 1) {
      Get.toNamed<void>(AppRoutes.productDetail, arguments: product);
      return;
    }
    final size = product.sizes.isEmpty ? '' : product.sizes.first;
    final result = Get.find<CartViewModel>().add(product, size: size);
    switch (result) {
      case CartAddResult.added:
      case CartAddResult.increased:
        AppSnackbar.action(
          'Added to cart',
          product.name,
          actionLabel: 'View cart',
          onAction: () => Get.find<ShellViewModel>().goTo(ShellTab.cart),
        );
      case CartAddResult.limitReached:
        AppSnackbar.info('You already have all available units in your cart.');
      case CartAddResult.outOfStock:
      case CartAddResult.sizeRequired:
        Get.toNamed<void>(AppRoutes.productDetail, arguments: product);
    }
  }
}
