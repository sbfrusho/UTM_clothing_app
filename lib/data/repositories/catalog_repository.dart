import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// One page of products plus the cursor for the next page.
class ProductPage {
  const ProductPage(this.items, this.cursor, {required this.hasMore});

  final List<ProductModel> items;
  final DocumentSnapshot<Map<String, dynamic>>? cursor;
  final bool hasMore;
}

/// Categories, banners and products (all read-only for customers).
class CatalogRepository {
  CatalogRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  static const pageSize = 20;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection(FirestorePaths.products);

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final snapshot = await _db.collection(FirestorePaths.categories).get();
      return snapshot.docs
          .map((d) => CategoryModel.fromMap(d.data(), id: d.id))
          .toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<List<String>> fetchBannerUrls() async {
    try {
      final snapshot = await _db.collection(FirestorePaths.banners).get();
      return snapshot.docs
          .map((d) => d.data()['imageUrl'])
          .whereType<String>()
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Cursor-paginated products of a category. Ordered by document id, which
  /// works with Firestore's automatic single-field index.
  Future<ProductPage> fetchByCategory(
    String categoryId, {
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit = pageSize,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _products
          .where('categoryId', isEqualTo: categoryId)
          .orderBy(FieldPath.documentId)
          .limit(limit);
      if (startAfter != null) query = query.startAfterDocument(startAfter);
      final snapshot = await query.get();
      return ProductPage(
        snapshot.docs.map(_toProduct).toList(),
        snapshot.docs.isEmpty ? startAfter : snapshot.docs.last,
        hasMore: snapshot.docs.length == limit,
      );
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<List<ProductModel>> fetchLatest({int limit = 10}) async {
    try {
      final snapshot = await _products
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map(_toProduct).toList();
      }
      final fallback = await _products.limit(limit).get();
      return fallback.docs.map(_toProduct).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<ProductModel?> fetchProduct(String id) async {
    try {
      final doc = await _products.doc(id).get();
      return doc.exists ? _toProduct(doc) : null;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Case-insensitive name search.
  ///
  /// Firestore has no substring search, so this scans a bounded window of
  /// products. Sprint 5 replaces it with an indexed `searchKeywords` field
  /// (or Algolia/Typesense) without changing this method's signature.
  Future<List<ProductModel>> search(String query, {int scanLimit = 300}) async {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];
    try {
      final snapshot = await _products.limit(scanLimit).get();
      return snapshot.docs
          .map(_toProduct)
          .where((p) => p.name.toLowerCase().contains(needle))
          .toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  ProductModel _toProduct(DocumentSnapshot<Map<String, dynamic>> doc) =>
      ProductModel.fromMap(doc.data() ?? const {}, id: doc.id);
}
