import '../../core/utils/json_parsing.dart';
import 'product_model.dart';

/// A line in the cart, stored at `users/{uid}/cart/{key}`.
///
/// Identity is product + size: the same product in two sizes is two lines,
/// and adding it again raises the quantity. Name, image, price and stock are
/// a snapshot for instant/offline display; the cart refreshes them from the
/// live catalogue and checkout re-verifies them on the server.
class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.sellerEmail,
    required this.maxQuantity,
    this.size = '',
    this.quantity = 1,
    this.addedAt,
    this.isAvailable = true,
  });

  factory CartItemModel.fromProduct(
    ProductModel product, {
    String size = '',
    int quantity = 1,
    DateTime? addedAt,
  }) => CartItemModel(
    productId: product.id,
    name: product.name,
    imageUrl: product.thumbnail ?? '',
    unitPrice: product.price,
    sellerEmail: product.sellerEmail,
    maxQuantity: product.stock,
    size: size,
    quantity: quantity,
    addedAt: addedAt,
  );

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
    productId: asString(map['productId']),
    size: asString(map['size']),
    quantity: asInt(map['quantity'], fallback: 1).clamp(1, 999),
    name: asString(map['productName']),
    imageUrl: asString(map['productImage']),
    unitPrice: asDouble(map['price']),
    sellerEmail: asString(map['sellerEmail']),
    maxQuantity: asInt(map['stock']),
    addedAt: asDateTime(map['addedAt']),
  );

  final String productId;
  final String name;
  final String imageUrl;
  final double unitPrice;
  final String sellerEmail;

  /// Units available (live stock after a catalogue refresh).
  final int maxQuantity;
  final String size;
  final int quantity;
  final DateTime? addedAt;

  /// False when the product was removed or sold out. Not stored.
  final bool isAvailable;

  String get key => keyFor(productId, size);
  double get total => unitPrice * quantity;

  /// Firestore-safe document id ("/" and similar are escaped).
  static String keyFor(String productId, String size) =>
      '${productId}__${Uri.encodeComponent(size)}';

  /// Snapshot written to Firestore. `addedAt` is set by the repository.
  Map<String, dynamic> toMap() => {
    'productId': productId,
    'size': size,
    'quantity': quantity,
    'productName': name,
    'productImage': imageUrl,
    'price': unitPrice,
    'sellerEmail': sellerEmail,
    'stock': maxQuantity,
  };

  CartItemModel copyWith({
    int? quantity,
    String? name,
    String? imageUrl,
    double? unitPrice,
    String? sellerEmail,
    int? maxQuantity,
    bool? isAvailable,
  }) => CartItemModel(
    productId: productId,
    size: size,
    addedAt: addedAt,
    quantity: quantity ?? this.quantity,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    unitPrice: unitPrice ?? this.unitPrice,
    sellerEmail: sellerEmail ?? this.sellerEmail,
    maxQuantity: maxQuantity ?? this.maxQuantity,
    isAvailable: isAvailable ?? this.isAvailable,
  );

  /// Whether the stored snapshot differs from [other] (worth a write).
  bool storedDiffers(CartItemModel other) =>
      quantity != other.quantity ||
      name != other.name ||
      imageUrl != other.imageUrl ||
      (unitPrice - other.unitPrice).abs() > 0.005 ||
      sellerEmail != other.sellerEmail ||
      maxQuantity != other.maxQuantity;
}
