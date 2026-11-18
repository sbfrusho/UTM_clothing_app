import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/catalog_repository.dart';

class SearchViewModel extends GetxController {
  SearchViewModel(this._catalog, String initialQuery)
    : textController = TextEditingController(text: initialQuery),
      query = initialQuery.obs;

  final CatalogRepository _catalog;
  final TextEditingController textController;

  final RxString query;
  final RxList<ProductModel> results = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  late final Worker _debounce;

  @override
  void onInit() {
    super.onInit();
    _debounce = debounce<String>(
      query,
      _search,
      time: const Duration(milliseconds: 400),
    );
    _search(query.value);
  }

  void onQueryChanged(String value) => query.value = value;

  Future<void> _search(String value) async {
    final q = value.trim();
    if (q.length < 2) {
      results.clear();
      return;
    }
    isLoading.value = true;
    error.value = null;
    try {
      final found = await _catalog.search(q);
      if (query.value.trim() == q) results.assignAll(found); // drop stale
    } on AppException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce.dispose();
    textController.dispose();
    super.onClose();
  }
}
