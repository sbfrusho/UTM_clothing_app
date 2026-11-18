import 'package:flutter_test/flutter_test.dart';
import 'package:your_shop/data/catalog/catalog_source.dart';
import 'package:your_shop/data/catalog/product_filter.dart';
import 'package:your_shop/data/catalog/product_search_index.dart';
import 'package:your_shop/data/models/category_model.dart';
import 'package:your_shop/data/models/product_model.dart';
import 'package:your_shop/data/repositories/catalog_repository.dart';

ProductModel _p(
  String id,
  String name, {
  String cat = 'c1',
  String catName = 'Shirts',
  String sale = '50',
  String full = '50',
  int stock = 5,
  List<String> sizes = const [],
  DateTime? created,
  String description = '',
  bool isSale = false,
}) => ProductModel.fromMap({
  'productId': id,
  'productName': name,
  'categoryId': cat,
  'categoryName': catName,
  'salePrice': sale,
  'fullPrice': full,
  'quantity': '$stock',
  'productSizes': sizes,
  'productDescription': description,
  'isSale': isSale,
  'createdAt': created,
});

final _items = [
  _p(
    'a',
    'Linen Shirt',
    sale: '89',
    full: '119',
    sizes: ['M', 'L'],
    created: DateTime(2026, 3),
  ),
  _p(
    'b',
    'Oxford Shirt',
    sale: '120',
    sizes: ['S', 'M'],
    created: DateTime(2026, 5),
  ),
  _p(
    'c',
    'Everyday Cap',
    cat: 'c2',
    catName: 'Caps',
    sale: '35',
    full: '35',
    stock: 0,
    created: DateTime(2026, 4),
  ),
  _p(
    'd',
    'Stoneware Mug',
    cat: 'c3',
    catName: 'Mugs',
    sale: '29',
    full: '39',
    description: 'Holds a generous cup of coffee',
  ),
  _p(
    'e',
    'Graphic Tee',
    cat: 'c1',
    catName: 'Shirts',
    sale: '45',
    sizes: ['XL', 'S'],
    isSale: true,
    created: DateTime(2026, 6),
  ),
];

class _FakeSource implements CatalogSource {
  int productLoads = 0;

  @override
  Future<List<ProductModel>> loadProducts({required int max}) async {
    productLoads++;
    await Future<void>.delayed(Duration.zero);
    return _items;
  }

  @override
  Future<ProductModel?> loadProduct(String id) async =>
      _items.where((p) => p.id == id).firstOrNull;

  @override
  Future<List<CategoryModel>> loadCategories() async => const [
    CategoryModel(id: 'c2', name: 'caps', imageUrl: ''),
    CategoryModel(id: 'c1', name: 'Shirts', imageUrl: ''),
  ];

  @override
  Future<List<String>> loadBannerUrls() async => const [];
}

List<String> ids(List<ProductModel> l) => l.map((p) => p.id).toList();

