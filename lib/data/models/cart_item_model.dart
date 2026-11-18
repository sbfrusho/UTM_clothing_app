import 'product_model.dart';

/// A line in the cart. Identity is product + size, so the same product in
/// two sizes is two lines and adding again increases quantity.
class CartItemModel {
  CartItemModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.sellerEmail,
    required this.maxQuantity,
    this.size = '',
    this.quantity = 1,
  });

  factory CartItemModel.fromProduct(
    ProductModel product, {
    String size = '',
    int quantity = 1,
  }) => CartItemModel(
    productId: product.id,
    name: product.name,
    imageUrl: product.thumbnail ?? '',
    unitPrice: product.price,
    sellerEmail: product.sellerEmail,
    maxQuantity: product.stock,
    size: size,
    quantity: quantity,
  );

  final String productId;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final String sellerEmail;

  /// Stock when added; the order transaction re-checks the live value.
  final int maxQuantity;
  final String size;
  int quantity;

  String get key => keyFor(productId, size);
  double get total => unitPrice * quantity;

  static String keyFor(String productId, String size) => '$productId|$size';
}
