import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/catalog_repository.dart';

class HomeViewModel extends GetxController {
  HomeViewModel(this._catalog);

  final CatalogRepository _catalog;

  final RxList<String> banners = <String>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> latestProducts = <ProductModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final results = await Future.wait([
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
}
