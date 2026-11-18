import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:your_shop/models/product-model.dart';
import 'package:your_shop/core/utils/app_logger.dart';

class SearchControllerAll extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<ProductModel> searchResults = <ProductModel>[].obs;

  void searchProducts(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      final result = await _firestore.collection('products').get();
      List<ProductModel> products = result.docs.map((doc) {
        return ProductModel.fromMap(doc.data());
      }).toList();

      searchResults.value = products.where((product) {
        return product.productName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      AppLogger.debug("Error fetching products: $e");
      searchResults.clear(); // Clear search results on error
    }
  }
}
