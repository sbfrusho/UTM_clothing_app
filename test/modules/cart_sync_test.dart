import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:your_shop/data/models/cart_item_model.dart';
import 'package:your_shop/data/models/product_model.dart';
import 'package:your_shop/data/models/wishlist_item_model.dart';
import 'package:your_shop/modules/cart/view_models/cart_view_model.dart';
import 'package:your_shop/modules/wishlist/view_models/wishlist_view_model.dart';

ProductModel _p(String id, {String price = '10', int stock = 5}) =>
    ProductModel.fromMap({
      'productId': id,
      'productName': 'P$id',
      'salePrice': price,
      'quantity': '$stock',
    });

CartItemModel _line(
  String id, {
  String size = '',
  int qty = 1,
  double price = 10,
}) => CartItemModel(
  productId: id,
  name: 'P$id',
  imageUrl: '',
  unitPrice: price,
  sellerEmail: '',
  maxQuantity: 5,
  size: size,
  quantity: qty,
);

WishlistItemModel _w(String id) => WishlistItemModel.fromProduct(_p(id));

void main() {
  group('CartItemModel', () {
    test('keys are Firestore-safe and distinct per size', () {
      expect(CartItemModel.keyFor('p1', ''), 'p1__');
      expect(CartItemModel.keyFor('p1', 'UK 8/9'), 'p1__UK%208%2F9');
      expect(
        CartItemModel.keyFor('p1', 'S'),
        isNot(CartItemModel.keyFor('p1', 'M')),
      );
    });

    test('round-trips through its stored map', () {
      final line = _line('p1', size: 'M', qty: 3, price: 12.5);
      final back = CartItemModel.fromMap(line.toMap());
      expect(back.key, line.key);
      expect(back.quantity, 3);
      expect(back.unitPrice, 12.5);
      expect(back.storedDiffers(line), isFalse);
    });
  });

  group('CartViewModel.reconcile', () {
    test('updates prices and reports the change', () {
      final r = CartViewModel.reconcile(
        [_line('a', price: 10)],
        {'a': _p('a', price: '8')},
      );
      expect(r.items.single.unitPrice, 8);
      expect(r.changed, hasLength(1));
      expect(r.notices.single, contains('dropped'));
    });

    test('flags removed and sold-out products as unavailable', () {
      final r = CartViewModel.reconcile(
        [_line('gone'), _line('empty')],
        {'empty': _p('empty', stock: 0)},
      );
      expect(r.items.map((i) => i.isAvailable), [false, false]);
      expect(r.notices, hasLength(2));
    });

    test('shares stock across sizes in cart order', () {
      final r = CartViewModel.reconcile(
        [_line('a', size: 'S', qty: 2), _line('a', size: 'M', qty: 2)],
        {'a': _p('a', stock: 3)},
      );
      expect(r.items.map((i) => i.quantity), [2, 1]);
      expect(r.items.every((i) => i.isAvailable), isTrue);
      expect(r.notices.single, contains('Only 1'));
    });

    test('nothing to write when the cart is already current', () {
      final r = CartViewModel.reconcile([_line('a')], {'a': _p('a')});
      expect(r.changed, isEmpty);
      expect(r.notices, isEmpty);
    });
  });

  group('cart totals', () {
    test('unavailable lines are excluded and block checkout', () {
      final cart = CartViewModel()
        ..items.assignAll([
          _line('a', qty: 2),
          _line('b').copyWith(isAvailable: false),
        ]);
      expect(cart.itemCount, 2);
      expect(cart.total, 20);
      expect(cart.availableItems, hasLength(1));
      expect(cart.canCheckout, isFalse);
      cart.removeUnavailable();
      expect(cart.canCheckout, isTrue);
    });
  });

  group('WishlistViewModel.applyPending', () {
    test('an unconfirmed add survives an older snapshot', () {
      final pending = <String, WishlistItemModel?>{'new': _w('new')};
      final out = WishlistViewModel.applyPending([_w('old')], pending);
      expect(out.map((i) => i.productId), ['new', 'old']);
      expect(pending, contains('new'));
    });

    test('an unconfirmed removal stays hidden', () {
      final pending = <String, WishlistItemModel?>{'old': null};
      final out = WishlistViewModel.applyPending([_w('old'), _w('x')], pending);
      expect(out.map((i) => i.productId), ['x']);
    });

    test('confirmed toggles are forgotten', () {
      final pending = <String, WishlistItemModel?>{'a': _w('a'), 'b': null};
      final out = WishlistViewModel.applyPending([_w('a')], pending);
      expect(out.map((i) => i.productId), ['a']);
      expect(pending, isEmpty);
    });
  });
}
