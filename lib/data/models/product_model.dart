import '../../core/utils/json_parsing.dart';

/// A product as written by the admin app to `products/{productId}`.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.salePrice,
    required this.fullPrice,
    required this.images,
    required this.sizes,
    required this.stock,
    required this.isSale,
    required this.deliveryTime,
    required this.sellerEmail,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final double salePrice;
  final double fullPrice;
  final List<String> images;
  final List<String> sizes;
  final int stock;
  final bool isSale;
  final String deliveryTime;
  final String sellerEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String? get thumbnail => images.isEmpty ? null : images.first;
  bool get inStock => stock > 0;
  bool get requiresSize => sizes.isNotEmpty;

  /// Price the customer pays.
  double get price => salePrice > 0 ? salePrice : fullPrice;
  bool get hasDiscount => fullPrice > price && price > 0;

  /// Flagged as a sale by the admin, or simply priced below full price.
  bool get isOnSale => isSale || hasDiscount;
  int get discountPercent =>
      hasDiscount ? ((fullPrice - price) / fullPrice * 100).round() : 0;

  factory ProductModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ProductModel(
      id: asString(map['productId'], fallback: id ?? ''),
      categoryId: asString(map['categoryId']),
      categoryName: asString(map['categoryName']),
      name: asString(map['productName']),
      description: asString(map['productDescription']),
      salePrice: asDouble(map['salePrice']),
      fullPrice: asDouble(map['fullPrice']),
      images: asStringList(map['productImages']),
      sizes: asStringList(map['productSizes']),
      stock: asInt(map['quantity']),
      isSale: asBool(map['isSale']),
      deliveryTime: asString(map['deliveryTime']),
      sellerEmail: asString(map['email']),
      createdAt: asDateTime(map['createdAt']),
      updatedAt: asDateTime(map['updatedAt']),
    );
  }
}
