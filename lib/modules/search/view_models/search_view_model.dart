import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/search_history_repository.dart';

class SearchViewModel extends GetxController {
  SearchViewModel(this._catalog, this._history, String initialQuery)
    : textController = TextEditingController(text: initialQuery),
      query = initialQuery.obs;

  static const minLength = 2;

  final CatalogRepository _catalog;
  final SearchHistoryRepository _history;
  final TextEditingController textController;

  final RxString query;
  final RxList<ProductModel> results = <ProductModel>[].obs;
  final RxList<String> recent = <String>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  late final Worker _debounce;
  int _requestId = 0;

  bool get hasQuery => query.value.trim().length >= minLength;

  @override
  void onInit() {
    super.onInit();
    _debounce = debounce<String>(
      query,
      _search,
      time: const Duration(milliseconds: 300),
    );
    _loadSuggestions();
    _search(query.value);
  }

  Future<void> _loadSuggestions() async {
    recent.assignAll(await _history.load());
    try {
      categories.assignAll(await _catalog.fetchCategories());
      // Warm the catalogue so the first search is instant.
      await _catalog.allProducts();
    } on AppException {
      // Suggestions are optional.
    }
  }

  void onQueryChanged(String value) => query.value = value;

  /// Keyboard "search" or a tapped suggestion: run now and remember it.
  void submit([String? value]) {
    final term = (value ?? textController.text).trim();
    if (value != null) {
      textController.text = value;
      textController.selection = TextSelection.collapsed(offset: value.length);
    }
    query.value = term;
    _search(term);
    if (term.length >= minLength) _remember(term);
  }

  void clear() {
    textController.clear();
    query.value = '';
  }

  /// Opening a result counts as a useful search.
  void onResultOpened() {
    final term = query.value.trim();
    if (term.length >= minLength) _remember(term);
  }

  Future<void> removeRecent(String term) async =>
      recent.assignAll(await _history.remove(term));

  Future<void> clearRecent() async {
    await _history.clear();
    recent.clear();
  }

  Future<void> _remember(String term) async =>
      recent.assignAll(await _history.add(term));

  Future<void> _search(String value) async {
    final q = value.trim();
    final id = ++_requestId;
    if (q.length < minLength) {
      results.clear();
      error.value = null;
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    error.value = null;
    try {
      final found = await _catalog.search(q);
      if (id == _requestId) results.assignAll(found); // drop stale responses
    } on AppException catch (e) {
      if (id == _requestId) error.value = e.message;
    } finally {
      if (id == _requestId) isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce.dispose();
    textController.dispose();
    super.onClose();
  }
}
