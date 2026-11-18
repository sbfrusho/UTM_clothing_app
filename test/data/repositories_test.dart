import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_shop/core/errors/app_exception.dart';
import 'package:your_shop/core/services/functions_client.dart';
import 'package:your_shop/data/models/address_model.dart';
import 'package:your_shop/data/models/cart_item_model.dart';
import 'package:your_shop/data/models/order_model.dart';
import 'package:your_shop/data/models/product_model.dart';
import 'package:your_shop/data/models/user_model.dart';
import 'package:your_shop/data/models/wishlist_item_model.dart';
import 'package:your_shop/data/repositories/address_repository.dart';
import 'package:your_shop/data/repositories/cart_repository.dart';
import 'package:your_shop/data/repositories/order_repository.dart';
import 'package:your_shop/data/repositories/user_repository.dart';
import 'package:your_shop/data/repositories/wishlist_repository.dart';

class _MockFunctions extends Mock implements FunctionsClient {}

class _Offline extends Mock implements FunctionsClient {
  @override
  bool get isConfigured => false;
}

const uid = 'alice';

CartItemModel line(
  String id, {
  int qty = 1,
  double price = 10,
  String size = '',
}) => CartItemModel(
  productId: id,
  name: 'P$id',
  imageUrl: '',
  unitPrice: price,
  sellerEmail: '',
  maxQuantity: 9,
  size: size,
  quantity: qty,
);

OrderDraft draft(List<CartItemModel> cart, {PaymentMethod? method}) =>
    OrderDraft(
      customerId: uid,
      customerEmail: 'alice@example.com',
      customerName: 'Alice',
      customerPhone: '0123456789',
      customerAddress: '1 Jalan, Johor Bahru',
      deliveryDate: '2026-12-01',
      deliveryType: 'Standard',
      paymentMethod: method ?? PaymentMethod.cashOnDelivery,
      paymentGateway: 'cod',
      sellerIds: const [],
      items: [
        for (final l in cart)
          OrderItemModel(
            productId: l.productId,
            name: l.name,
            unitPrice: l.unitPrice,
            quantity: l.quantity,
            size: l.size,
          ),
      ],
    );

AddressModel address(String label, {bool isDefault = false, String? id}) =>
    AddressModel(
      id: id,
      label: label,
      fullName: 'Alice',
      phone: '0123456789',
      address: '1',
      city: 'JB',
      postalCode: '81300',
      country: 'Malaysia',
      isDefault: isDefault,
    );

