import '../catalog/catalog_source.dart';
import '../catalog/product_filter.dart';
import '../catalog/product_search_index.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Categories, banners and products (read-only for customers).
///
/// **Why an in-memory catalogue:** the admin app stores prices as strings
/// and writes no search keywords, so Firestore can neither sort by price
/// nor search inside names. The repository therefore keeps a snapshot of
/// the catalogue (read in chunks, refreshed every [cacheTtl]) and filters,
/// sorts and searches it locally.
///
/// Screens depend only on [browse], [search], [newArrivals] and friends.
/// When the catalogue grows past [maxCatalogSize] (or the admin app starts
/// writing a numeric `price` and `searchKeywords`), only this class changes:
/// [browse] becomes a cursor query and [search] calls Algolia/Typesense.
class CatalogRepository {
  CatalogRepository({CatalogSource? source, DateTime Function()? clock})
    : _source = source ?? FirestoreCatalogSource(),
      _now = clock ?? DateTime.now;

  /// Items shown per infinite-scroll page.
  static const pageSize = 20;
  static const maxCatalogSize = 2000;
  static const cacheTtl = Duration(minutes: 5);

  final CatalogSource _source;
  final DateTime Function() _now;

  final _productCache = _Cached<List<ProductModel>>();
  final _categoryCache = _Cached<List<CategoryModel>>();
  ProductSearchIndex? _index;

  // ---------------------------------------------------------------------------
  // Catalogue snapshot
  // ---------------------------------------------------------------------------

  /// Every product (up to [maxCatalogSize]). Concurrent callers share one
  /// load; [refresh] forces a reload (pull-to-refresh).
  Future<List<ProductModel>> allProducts({bool refresh = false}) =>
      _productCache.get(_loadAllProducts, now: _now(), refresh: refresh);

  Future<List<ProductModel>> _loadAllProducts() async {
    final all = await _source.loadProducts(max: maxCatalogSize);
    _index = ProductSearchIndex(all);
    return List.unmodifiable(all);
  }

  // ---------------------------------------------------------------------------
  // Queries used by screens
  // ---------------------------------------------------------------------------

  Future<List<ProductModel>> browse(
    ProductFilter filter, {
    bool refresh = false,
  }) async => filter.apply(await allProducts(refresh: refresh));

  /// Price range and sizes available within [categoryId] (or everywhere).
  Future<CatalogFacets> facets({String? categoryId}) async {
    final all = await allProducts();
    return CatalogFacets.of(
      categoryId == null ? all : all.where((p) => p.categoryId == categoryId),
    );
  }

  Future<List<ProductModel>> newArrivals({int limit = 10}) async =>
      (await browse(const ProductFilter())).take(limit).toList();

  Future<List<ProductModel>> onSale({int limit = 10}) async => (await browse(
    const ProductFilter(
      onSaleOnly: true,
      inStockOnly: true,
      sort: ProductSort.biggestDiscount,
    ),
  )).take(limit).toList();

  /// Same category first (in stock), then other in-stock products.
  Future<List<ProductModel>> related(
    ProductModel product, {
    int limit = 8,
  }) async {
    final others = (await allProducts())
        .where((p) => p.id != product.id && p.inStock)
        .toList();
    final same = others.where((p) => p.categoryId == product.categoryId);
    final rest = others.where((p) => p.categoryId != product.categoryId);
    return [...same, ...rest].take(limit).toList();
  }

  Future<List<ProductModel>> search(String query, {int limit = 60}) async {
    if (query.trim().isEmpty) return const [];
    await allProducts();
    return _index?.search(query, limit: limit) ?? const [];
  }

  /// Always read from the server: product details need live stock and price.
  Future<ProductModel?> fetchProduct(String id) => _source.loadProduct(id);

  // ---------------------------------------------------------------------------
  // Categories and banners
  // ---------------------------------------------------------------------------

  /// Sorted by name.
  Future<List<CategoryModel>> fetchCategories({bool refresh = false}) =>
      _categoryCache.get(
        () async {
          final list = [...await _source.loadCategories()]
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
          return List<CategoryModel>.unmodifiable(list);
        },
        now: _now(),
        refresh: refresh,
      );

  Future<List<String>> fetchBannerUrls() => _source.loadBannerUrls();
}

/// A value with a time-to-live and de-duplicated in-flight loads.
class _Cached<T> {
  T? _value;
  DateTime? _at;
  Future<T>? _inflight;

  Future<T> get(
    Future<T> Function() load, {
    required DateTime now,
    bool refresh = false,
  }) {
    final fresh =
        _value != null &&
        _at != null &&
        now.difference(_at!) < CatalogRepository.cacheTtl;
    if (!refresh && fresh) return Future.value(_value as T);
    return _inflight ??= load()
        .then((v) {
          _value = v;
          _at = now;
          return v;
        })
        .whenComplete(() => _inflight = null);
  }
}
