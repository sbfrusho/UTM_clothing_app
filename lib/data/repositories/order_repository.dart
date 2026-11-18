import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_paths.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/json_parsing.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class OrderRepository {
  OrderRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

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
  Future<String> placeOrder(OrderDraft draft, List<CartItemModel> cart) async {
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
          'paymentStatus': draft.paymentMethod == PaymentMethod.card
              ? 'paid'
              : 'unpaid',
          'paymentReference': draft.paymentReference,
          'deliveryTime': draft.deliveryDate,
          'deliveryType': draft.deliveryType,
          'totalPrice': draft.total,
          'status': 'Pending',
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

  /// Newest first. Sorted on the client so no composite index is needed;
  /// pagination + index arrive with Sprint 8's `firestore.indexes.json`.
  Future<List<OrderModel>> fetchForCustomer(String uid) async {
    try {
      final snapshot = await _orders.where('customerId', isEqualTo: uid).get();
      final orders =
          snapshot.docs
              .map((d) => OrderModel.fromMap(d.data(), id: d.id))
              .toList()
            ..sort(
              (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
                a.createdAt ?? DateTime(0),
              ),
            );
      return orders;
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<OrderModel?> fetchOrder(String id) async {
    try {
      final doc = await _orders.doc(id).get();
      final data = doc.data();
      if (data == null) return null;
      final items = await doc.reference
          .collection(FirestorePaths.orderItems)
          .get();
      return OrderModel.fromMap(
        data,
        id: doc.id,
        items: items.docs.map((d) => OrderItemModel.fromMap(d.data())).toList(),
      );
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
