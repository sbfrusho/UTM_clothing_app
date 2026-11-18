import '../../core/utils/json_parsing.dart';
import 'product_model.dart';

/// Entry in `wishlist/{email}.wishlist[]`. Keeps the legacy field names so
/// existing wishlists keep working.
class WishlistItemModel {
  const WishlistItemModel({
    required this.productId,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.salePrice,
    required this.fullPrice,
    required this.images,
    this.description = '',
    this.deliveryTime = '',
    this.isSale = false,
  });

  factory WishlistItemModel.fromProduct(ProductModel p) => WishlistItemModel(
    productId: p.id,
    categoryId: p.categoryId,
    categoryName: p.categoryName,
    name: p.name,
    salePrice: p.salePrice,
    fullPrice: p.fullPrice,
    images: p.images,
    description: p.description,
    deliveryTime: p.deliveryTime,
    isSale: p.isSale,
  );

  final String productId;
  final String categoryId;
  final String categoryName;
  final String name;
  final double salePrice;
  final double fullPrice;
  final List<String> images;
  final String description;
  final String deliveryTime;
  final bool isSale;

  String? get thumbnail => images.isEmpty ? null : images.first;
  double get price => salePrice > 0 ? salePrice : fullPrice;

  factory WishlistItemModel.fromMap(Map<String, dynamic> map) =>
      WishlistItemModel(
        productId: asString(map['productId']),
        categoryId: asString(map['categoryId']),
        categoryName: asString(map['categoryName']),
        name: asString(map['productName']),
        salePrice: asDouble(map['salePrice']),
        fullPrice: asDouble(map['fullPrice']),
        images: asStringList(map['productImages']),
        description: asString(map['productDescription']),
        deliveryTime: asString(map['deliveryTime']),
        isSale: asBool(map['isSale']),
      );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'productName': name,
    // Stored as strings for compatibility with the admin app.
    'salePrice': salePrice.toString(),
    'fullPrice': fullPrice.toString(),
    'productImages': images,
    'productDescription': description,
    'deliveryTime': deliveryTime,
    'isSale': isSale,
    'timeSlot': '',
  };
}
