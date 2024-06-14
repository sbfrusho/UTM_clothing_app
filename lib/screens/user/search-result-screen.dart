// search_results_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/screens/user/product-detailscreen.dart';

import '../../models/product-model.dart';


class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({Key? key, required this.query}) : super(key: key);

  Future<List<ProductModel>> fetchSearchResults(String query) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('products') // Replace with your collection name
        .where('productName', isGreaterThanOrEqualTo: query)
        .where('productName', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "$query"'),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: fetchSearchResults(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No results found for "$query"'));
          } else {
            final searchResults = snapshot.data!;
            return ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final product = searchResults[index];
                return ListTile(
                  leading: Image.network(product.productImages[0]), // Display the first product image
                  title: Text(product.productName),
                  subtitle: Text(product.salePrice),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productModel: product)));
                  },
                );
              },
            );
          }
        },
      ),
      
    );
  }
}
