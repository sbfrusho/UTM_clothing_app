import '../../core/utils/json_parsing.dart';

enum PaymentMethod {
  card('Card'),
  cashOnDelivery('Cash on Delivery');

  const PaymentMethod(this.label);

  /// Stored value (shared with the admin app).
  final String label;
}

/// Fulfilment status, set by the admin app (customers may only cancel).
/// Stored as the capitalised label for compatibility.
enum OrderStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  shipped('Shipped'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const OrderStatus(this.label);
  final String label;

  static OrderStatus parse(String value) => values.firstWhere(
    (s) => s.label.toLowerCase() == value.trim().toLowerCase(),
    orElse: () => pending,
  );

  /// The happy path shown as a timeline.
  static const timeline = [pending, confirmed, shipped, delivered];
}

/// Stored `paymentStatus` values.
abstract final class PaymentStatusValue {
  /// Cash on delivery, collected by the courier.
  static const unpaid = 'unpaid';

  /// Card order created; stock reserved until paid or expired.
  static const awaitingPayment = 'awaiting_payment';
  static const paid = 'paid';
  static const refunded = 'refunded';

  /// Cancelled before payment or released after expiry.
  static const voided = 'void';
}

/// `paymentGateway` values.
abstract final class GatewayId {
  static const cod = 'cod';
  static const demo = 'demo';
  static const stripe = 'stripe';
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
    this.paymentGateway = '',
    this.deliveryType = '',
    this.sellerId = '',
    this.createdAt,
    this.statusHistory = const {},
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
  final String paymentGateway;
  final String deliveryType;
  final String sellerId;
  final DateTime? createdAt;

  /// When each status was reached (written by Cloud Functions; may be
  /// empty for older orders).
  final Map<OrderStatus, DateTime> statusHistory;
  final List<OrderItemModel> items;

  OrderStatus get orderStatus => OrderStatus.parse(status);
  bool get isCancelled => orderStatus == OrderStatus.cancelled;
  String get shortId => (id.length > 6 ? id.substring(0, 6) : id).toUpperCase();

  bool get isAwaitingPayment =>
      !isCancelled && paymentStatus == PaymentStatusValue.awaitingPayment;

  /// Customers may cancel until the shop confirms, unless real money was
  /// taken (a refund needs the shop or the server).
  bool get canCancel =>
      orderStatus == OrderStatus.pending &&
      (paymentStatus != PaymentStatusValue.paid ||
          paymentGateway == GatewayId.demo);

  /// Card orders are held this long before stock is released.
  static const paymentWindow = Duration(minutes: 30);

  DateTime? get paymentDeadline => createdAt?.add(paymentWindow);

  String get paymentSummary => switch (paymentStatus) {
    PaymentStatusValue.paid =>
      paymentGateway == GatewayId.demo ? 'Paid (test)' : 'Paid',
    PaymentStatusValue.awaitingPayment => 'Awaiting payment',
    PaymentStatusValue.refunded => 'Refunded',
    PaymentStatusValue.voided => 'Not charged',
    _ =>
      paymentMethod == PaymentMethod.cashOnDelivery.label
          ? 'Pay on delivery'
          : 'Unpaid',
  };

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
    paymentReference: map['paymentReference'] is String
        ? map['paymentReference'] as String
        : null,
    paymentGateway: asString(map['paymentGateway']),
    deliveryType: asString(map['deliveryType']),
    sellerId: asString(map['sellerId']),
    createdAt: asDateTime(map['createdAt']),
    statusHistory: _history(map['statusHistory']),
    items: items,
  );

  static Map<OrderStatus, DateTime> _history(Object? raw) {
    if (raw is! Map) return const {};
    final out = <OrderStatus, DateTime>{};
    raw.forEach((k, v) {
      final at = asDateTime(v);
      if (at != null) out[OrderStatus.parse('$k')] = at;
    });
    return out;
  }

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
    paymentGateway: paymentGateway,
    deliveryType: deliveryType,
    sellerId: sellerId,
    createdAt: createdAt,
    statusHistory: statusHistory,
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
    required this.paymentGateway,
    this.deviceToken,
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

  /// [GatewayId] that will take the money.
  final String paymentGateway;

  String get initialPaymentStatus => paymentMethod == PaymentMethod.card
      ? PaymentStatusValue.awaitingPayment
      : PaymentStatusValue.unpaid;

  double get total => items.fold(0, (sum, item) => sum + item.total);
}
