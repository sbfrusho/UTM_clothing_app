import '../../core/utils/json_parsing.dart';

enum PaymentMethod {
  card('Card'),
  cashOnDelivery('Cash on Delivery');

  const PaymentMethod(this.label);

  /// Stored value (shared with the admin app).
  final String label;
}

class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.size = '',
    this.imageUrl = '',
  });

  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final String size;
  final String imageUrl;

  double get total => unitPrice * quantity;

  factory OrderItemModel.fromMap(Map<String, dynamic> map) => OrderItemModel(
    productId: asString(map['product_id']),
    name: asString(map['product_name']),
    unitPrice: asDouble(map['price']),
    quantity: asInt(map['quantity'], fallback: 1),
    size: asString(map['size']),
    imageUrl: asString(map['product_image']),
  );

  Map<String, dynamic> toMap() => {
    'product_id': productId,
    'product_name': name,
    // Stored as string for compatibility with the admin app.
    'price': unitPrice.toString(),
    'quantity': quantity,
    'size': size,
    'product_image': imageUrl,
  };
}

/// `orders/{id}` with line items in the `items` sub-collection.
class OrderModel {
  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerEmail,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.paymentMethod,
    required this.deliveryDate,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    this.paymentReference,
    this.sellerId = '',
    this.createdAt,
    this.items = const [],
  });

  final String id;
  final String customerId;
  final String customerEmail;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String paymentMethod;
  final String deliveryDate;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final String? paymentReference;
  final String sellerId;
  final DateTime? createdAt;
  final List<OrderItemModel> items;

  factory OrderModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
    List<OrderItemModel> items = const [],
  }) => OrderModel(
    id: id,
    customerId: asString(map['customerId']),
    customerEmail: asString(map['uniqueId']),
    customerName: asString(map['customerName']),
    customerPhone: asString(map['customerPhone']),
    customerAddress: asString(map['customerAddress']),
    paymentMethod: asString(map['paymentMethod']),
    deliveryDate: asString(map['deliveryTime']),
    totalPrice: asDouble(map['totalPrice']),
    status: asString(map['status'], fallback: 'Pending'),
    paymentStatus: asString(map['paymentStatus'], fallback: 'unpaid'),
    paymentReference: map['paymentReference'] as String?,
    sellerId: asString(map['sellerId']),
    createdAt: asDateTime(map['createdAt']),
    items: items,
  );

  OrderModel withItems(List<OrderItemModel> items) => OrderModel(
    id: id,
    customerId: customerId,
    customerEmail: customerEmail,
    customerName: customerName,
    customerPhone: customerPhone,
    customerAddress: customerAddress,
    paymentMethod: paymentMethod,
    deliveryDate: deliveryDate,
    totalPrice: totalPrice,
    status: status,
    paymentStatus: paymentStatus,
    paymentReference: paymentReference,
    sellerId: sellerId,
    createdAt: createdAt,
    items: items,
  );
}

/// Everything checkout collects before the order is written.
class OrderDraft {
  const OrderDraft({
    required this.customerId,
    required this.customerEmail,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.deliveryDate,
    required this.deliveryType,
    required this.paymentMethod,
    required this.items,
    required this.sellerIds,
    this.deviceToken,
    this.paymentReference,
  });

  final String customerId;
  final String customerEmail;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String deliveryDate;
  final String deliveryType;
  final PaymentMethod paymentMethod;
  final List<OrderItemModel> items;
  final List<String> sellerIds;
  final String? deviceToken;
  final String? paymentReference;

  double get total => items.fold(0, (sum, item) => sum + item.total);
}
