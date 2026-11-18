import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/user_repository.dart';

class HomeViewModel extends GetxController {
  HomeViewModel(this._catalog, this._users, this._auth);

  final CatalogRepository _catalog;
  final UserRepository _users;
  final AuthService _auth;

  final RxList<String> banners = <String>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> onSale = <ProductModel>[].obs;
  final RxList<ProductModel> newArrivals = <ProductModel>[].obs;
  final RxString firstName = ''.obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void onInit() {
    super.onInit();
    load();
    _loadName();
  }

  /// Pull-to-refresh reloads the catalogue from the server.
  Future<void> refreshHome() => load(refresh: true);

  Future<void> load({bool refresh = false}) async {
    isLoading.value = true;
    error.value = null;
    try {
      final results = await Future.wait<Object>([
        _catalog.fetchBannerUrls(),
        _catalog.fetchCategories(refresh: refresh),
        _catalog.allProducts(refresh: refresh),
      ]);
      banners.assignAll(results[0] as List<String>);
      categories.assignAll(results[1] as List<CategoryModel>);
      onSale.assignAll(await _catalog.onSale(limit: 10));
      newArrivals.assignAll(await _catalog.newArrivals(limit: 8));
    } on AppException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadName() async {
    final uid = _auth.uid;
    if (uid == null) return;
    try {
      final name = (await _users.fetch(uid))?.name.trim() ?? '';
      firstName.value = name.split(' ').first;
    } on AppException {
      // Greeting falls back to no name.
    }
  }
}