void main() {
  late FakeFirebaseFirestore db;

  setUp(() async {
    db = FakeFirebaseFirestore();
    await db.doc('products/a').set({
      'productName': 'Pa',
      'salePrice': '10',
      'quantity': '3',
    });
    await db.doc('products/b').set({
      'productName': 'Pb',
      'salePrice': '25',
      'quantity': '1',
    });
  });

  Future<int> stock(String id) async =>
      int.parse((await db.doc('products/$id').get()).get('quantity') as String);

  group('OrderRepository (client transaction)', () {
    late OrderRepository repo;
    setUp(() => repo = OrderRepository(firestore: db, functions: _Offline()));

    test(
      'places the order: stock reserved, items written, cart emptied',
      () async {
        final cart = [
          line('a', qty: 1, size: 'S'),
          line('a', qty: 1, size: 'M'),
          line('b', price: 25),
        ];
        for (final l in cart) {
          await db.doc('users/$uid/cart/${l.key}').set(l.toMap());
        }
        final id = await repo.placeOrder(draft(cart), cart);

        expect(await stock('a'), 1);
        expect(await stock('b'), 0);
        final order = await repo.fetchOrder(id);
        expect(order!.customerId, uid);
        expect(order.items, hasLength(3));
        expect(order.orderStatus, OrderStatus.pending);
        expect((await db.collection('users/$uid/cart').get()).docs, isEmpty);
      },
    );

    test('card orders start awaiting payment', () async {
      final cart = [line('a')];
      final id = await repo.placeOrder(
        draft(cart, method: PaymentMethod.card),
        cart,
      );
      expect(
        (await db.doc('orders/$id').get()).get('paymentStatus'),
        PaymentStatusValue.awaitingPayment,
      );
    });

    test('refuses without writing anything when stock is short', () async {
      final cart = [line('a'), line('b', qty: 2, price: 25)];
      await expectLater(
        repo.placeOrder(draft(cart), cart),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('Only 1'),
          ),
        ),
      );
      expect(await stock('a'), 3);
      expect((await db.collection('orders').get()).docs, isEmpty);
    });

    test('refuses when the price changed or the product is gone', () async {
      await expectLater(
        repo.verifyCart([line('a', price: 9)]),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        repo.verifyCart([line('zzz')]),
        throwsA(isA<AppException>()),
      );
      await repo.verifyCart([line('a', qty: 3)]);
    });

    test(
      'cancel restocks and voids an unpaid order; only the owner may',
      () async {
        final cart = [line('a', qty: 2)];
        final id = await repo.placeOrder(draft(cart), cart);
        expect(await stock('a'), 1);

        await expectLater(
          repo.cancel(id, uid: 'bob'),
          throwsA(isA<AppException>()),
        );
        expect(await repo.cancel(id, uid: uid), isFalse);
        expect(await stock('a'), 3);
        final doc = await db.doc('orders/$id').get();
        expect(doc.get('status'), OrderStatus.cancelled.label);
        expect(doc.get('paymentStatus'), PaymentStatusValue.voided);
        await expectLater(
          repo.cancel(id, uid: uid),
          throwsA(isA<AppException>()),
        );
      },
    );

    test('test payments are settled once, only for demo orders', () async {
      final cart = [line('a')];
      final order = OrderDraft(
        customerId: uid,
        customerEmail: '',
        customerName: '',
        customerPhone: '',
        customerAddress: '',
        deliveryDate: '',
        deliveryType: '',
        paymentMethod: PaymentMethod.card,
        paymentGateway: GatewayId.demo,
        sellerIds: const [],
        items: draft(cart).items,
      );
      final id = await repo.placeOrder(order, cart);
      await repo.markTestPaid(id, 'ref1');
      expect(
        (await db.doc('orders/$id').get()).get('paymentStatus'),
        PaymentStatusValue.paid,
      );
      await expectLater(
        repo.markTestPaid(id, 'ref2'),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('OrderRepository (server)', () {
    test('sends cart lines and the expected total to placeOrder', () async {
      final functions = _MockFunctions();
      when(() => functions.isConfigured).thenReturn(true);
      when(
        () => functions.call(any(), any()),
      ).thenAnswer((_) async => {'orderId': 'o9'});
      final repo = OrderRepository(firestore: db, functions: functions);
      final cart = [line('a', qty: 2, size: 'M')];

      expect(await repo.placeOrder(draft(cart), cart), 'o9');
      final body =
          verify(
                () => functions.call('placeOrder', captureAny()),
              ).captured.single
              as Map<String, Object?>;
      expect(body['expectedTotal'], 20);
      expect(body['paymentMethod'], 'cod');
      expect(body['items'], [
        {'productId': 'a', 'size': 'M', 'quantity': 2},
      ]);
      // Nothing written by the client.
      expect(await stock('a'), 3);
    });
  });

  group('CartRepository and WishlistRepository', () {
    test('cart save, watch, remove and clear', () async {
      final repo = CartRepository(firestore: db);
      await repo.save(uid, line('a', size: 'S'), isNew: true);
      await repo.save(uid, line('b'), isNew: true);
      expect(
        (await repo.watch(uid).first).map((l) => l.key),
        containsAll(['a__S', 'b__']),
      );
      await repo.remove(uid, 'a__S');
      expect(await repo.watch(uid).first, hasLength(1));
      await repo.clear(uid);
      expect(await repo.watch(uid).first, isEmpty);
    });

    test('wishlist migrates the legacy array once', () async {
      final legacy = WishlistItemModel.fromProduct(
        ProductModel.fromMap({
          'productId': 'a',
          'productName': 'Pa',
          'salePrice': '10',
        }),
      );
      await db.doc('wishlist/alice@example.com').set({
        'wishlist': [legacy.toMap()],
      });
      final repo = WishlistRepository(firestore: db);

      await repo.migrateLegacy(uid: uid, email: 'alice@example.com');
      expect((await repo.watch(uid).first).single.productId, 'a');
      await repo.remove(uid, 'a');
      await repo.migrateLegacy(uid: uid, email: 'alice@example.com');
      expect(
        await repo.watch(uid).first,
        isEmpty,
        reason: 'flag stops a second run',
      );
    });
  });

  group('AddressRepository', () {
    test(
      'first address is default; a new default replaces the old one',
      () async {
        final repo = AddressRepository(firestore: db);
        final home = await repo.save(uid, address('Home'));
        expect(home.isDefault, isTrue);
        final work = await repo.save(uid, address('Work', isDefault: true));
        final book = await repo.fetchAll(uid);
        expect(book.where((a) => a.isDefault).single.id, work.id);
        expect(book.first.id, work.id, reason: 'default sorts first');
      },
    );

    test('deleting the default promotes another', () async {
      final repo = AddressRepository(firestore: db);
      final home = await repo.save(uid, address('Home'));
      await repo.save(uid, address('Work'));
      await repo.delete(uid, home);
      final book = await repo.fetchAll(uid);
      expect(book.single.label, 'Work');
      expect(book.single.isDefault, isTrue);
    });
  });

  group('UserRepository', () {
    test(
      'profile updates keep role fields; device tokens add and remove',
      () async {
        final repo = UserRepository(firestore: db);
        await db
            .doc('users/$uid')
            .set(const UserModel(uid: uid, email: 'a@x.com').toMap());
        final user = (await repo.fetch(uid))!;
        await repo.updateProfile(user.copyWith(name: 'Alice'));
        expect((await repo.fetch(uid))!.name, 'Alice');

        await repo.addDeviceToken(uid, 't1');
        await repo.addDeviceToken(uid, 't2');
        await repo.removeDeviceToken(uid, 't2');
        final doc = await db.doc('users/$uid').get();
        expect(doc.get('fcmTokens'), ['t1']);
        expect(doc.get('deviceToken'), '');
      },
    );

    test('deleteUserData removes the profile and its subcollections', () async {
      await db.doc('users/$uid').set({'name': 'A'});
      await db.doc('users/$uid/cart/a__').set(line('a').toMap());
      await db.doc('users/$uid/wishlist/a').set({'productId': 'a'});
      await db.doc('users/$uid/addresses/x').set({'city': 'JB'});
      await db.doc('users/bob/cart/a__').set(line('a').toMap());

      await UserRepository(firestore: db).deleteUserData(uid);
      expect((await db.doc('users/$uid').get()).exists, isFalse);
      for (final sub in ['cart', 'wishlist', 'addresses']) {
        expect((await db.collection('users/$uid/$sub').get()).docs, isEmpty);
      }
      expect((await db.collection('users/bob/cart').get()).docs, hasLength(1));
    });
  });
}