void main() {
  group('ProductFilter', () {
    test('newest first, undated last', () {
      expect(ids(const ProductFilter().apply(_items)), [
        'e',
        'b',
        'c',
        'a',
        'd',
      ]);
    });

    test('price sorts use the numeric sale price, not strings', () {
      expect(
        ids(const ProductFilter(sort: ProductSort.priceLowHigh).apply(_items)),
        ['d', 'c', 'e', 'a', 'b'],
      );
      expect(
        ids(
          const ProductFilter(sort: ProductSort.priceHighLow).apply(_items),
        ).first,
        'b',
      );
    });

    test('category, price range, size, sale and stock combine', () {
      expect(ids(const ProductFilter(categoryId: 'c1').apply(_items)), [
        'e',
        'b',
        'a',
      ]);
      expect(
        ids(const ProductFilter(minPrice: 40, maxPrice: 100).apply(_items)),
        ['e', 'a'],
      );
      expect(ids(const ProductFilter(sizes: {'S'}).apply(_items)), ['e', 'b']);
      // Discounted (a, d) or flagged by the admin (e).
      expect(ids(const ProductFilter(onSaleOnly: true).apply(_items)), [
        'e',
        'a',
        'd',
      ]);
      expect(
        ids(const ProductFilter(inStockOnly: true).apply(_items)),
        isNot(contains('c')),
      );
    });

    test('activeCount ignores category and sort; cleared keeps them', () {
      const f = ProductFilter(
        categoryId: 'c1',
        sort: ProductSort.nameAZ,
        minPrice: 10,
        maxPrice: 20,
        sizes: {'M'},
        inStockOnly: true,
      );
      expect(f.activeCount, 3);
      expect(
        f.cleared(),
        const ProductFilter(categoryId: 'c1', sort: ProductSort.nameAZ),
      );
    });
  });

  test('literal "null" from the admin app reads as empty', () {
    final p = ProductModel.fromMap({
      'productName': 'Shoes',
      'categoryName': 'null',
    });
    expect(p.categoryName, '');
  });

  group('CatalogFacets', () {
    test('price bounds and sizes in wearing order', () {
      final f = CatalogFacets.of(_items);
      expect(f.minPrice, 29);
      expect(f.maxPrice, 120);
      expect(f.sizes, ['S', 'M', 'L', 'XL']);
    });

    test('numeric sizes sort numerically after letter sizes', () {
      expect(CatalogFacets.sortSizes(['42', 'M', '9', 'One size', 'S']), [
        'S',
        'M',
        '9',
        '42',
        'One size',
      ]);
    });
  });

  group('ProductSearchIndex', () {
    final index = ProductSearchIndex(_items);

    test('prefix and plural matching', () {
      expect(ids(index.search('shi')), containsAll(['a', 'b', 'e']));
      expect(ids(index.search('shirts')), containsAll(['a', 'b']));
      expect(ids(index.search('caps')), ['c']);
    });

    test('all words must match', () {
      expect(ids(index.search('linen shirt')), ['a']);
      expect(index.search('linen mug'), isEmpty);
    });

    test('name matches outrank description matches', () {
      final mugIndex = ProductSearchIndex([
        _p('x', 'Coffee Mug'),
        _p('y', 'Plain Mug', description: 'Great for coffee'),
      ]);
      expect(ids(mugIndex.search('coffee')), ['x', 'y']);
    });

    test('ignores punctuation and case; blank query finds nothing', () {
      expect(ids(index.search('  OXFORD!! ')), ['b']);
      expect(index.search('   '), isEmpty);
    });
  });

  group('CatalogRepository', () {
    late _FakeSource source;
    late DateTime now;
    late CatalogRepository repo;

    setUp(() {
      source = _FakeSource();
      now = DateTime(2026, 11, 18, 12);
      repo = CatalogRepository(source: source, clock: () => now);
    });

    test('concurrent callers share one load, then it is cached', () async {
      await Future.wait([
        repo.allProducts(),
        repo.allProducts(),
        repo.search('mug'),
      ]);
      expect(source.productLoads, 1);
      await repo.browse(const ProductFilter());
      expect(source.productLoads, 1);
    });

    test('reloads after the TTL or on refresh', () async {
      await repo.allProducts();
      now = now.add(CatalogRepository.cacheTtl + const Duration(seconds: 1));
      await repo.allProducts();
      expect(source.productLoads, 2);
      await repo.allProducts(refresh: true);
      expect(source.productLoads, 3);
    });

    test('related: same category first, in stock, excluding itself', () async {
      final related = await repo.related(_items[0]);
      expect(ids(related).take(2), unorderedEquals(['b', 'e']));
      expect(ids(related), isNot(contains('a')));
      expect(ids(related), isNot(contains('c'))); // sold out
    });

    test('onSale lists in-stock discounts, biggest first', () async {
      // Mug 26% off, shirt 25% off, tee flagged with no discount.
      expect(ids(await repo.onSale()), ['d', 'a', 'e']);
    });

    test('categories are sorted case-insensitively', () async {
      final cats = await repo.fetchCategories();
      expect(cats.map((c) => c.name), ['caps', 'Shirts']);
    });
  });
}
