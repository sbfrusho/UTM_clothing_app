import '../models/product_model.dart';

enum ProductSort {
  newest('Newest'),
  priceLowHigh('Price: low to high'),
  priceHighLow('Price: high to low'),
  biggestDiscount('Biggest discount'),
  nameAZ('Name: A to Z');

  const ProductSort(this.label);
  final String label;
}

/// Immutable browse criteria. [apply] is pure, so the same rules work
/// against an in-memory catalogue now and translate to a server query later.
class ProductFilter {
  const ProductFilter({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.sizes = const {},
    this.onSaleOnly = false,
    this.inStockOnly = false,
    this.sort = ProductSort.newest,
  });

  /// `null` means every category.
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;

  /// Matches products offering **any** of these sizes.
  final Set<String> sizes;
  final bool onSaleOnly;
  final bool inStockOnly;
  final ProductSort sort;

  /// Number of user-facing refinements (category and sort excluded),
  /// shown as a badge on the filter button.
  int get activeCount =>
      (minPrice != null || maxPrice != null ? 1 : 0) +
      (sizes.isNotEmpty ? 1 : 0) +
      (onSaleOnly ? 1 : 0) +
      (inStockOnly ? 1 : 0);

  bool get hasRefinements => activeCount > 0;

  /// Clears refinements but keeps the category and sort order.
  ProductFilter cleared() => ProductFilter(categoryId: categoryId, sort: sort);

  ProductFilter copyWith({
    double? Function()? minPrice,
    double? Function()? maxPrice,
    Set<String>? sizes,
    bool? onSaleOnly,
    bool? inStockOnly,
    ProductSort? sort,
  }) => ProductFilter(
    categoryId: categoryId,
    minPrice: minPrice != null ? minPrice() : this.minPrice,
    maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
    sizes: sizes ?? this.sizes,
    onSaleOnly: onSaleOnly ?? this.onSaleOnly,
    inStockOnly: inStockOnly ?? this.inStockOnly,
    sort: sort ?? this.sort,
  );

  bool matches(ProductModel p) {
    if (categoryId != null && p.categoryId != categoryId) return false;
    if (minPrice != null && p.price < minPrice!) return false;
    if (maxPrice != null && p.price > maxPrice!) return false;
    if (sizes.isNotEmpty && !p.sizes.any(sizes.contains)) return false;
    if (onSaleOnly && !p.isOnSale) return false;
    if (inStockOnly && !p.inStock) return false;
    return true;
  }

  List<ProductModel> apply(Iterable<ProductModel> products) =>
      products.where(matches).toList()..sort(comparator(sort));

  static int Function(ProductModel, ProductModel) comparator(
    ProductSort sort,
  ) => switch (sort) {
    ProductSort.newest => _byNewest,
    ProductSort.priceLowHigh => (a, b) => _then(
      a.price.compareTo(b.price),
      a,
      b,
    ),
    ProductSort.priceHighLow => (a, b) => _then(
      b.price.compareTo(a.price),
      a,
      b,
    ),
    ProductSort.biggestDiscount => (a, b) => _then(
      b.discountPercent.compareTo(a.discountPercent),
      a,
      b,
    ),
    ProductSort.nameAZ => (a, b) => _then(
      a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      a,
      b,
    ),
  };

  /// Newest first; undated products last; ties broken by name for a
  /// stable order between refreshes.
  static int _byNewest(ProductModel a, ProductModel b) {
    final da = a.createdAt, db = b.createdAt;
    if (da != null && db != null && da != db) return db.compareTo(da);
    if (da == null && db != null) return 1;
    if (da != null && db == null) return -1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  static int _then(int primary, ProductModel a, ProductModel b) =>
      primary != 0 ? primary : _byNewest(a, b);

  @override
  bool operator ==(Object other) =>
      other is ProductFilter &&
      other.categoryId == categoryId &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.sizes.length == sizes.length &&
      other.sizes.containsAll(sizes) &&
      other.onSaleOnly == onSaleOnly &&
      other.inStockOnly == inStockOnly &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    categoryId,
    minPrice,
    maxPrice,
    Object.hashAllUnordered(sizes),
    onSaleOnly,
    inStockOnly,
    sort,
  );
}

/// What a set of products offers, used to build the filter sheet.
class CatalogFacets {
  const CatalogFacets({
    required this.minPrice,
    required this.maxPrice,
    required this.sizes,
  });

  factory CatalogFacets.of(Iterable<ProductModel> products) {
    var lo = double.infinity, hi = 0.0;
    final sizes = <String>{};
    for (final p in products) {
      if (p.price > 0) {
        if (p.price < lo) lo = p.price;
        if (p.price > hi) hi = p.price;
      }
      sizes.addAll(p.sizes.map((s) => s.trim()).where((s) => s.isNotEmpty));
    }
    return CatalogFacets(
      minPrice: lo.isFinite ? lo.floorToDouble() : 0,
      maxPrice: hi.ceilToDouble(),
      sizes: sortSizes(sizes),
    );
  }

  final double minPrice;
  final double maxPrice;
  final List<String> sizes;

  bool get hasPriceRange => maxPrice > minPrice;

  static const _apparelOrder = [
    'XXS',
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    '2XL',
    'XXXL',
    '3XL',
    '4XL',
  ];

  /// Apparel sizes in wearing order, then numbers ascending, then the rest.
  static List<String> sortSizes(Iterable<String> sizes) {
    int rank(String s) {
      final i = _apparelOrder.indexOf(s.toUpperCase());
      if (i >= 0) return i;
      return num.tryParse(s) != null ? 100 : 200;
    }

    return sizes.toSet().toList()..sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      if (r != 0) return r;
      final na = num.tryParse(a), nb = num.tryParse(b);
      if (na != null && nb != null) return na.compareTo(nb);
      return a.compareTo(b);
    });
  }
}
