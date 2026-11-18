import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../../core/services/functions_client.dart';
import '../../core/utils/json_parsing.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

/// Orders. With the backend configured (`FUNCTIONS_BASE_URL`), creating
/// and cancelling go through Cloud Functions, as `firestore.rules` requires;
/// otherwise (local development before deploying) the same steps run as
/// client transactions.
class OrderRepository {
  OrderRepository({FirebaseFirestore? firestore, FunctionsClient? functions})
    : _db = firestore ?? FirebaseFirestore.instance,
      _functions = functions ?? FunctionsClient();

  final FirebaseFirestore _db;
  final FunctionsClient _functions;

  bool get usesServer => _functions.isConfigured;

  /// The server can refund Stripe payments, so with it customers may cancel
  /// any pending order; without it, only orders with no real money taken.
  bool canCancel(OrderModel order) =>
      usesServer ? order.orderStatus == OrderStatus.pending : order.canCancel;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection(FirestorePaths.orders);
  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection(FirestorePaths.products);

  /// Read-only pre-check run **before** taking payment: every product still
  /// exists, has enough stock and still costs what the cart says.
  Future<void> verifyCart(List<CartItemModel> items) async {
    try {
      final needed = _quantitiesByProduct(items);
      for (final entry in needed.entries) {
        final doc = await _products.doc(entry.key).get();
        _checkProduct(doc, entry.value, items);
      }
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Atomically checks and decrements stock, writes the order with its
  /// items and removes the purchased lines from the customer's cart.
  /// Either everything is written or nothing is.
  ///
  /// Card orders are created **before** payment with
  /// `paymentStatus: awaiting_payment`: stock is reserved, the server
  /// charges exactly the stored total, and nobody can pay for an order that
  /// failed to be created.
  Future<String> placeOrder(OrderDraft draft, List<CartItemModel> cart) async {
    if (usesServer) return _placeOnServer(draft, cart);
    try {
      return await _db.runTransaction((tx) async {
        final needed = _quantitiesByProduct(cart);

        // 1. Reads (a transaction must read before it writes).
        final snapshots = <String, DocumentSnapshot<Map<String, dynamic>>>{};
        for (final id in needed.keys) {
          snapshots[id] = await tx.get(_products.doc(id));
        }

        // 2. Validate and decrement stock (stored as string by admin app).
        for (final entry in needed.entries) {
          final doc = snapshots[entry.key]!;
          final stock = _checkProduct(doc, entry.value, cart);
          tx.update(doc.reference, {'quantity': '${stock - entry.value}'});
        }

        // 3. Order document + items (legacy field names kept for admin app).
        final orderRef = _orders.doc();
        tx.set(orderRef, {
          'customerId': draft.customerId,
          'uniqueId': draft.customerEmail,
          'customerName': draft.customerName,
          'customerPhone': draft.customerPhone,
          'customerAddress': draft.customerAddress,
          'customerDeviceToken': draft.deviceToken ?? '',
          'paymentMethod': draft.paymentMethod.label,
          'paymentStatus': draft.initialPaymentStatus,
          'paymentGateway': draft.paymentGateway,
          'paymentReference': null,
          'deliveryTime': draft.deliveryDate,
          'deliveryType': draft.deliveryType,
          'totalPrice': draft.total,
          'status': OrderStatus.pending.label,
          'statusHistory': {
            OrderStatus.pending.label: FieldValue.serverTimestamp(),
          },
          'sellerId': draft.sellerIds.isEmpty ? '' : draft.sellerIds.first,
          'sellerIds': draft.sellerIds,
          'createdAt': FieldValue.serverTimestamp(),
        });
        for (final item in draft.items) {
          tx.set(
            orderRef.collection(FirestorePaths.orderItems).doc(),
            item.toMap(),
          );
        }
        // 4. Empty the purchased cart lines in the same commit, so a
        //    retry can never order the same cart twice.
        final cartRef = _db
            .collection(FirestorePaths.users)
            .doc(draft.customerId)
            .collection(FirestorePaths.userCart);
        for (final line in cart) {
          tx.delete(cartRef.doc(line.key));
        }
        return orderRef.id;
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<String> _placeOnServer(
    OrderDraft draft,
    List<CartItemModel> cart,
  ) async {
    final result = await _functions.call('placeOrder', {
      'items': [
        for (final l in cart)
          {'productId': l.productId, 'size': l.size, 'quantity': l.quantity},
      ],
      'address': {
        'fullName': draft.customerName,
        'phone': draft.customerPhone,
        'formatted': draft.customerAddress,
      },
      'deliveryDate': draft.deliveryDate,
      'deliveryType': draft.deliveryType,
      'paymentMethod': draft.paymentMethod == PaymentMethod.card
          ? 'card'
          : 'cod',
      'expectedTotal': draft.total,
    });
    return result['orderId'] as String;
  }

  /// Live list, newest first. Sorted on the client so no composite index
  /// is needed (Sprint 8 adds indexes and pagination).
  Stream<List<OrderModel>> watchForCustomer(String uid) => _orders
      .where('customerId', isEqualTo: uid)
      .snapshots()
      .map(
        (s) =>
            s.docs.map((d) => OrderModel.fromMap(d.data(), id: d.id)).toList()
              ..sort(
                (a, b) => (b.createdAt ?? DateTime(9999)).compareTo(
                  a.createdAt ?? DateTime(9999),
                ),
              ),
      )
      .handleError((Object e) => throw AppException.from(e));

  /// Live order with its (immutable) items.
  Stream<OrderModel?> watchOrder(String id) async* {
    final items = await _items(id);
    yield* _orders
        .doc(id)
        .snapshots()
        .map((doc) {
          final data = doc.data();
          return data == null
              ? null
              : OrderModel.fromMap(data, id: doc.id, items: items);
        })
        .handleError((Object e) => throw AppException.from(e));
  }

  Future<List<OrderItemModel>> _items(String orderId) async {
    try {
      final s = await _orders
          .doc(orderId)
          .collection(FirestorePaths.orderItems)
          .get();
      return s.docs.map((d) => OrderItemModel.fromMap(d.data())).toList();
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<OrderModel?> fetchOrder(String id) async {
    try {
      final doc = await _orders.doc(id).get();
      final data = doc.data();
      if (data == null) return null;
      return OrderModel.fromMap(data, id: doc.id, items: await _items(id));
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Settles a **test** payment. Real (Stripe) payments are settled only
  /// by the server webhook.
  Future<void> markTestPaid(String orderId, String reference) async {
    try {
      await _db.runTransaction((tx) async {
        final ref = _orders.doc(orderId);
        final order = await tx.get(ref);
        final data = order.data();
        if (data == null ||
            data['paymentGateway'] != GatewayId.demo ||
            data['paymentStatus'] != PaymentStatusValue.awaitingPayment) {
          throw const AppException('This order can no longer be paid.');
        }
        tx.update(ref, {
          'paymentStatus': PaymentStatusValue.paid,
          'paymentReference': reference,
          'paidAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Cancels a pending order and puts its stock back, atomically.
  ///
  /// Allowed for the owner while the order is still pending and no real
  /// money was taken ([OrderModel.canCancel]). Sprint 8 moves this into a
  /// Cloud Function once security rules stop clients writing stock.
  /// Returns whether a payment was refunded.
  Future<bool> cancel(String orderId, {required String uid}) async {
    if (usesServer) {
      final r = await _functions.call('cancelOrder', {'orderId': orderId});
      return r['refunded'] == true;
    }
    var refunded = false;
    try {
      final items = await _items(orderId);
      final needed = <String, int>{};
      for (final i in items) {
        needed.update(
          i.productId,
          (q) => q + i.quantity,
          ifAbsent: () => i.quantity,
        );
      }
      await _db.runTransaction((tx) async {
        final ref = _orders.doc(orderId);
        final snap = await tx.get(ref);
        final data = snap.data();
        if (data == null) throw const AppException('Order not found.');
        final order = OrderModel.fromMap(data, id: orderId);
        if (order.customerId != uid) {
          throw const AppException('You can only cancel your own orders.');
        }
        if (!order.canCancel) {
          throw const AppException(
            'This order can no longer be cancelled. Please contact us.',
          );
        }
        final products = {
          for (final id in needed.keys) id: await tx.get(_products.doc(id)),
        };
        for (final MapEntry(key: id, value: qty) in needed.entries) {
          final p = products[id]!;
          if (!p.exists) continue; // removed product: nothing to restock
          final stock = asInt(p.data()?['quantity']);
          tx.update(p.reference, {'quantity': '${stock + qty}'});
        }
        refunded = order.paymentStatus == PaymentStatusValue.paid;
        tx.update(ref, {
          'status': OrderStatus.cancelled.label,
          'statusHistory.${OrderStatus.cancelled.label}':
              FieldValue.serverTimestamp(),
          'cancelledBy': 'customer',
          'paymentStatus': order.paymentStatus == PaymentStatusValue.paid
              ? PaymentStatusValue
                    .refunded // test payments only
              : PaymentStatusValue.voided,
        });
      });
      return refunded;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Sizes share one stock counter, so quantities are summed per product.
  static Map<String, int> _quantitiesByProduct(List<CartItemModel> items) {
    final result = <String, int>{};
    for (final item in items) {
      result.update(
        item.productId,
        (q) => q + item.quantity,
        ifAbsent: () => item.quantity,
      );
    }
    return result;
  }

  /// Returns current stock, or throws a user-facing [AppException].
  static int _checkProduct(
    DocumentSnapshot<Map<String, dynamic>> doc,
    int needed,
    List<CartItemModel> cart,
  ) {
    final line = cart.firstWhere((i) => i.productId == doc.id);
    final data = doc.data();
    if (data == null) {
      throw AppException('"${line.name}" is no longer available.');
    }
    final stock = asInt(data['quantity']);
    if (stock < needed) {
      throw AppException(
        stock == 0
            ? '"${line.name}" is out of stock.'
            : 'Only $stock of "${line.name}" left in stock.',
      );
    }
    final sale = asDouble(data['salePrice']);
    final livePrice = sale > 0 ? sale : asDouble(data['fullPrice']);
    if ((livePrice - line.unitPrice).abs() > 0.005) {
      throw AppException(
        'The price of "${line.name}" has changed. Please review your cart.',
      );
    }
    return stock;
  }
}
