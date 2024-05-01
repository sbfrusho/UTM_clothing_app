class CartItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      productName: json['productName'],
      productImage: json['productImage'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
    };
  }
}
