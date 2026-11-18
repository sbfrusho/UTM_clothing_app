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
  final RxList<ProductModel> latestProducts = <ProductModel>[].obs;
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

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final results = await Future.wait<Object>([
        _catalog.fetchBannerUrls(),
        _catalog.fetchCategories(),
        _catalog.fetchLatest(),
      ]);
      banners.assignAll(results[0] as List<String>);
      categories.assignAll(results[1] as List<CategoryModel>);
      latestProducts.assignAll(results[2] as List<ProductModel>);
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
