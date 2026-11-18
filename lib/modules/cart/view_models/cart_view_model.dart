import 'dart:async';

import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/catalog_repository.dart';

enum CartAddResult { added, increased, outOfStock, limitReached, sizeRequired }

/// Session-wide cart, persisted per user in `users/{uid}/cart`.
///
/// Edits apply locally at once (so the UI never waits) and are written in
/// the background; the Firestore stream then confirms them and brings in
/// changes from the user's other devices.
class CartViewModel extends GetxController {
  CartViewModel({
    CartRepository? repository,
    CatalogRepository? catalog,
    AuthService? auth,
  }) : _repoOverride = repository,
       _catalogOverride = catalog,
       _authOverride = auth;

  final CartRepository? _repoOverride;
  final CatalogRepository? _catalogOverride;
  final AuthService? _authOverride;

  CartRepository get _repo => _repoOverride ?? Get.find<CartRepository>();
  CatalogRepository get _catalog =>
      _catalogOverride ?? Get.find<CatalogRepository>();
  AuthService? get _auth =>
      _authOverride ??
      (Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null);

  final RxList<CartItemModel> items = <CartItemModel>[].obs;
  final RxBool isLoading = false.obs;

  /// What changed after the latest refresh ("price dropped", "sold out").
  final RxList<String> notices = <String>[].obs;

  StreamSubscription<List<CartItemModel>>? _sub;
  String? _uid;
  bool _reconciledThisSession = false;

  // ----- derived state ------------------------------------------------------

  List<CartItemModel> get availableItems =>
      items.where((i) => i.isAvailable).toList();

  bool get hasUnavailable => items.any((i) => !i.isAvailable);

  /// Units across available lines (cart badge).
  int get itemCount => availableItems.fold(0, (sum, i) => sum + i.quantity);

  double get total => availableItems.fold(0, (sum, i) => sum + i.total);
  bool get isEmpty => items.isEmpty;
  bool get canCheckout => availableItems.isNotEmpty && !hasUnavailable;

  /// Distinct sellers in the cart (orders record all of them).
  List<String> get sellerIds => availableItems
      .map((i) => i.sellerEmail)
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();

  /// Units of [productId] across all sizes (they share one stock counter).
  int quantityOf(String productId) => items
      .where((i) => i.productId == productId)
      .fold(0, (sum, i) => sum + i.quantity);

