import 'package:flutter_test/flutter_test.dart';
import 'package:your_shop/data/models/order_model.dart';
import 'package:your_shop/data/models/product_model.dart';
import 'package:your_shop/data/models/user_model.dart';
import 'package:your_shop/data/models/wishlist_item_model.dart';

void main() {
  group('ProductModel.fromMap', () {
    test('parses the admin app string fields into numbers', () {
      final p = ProductModel.fromMap({
        'productId': 'p1',
        'productName': 'UTM Tee',
        'salePrice': '25.50',
        'fullPrice': '30',
        'quantity': '7',
        'productImages': ['a.jpg', 'b.jpg'],
        'productSizes': ['S', 'M'],
        'email': 'seller@shop.com',
      });

      expect(p.id, 'p1');
      expect(p.salePrice, 25.5);
      expect(p.fullPrice, 30);
      expect(p.stock, 7);
      expect(p.thumbnail, 'a.jpg');
      expect(p.requiresSize, isTrue);
      expect(p.sellerEmail, 'seller@shop.com');
    });

    test('also accepts numeric fields and missing values', () {
      final p = ProductModel.fromMap({
        'salePrice': 10,
        'quantity': 3.0,
      }, id: 'doc');

      expect(p.id, 'doc');
      expect(p.salePrice, 10);
      expect(p.stock, 3);
      expect(p.images, isEmpty);
      expect(p.thumbnail, isNull);
      expect(p.inStock, isTrue);
    });

    test('falls back to full price when there is no sale price', () {
      final p = ProductModel.fromMap({'salePrice': '', 'fullPrice': '40'});

      expect(p.price, 40);
      expect(p.hasDiscount, isFalse);
    });

    test('computes the discount percentage', () {
      final p = ProductModel.fromMap({'salePrice': '75', 'fullPrice': '100'});

      expect(p.hasDiscount, isTrue);
      expect(p.discountPercent, 25);
    });
  });

  group('UserModel', () {
    test(
      'round-trips the legacy "adress" field and never writes a password',
      () {
        final user = UserModel.fromMap({
          'uId': 'u1',
          'email': 'a@b.c',
          'adress': 'Jalan 1',
          'password': 'x',
        });
        final map = user.toMap();

        expect(user.address, 'Jalan 1');
        expect(map['adress'], 'Jalan 1');
        expect(map.containsKey('password'), isFalse);
      },
    );

    test('profile updates exclude role and identity fields', () {
      const user = UserModel(uid: 'u1', email: 'a@b.c', isAdmin: true);
      final update = user.toProfileUpdate();

      expect(update.containsKey('isAdmin'), isFalse);
      expect(update.containsKey('email'), isFalse);
      expect(update.containsKey('uId'), isFalse);
    });
  });

  group('WishlistItemModel', () {
    test('serialises with the legacy field names', () {
      final item = WishlistItemModel.fromProduct(
        ProductModel.fromMap({
          'productId': 'p1',
          'productName': 'Cap',
          'salePrice': '9.9',
        }),
      );
      final map = item.toMap();

      expect(map['productName'], 'Cap');
      expect(map['salePrice'], '9.9');
      expect(WishlistItemModel.fromMap(map).price, 9.9);
    });
  });

  group('OrderDraft', () {
    test('total is the sum of line totals', () {
      const draft = OrderDraft(
        customerId: 'u1',
        customerEmail: 'a@b.c',
        customerName: 'A',
        customerPhone: '1',
        customerAddress: 'X',
        deliveryDate: '01/01/2027',
        deliveryType: 'Normal Delivery',
        paymentMethod: PaymentMethod.cashOnDelivery,
        sellerIds: [],
        items: [
          OrderItemModel(productId: 'a', name: 'A', unitPrice: 10, quantity: 2),
          OrderItemModel(
            productId: 'b',
            name: 'B',
            unitPrice: 5.5,
            quantity: 1,
          ),
        ],
      );

      expect(draft.total, 25.5);
    });
  });
}
