import '../models/product_model.dart';

/// Tokenised, ranked product search.
///
/// Every query word must match the start of a word in the product's name,
/// category or description, so "shi" and "shirts" both find "Shirt".
/// Name matches rank above category matches, which rank above description.
class ProductSearchIndex {
  ProductSearchIndex(Iterable<ProductModel> products)
    : _entries = products.map(_Entry.new).toList(growable: false);

  final List<_Entry> _entries;

  List<ProductModel> search(String query, {int limit = 60}) {
    final terms = tokenize(query);
    if (terms.isEmpty) return const [];
    final phrase = normalize(query);

    final scored = <(ProductModel, int)>[];
    for (final e in _entries) {
      var score = 0;
      var allMatched = true;
      for (final t in terms) {
        final s = e.scoreTerm(t);
        if (s == 0) {
          allMatched = false;
          break;
        }
        score += s;
      }
      if (!allMatched) continue;
      if (e.name.startsWith(phrase)) score += 20;
      if (e.product.inStock) score += 1;
      scored.add((e.product, score));
    }
    scored.sort((a, b) {
      final s = b.$2.compareTo(a.$2);
      return s != 0 ? s : a.$1.name.compareTo(b.$1.name);
    });
    return scored.take(limit).map((e) => e.$1).toList();
  }

  // ---------------------------------------------------------------------------

  static String normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Lower-cased words with a light plural stem ("shirts" → "shirt").
  static List<String> tokenize(String s) => normalize(
    s,
  ).split(' ').where((w) => w.isNotEmpty).map(_stem).toSet().toList();

  static String _stem(String w) {
    if (w.length > 4 && w.endsWith('es') && !w.endsWith('ses')) {
      return w.substring(0, w.length - 2);
    }
    if (w.length > 3 && w.endsWith('s') && !w.endsWith('ss')) {
      return w.substring(0, w.length - 1);
    }
    return w;
  }
}

class _Entry {
  _Entry(this.product)
    : name = ProductSearchIndex.normalize(product.name),
      nameTokens = ProductSearchIndex.tokenize(product.name),
      categoryTokens = ProductSearchIndex.tokenize(product.categoryName),
      descriptionTokens = ProductSearchIndex.tokenize(product.description);

  final ProductModel product;
  final String name;
  final List<String> nameTokens;
  final List<String> categoryTokens;
  final List<String> descriptionTokens;

  int scoreTerm(String term) {
    bool hit(List<String> tokens) => tokens.any((t) => t.startsWith(term));
    bool exact(List<String> tokens) => tokens.contains(term);
    if (exact(nameTokens)) return 12;
    if (hit(nameTokens)) return 8;
    if (exact(categoryTokens)) return 6;
    if (hit(categoryTokens)) return 4;
    if (hit(descriptionTokens)) return 1;
    return 0;
  }
}
