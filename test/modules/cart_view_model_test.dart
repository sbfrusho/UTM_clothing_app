import 'package:flutter_test/flutter_test.dart';
import 'package:your_shop/data/models/product_model.dart';
import 'package:your_shop/modules/cart/view_models/cart_view_model.dart';

ProductModel _product({
  String id = 'p1',
  int stock = 5,
  List<String> sizes = const [],
  String price = '10',
  String seller = 'seller@shop.com',
}) => ProductModel.fromMap({
  'productId': id,
  'productName': 'Product $id',
  'salePrice': price,
  'quantity': '$stock',
  'productSizes': sizes,
  'email': seller,
});

void main() {
  late CartViewModel cart;

  setUp(() => cart = CartViewModel());

  test('adding the same product twice increases quantity, not lines', () {
    final p = _product();

    expect(cart.add(p), CartAddResult.added);
    expect(cart.add(p), CartAddResult.increased);
    expect(cart.items, hasLength(1));
    expect(cart.itemCount, 2);
    expect(cart.total, 20);
  });

  test('different sizes are separate lines', () {
    final p = _product(sizes: ['S', 'M']);

    cart.add(p, size: 'S');
    cart.add(p, size: 'M');

    expect(cart.items, hasLength(2));
  });

  test('size is required when the product has sizes', () {
    expect(cart.add(_product(sizes: ['S'])), CartAddResult.sizeRequired);
    expect(cart.isEmpty, isTrue);
  });

  test('cannot exceed stock across sizes', () {
    final p = _product(stock: 2, sizes: ['S', 'M']);

    cart.add(p, size: 'S');
    cart.add(p, size: 'M');

    expect(cart.add(p, size: 'S'), CartAddResult.limitReached);
    expect(cart.increment(cart.items.first.key), isFalse);
    expect(cart.itemCount, 2);
  });

  test('out of stock products cannot be added', () {
    expect(cart.add(_product(stock: 0)), CartAddResult.outOfStock);
  });

  test('decrement removes the line at quantity 1', () {
    final p = _product();
    cart.add(p);

    cart.decrement(cart.items.first.key);

    expect(cart.isEmpty, isTrue);
  });

  test('sellerIds lists each seller once', () {
    cart.add(_product(id: 'a', seller: 'x@shop.com'));
    cart.add(_product(id: 'b', seller: 'x@shop.com'));
    cart.add(_product(id: 'c', seller: 'y@shop.com'));

    expect(cart.sellerIds, unorderedEquals(['x@shop.com', 'y@shop.com']));
  });
}
