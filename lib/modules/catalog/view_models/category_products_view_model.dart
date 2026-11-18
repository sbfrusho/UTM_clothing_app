import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/catalog_repository.dart';

/// Infinite-scroll product list for one category (cursor pagination).
class CategoryProductsViewModel extends GetxController {
  CategoryProductsViewModel(this._catalog, this.category);

  final CatalogRepository _catalog;
  final CategoryModel category;

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxnString error = RxnString();

  DocumentSnapshot<Map<String, dynamic>>? _cursor;

  @override
  void onInit() {
    super.onInit();
    refreshProducts();
  }

  Future<void> refreshProducts() async {
    isLoading.value = true;
    error.value = null;
    _cursor = null;
    hasMore.value = true;
    try {
      final page = await _catalog.fetchByCategory(category.id);
      products.assignAll(page.items);
      _cursor = page.cursor;
      hasMore.value = page.hasMore;
    } on AppException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    try {
      final page = await _catalog.fetchByCategory(
        category.id,
        startAfter: _cursor,
      );
      products.addAll(page.items);
      _cursor = page.cursor;
      hasMore.value = page.hasMore;
    } on AppException catch (e) {
      error.value = e.message;
      hasMore.value = false;
    } finally {
      isLoadingMore.value = false;
    }
  }
}
