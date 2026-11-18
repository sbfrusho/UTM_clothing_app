import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/catalog/product_filter.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/catalog_repository.dart';

/// What to list: a category, everything, or a preset (e.g. on sale).
class ProductListArgs {
  const ProductListArgs({
    required this.title,
    this.filter = const ProductFilter(),
  });

  factory ProductListArgs.category(CategoryModel c) => ProductListArgs(
    title: c.name,
    filter: ProductFilter(categoryId: c.id),
  );

  static const all = ProductListArgs(title: 'All products');

  final String title;
  final ProductFilter filter;
}

/// Filterable, sortable product grid with infinite scroll.
class ProductListViewModel extends GetxController {
  ProductListViewModel(this._catalog, this.args)
    : filter = args.filter.obs,
      draft = args.filter.obs;

  final CatalogRepository _catalog;
  final ProductListArgs args;

  /// Applied criteria.
  final Rx<ProductFilter> filter;

  /// Edited in the filter sheet; copied to [filter] on "Show results".
  final Rx<ProductFilter> draft;

  final Rx<CatalogFacets> facets = const CatalogFacets(
    minPrice: 0,
    maxPrice: 0,
    sizes: [],
  ).obs;

  final RxList<ProductModel> visible = <ProductModel>[].obs;
  final RxInt totalCount = 0.obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();

  List<ProductModel> _matches = const [];

  bool get hasMore => visible.length < _matches.length;

  @override
  void onInit() {
    super.onInit();
    ever<ProductFilter>(filter, (_) => _load());
    ever<ProductFilter>(draft, (_) => _updateDraftCount());
    _load();
  }

  Future<void> refreshProducts() => _load(refresh: true);

  Future<void> _load({bool refresh = false}) async {
    isLoading.value = true;
    error.value = null;
    try {
      _matches = await _catalog.browse(filter.value, refresh: refresh);
      facets.value = await _catalog.facets(categoryId: filter.value.categoryId);
      totalCount.value = _matches.length;
      visible.assignAll(_matches.take(CatalogRepository.pageSize));
    } on AppException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reveals the next page of already-matched products.
  void loadMore() {
    if (isLoading.value || !hasMore) return;
    visible.addAll(
      _matches.skip(visible.length).take(CatalogRepository.pageSize),
    );
  }

  void setSort(ProductSort sort) =>
      filter.value = filter.value.copyWith(sort: sort);

  // ----- filter sheet -------------------------------------------------------

  void beginEditing() {
    draft.value = filter.value;
    draftCount.value = totalCount.value;
  }

  void setDraftPrice(double min, double max) {
    final f = facets.value;
    draft.value = draft.value.copyWith(
      minPrice: () => min <= f.minPrice ? null : min,
      maxPrice: () => max >= f.maxPrice ? null : max,
    );
  }

  void toggleDraftSize(String size) {
    final next = {...draft.value.sizes};
    next.contains(size) ? next.remove(size) : next.add(size);
    draft.value = draft.value.copyWith(sizes: next);
  }

  void setDraftOnSale(bool v) =>
      draft.value = draft.value.copyWith(onSaleOnly: v);

  void setDraftInStock(bool v) =>
      draft.value = draft.value.copyWith(inStockOnly: v);

  void resetDraft() => draft.value = draft.value.cleared();

  /// How many products the draft would show (live count on the button).
  final RxInt draftCount = 0.obs;

  Future<void> _updateDraftCount() async {
    try {
      draftCount.value = (await _catalog.browse(draft.value)).length;
    } on AppException {
      draftCount.value = 0;
    }
  }

  void applyDraft() => filter.value = draft.value;

  void clearFilters() => filter.value = filter.value.cleared();
}
