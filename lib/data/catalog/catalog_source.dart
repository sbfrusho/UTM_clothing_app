import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Where catalogue data comes from. Firestore today; a search service or a
/// fake in tests.
abstract interface class CatalogSource {
  /// Every product, up to [max].
  Future<List<ProductModel>> loadProducts({required int max});
  Future<ProductModel?> loadProduct(String id);
  Future<List<CategoryModel>> loadCategories();
  Future<List<String>> loadBannerUrls();
}

class FirestoreCatalogSource implements CatalogSource {
  FirestoreCatalogSource({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  static const _chunk = 200;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection(FirestorePaths.products);

  /// Reads in chunks ordered by document id (automatic index, no
  /// composite index needed).
  @override
  Future<List<ProductModel>> loadProducts({required int max}) async {
    try {
      final all = <ProductModel>[];
      DocumentSnapshot<Map<String, dynamic>>? cursor;
      while (all.length < max) {
        var query = _products.orderBy(FieldPath.documentId).limit(_chunk);
        if (cursor != null) query = query.startAfterDocument(cursor);
        final snapshot = await query.get();
        all.addAll(snapshot.docs.map(_toProduct));
        if (snapshot.docs.length < _chunk) break;
        cursor = snapshot.docs.last;
      }
      return all;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<ProductModel?> loadProduct(String id) async {
    try {
      final doc = await _products.doc(id).get();
      return doc.exists ? _toProduct(doc) : null;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<List<CategoryModel>> loadCategories() async {
    try {
      final snapshot = await _db.collection(FirestorePaths.categories).get();
      return snapshot.docs
          .map((d) => CategoryModel.fromMap(d.data(), id: d.id))
          .toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  @override
  Future<List<String>> loadBannerUrls() async {
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

  ProductModel _toProduct(DocumentSnapshot<Map<String, dynamic>> doc) =>
      ProductModel.fromMap(doc.data() ?? const {}, id: doc.id);
}