  // ----- lifecycle ----------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    final auth = _auth;
    if (auth == null) return; // tests without a session
    ever(auth.user, (user) => _bind(user?.uid));
    _bind(auth.uid);
  }

  void _bind(String? uid) {
    if (uid == _uid) return;
    _sub?.cancel();
    _uid = uid;
    _reconciledThisSession = false;
    // Never carry a cart over to another account.
    items.clear();
    notices.clear();
    if (uid == null) return;

    isLoading.value = true;
    _sub = _repo
        .watch(uid)
        .listen(
          (stored) {
            // Keep live availability computed locally.
            final status = {for (final i in items) i.key: i.isAvailable};
            items.assignAll(
              stored.map((i) => i.copyWith(isAvailable: status[i.key] ?? true)),
            );
            isLoading.value = false;
            if (!_reconciledThisSession) {
              _reconciledThisSession = true;
              refreshFromCatalog();
            }
          },
          onError: (Object e, StackTrace st) {
            AppLogger.error('Cart stream failed', e, st);
            isLoading.value = false;
          },
        );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // ----- edits ----------------------------------------------------------------

  CartAddResult add(ProductModel product, {String size = ''}) {
    if (!product.inStock) return CartAddResult.outOfStock;
    if (product.requiresSize && size.isEmpty) return CartAddResult.sizeRequired;
    if (quantityOf(product.id) >= product.stock) {
      return CartAddResult.limitReached;
    }

    final key = CartItemModel.keyFor(product.id, size);
    final index = items.indexWhere((i) => i.key == key);
    if (index >= 0) {
      // Adding from the product page also refreshes price and stock.
      final fresh = CartItemModel.fromProduct(product, size: size);
      final next = items[index].copyWith(
        quantity: items[index].quantity + 1,
        unitPrice: fresh.unitPrice,
        maxQuantity: fresh.maxQuantity,
        isAvailable: true,
      );
      items[index] = next;
      _write(next);
      return CartAddResult.increased;
    }
    final line = CartItemModel.fromProduct(
      product,
      size: size,
      addedAt: DateTime.now(),
    );
    items.add(line);
    _write(line, isNew: true);
    return CartAddResult.added;
  }

  /// Returns false when stock does not allow another unit.
  bool increment(String key) {
    final index = items.indexWhere((i) => i.key == key);
    if (index < 0) return false;
    final item = items[index];
    if (!item.isAvailable || quantityOf(item.productId) >= item.maxQuantity) {
      return false;
    }
    final next = item.copyWith(quantity: item.quantity + 1);
    items[index] = next;
    _write(next);
    return true;
  }

  void decrement(String key) {
    final index = items.indexWhere((i) => i.key == key);
    if (index < 0) return;
    final item = items[index];
    if (item.quantity <= 1) {
      remove(key);
    } else {
      final next = item.copyWith(quantity: item.quantity - 1);
      items[index] = next;
      _write(next);
    }
  }

  void remove(String key) {
    items.removeWhere((i) => i.key == key);
    final uid = _uid;
    if (uid != null) _background(() => _repo.remove(uid, key));
  }

  void removeUnavailable() {
    for (final item in items.where((i) => !i.isAvailable).toList()) {
      remove(item.key);
    }
  }

  /// Local clear after an order: the order transaction already deleted the
  /// stored lines.
  void clear() => items.clear();

  void dismissNotices() => notices.clear();

  // ----- reconciliation -------------------------------------------------------

  /// Brings names, prices and stock up to date with the catalogue: lowers
  /// quantities above stock, flags removed or sold-out products and records
  /// what changed in [notices]. Writes only lines that actually changed.
  Future<void> refreshFromCatalog({bool fromServer = false}) async {
    if (items.isEmpty) return;
    final List<ProductModel> products;
    try {
      products = await _catalog.allProducts(refresh: fromServer);
    } on AppException catch (e) {
      AppLogger.error('Cart refresh skipped', e);
      return;
    }
    final byId = {for (final p in products) p.id: p};
    final result = reconcile(items.toList(), byId);
    items.assignAll(result.items);
    notices.assignAll(result.notices);
    for (final line in result.changed) {
      _write(line);
    }
  }

  /// Pure reconciliation rule (unit tested). Stock is shared across sizes,
  /// so it is allotted to lines in cart order.
  static ({
    List<CartItemModel> items,
    List<CartItemModel> changed,
    List<String> notices,
  })
  reconcile(List<CartItemModel> lines, Map<String, ProductModel> live) {
    final out = <CartItemModel>[];
    final changed = <CartItemModel>[];
    final notices = <String>[];
    final remaining = <String, int>{};

    for (final line in lines) {
      final p = live[line.productId];
      if (p == null) {
        out.add(line.copyWith(isAvailable: false));
        notices.add('"${line.name}" is no longer available.');
        continue;
      }
      final left = remaining[p.id] ?? p.stock;
      if (left <= 0) {
        final next = line.copyWith(maxQuantity: p.stock, isAvailable: false);
        out.add(next);
        if (next.storedDiffers(line)) changed.add(next);
        notices.add('"${p.name}" is sold out.');
        continue;
      }
      final qty = line.quantity > left ? left : line.quantity;
      remaining[p.id] = left - qty;
      final next = line.copyWith(
        quantity: qty,
        name: p.name,
        imageUrl: p.thumbnail ?? line.imageUrl,
        unitPrice: p.price,
        sellerEmail: p.sellerEmail,
        maxQuantity: p.stock,
        isAvailable: true,
      );
      if (qty < line.quantity) {
        notices.add('Only $qty of "${p.name}" left, so we updated your cart.');
      }
      if ((p.price - line.unitPrice).abs() > 0.005) {
        notices.add(
          p.price < line.unitPrice
              ? '"${p.name}" dropped to ${Formatters.price(p.price)}.'
              : '"${p.name}" now costs ${Formatters.price(p.price)}.',
        );
      }
      out.add(next);
      if (next.storedDiffers(line)) changed.add(next);
    }
    return (items: out, changed: changed, notices: notices);
  }

  // ----- persistence ----------------------------------------------------------

  void _write(CartItemModel line, {bool isNew = false}) {
    final uid = _uid;
    if (uid == null) return;
    _background(() => _repo.save(uid, line, isNew: isNew));
  }

  /// Firestore queues writes offline and resolves them later, so failures
  /// here are rare (e.g. permissions) and only logged.
  void _background(Future<void> Function() op) {
    unawaited(
      op().catchError((Object e, StackTrace st) {
        AppLogger.error('Cart write failed', e, st);
      }),
    );
  }
}
