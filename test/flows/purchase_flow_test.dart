// End-to-end purchase flow on fakes: real view models, repositories and
// payment service; Firestore and Auth replaced by in-memory fakes. Runs in
// CI without a device or a Firebase project.
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_shop/app/routes/app_routes.dart';
import 'package:your_shop/core/services/auth_service.dart';
import 'package:your_shop/core/services/functions_client.dart';
import 'package:your_shop/core/services/notification_service.dart';
import 'package:your_shop/core/services/payment/demo_payment_gateway.dart';
import 'package:your_shop/core/services/payment/payment_service.dart';
import 'package:your_shop/data/catalog/catalog_source.dart';
import 'package:your_shop/data/models/address_model.dart';
import 'package:your_shop/data/models/order_model.dart';
import 'package:your_shop/data/models/product_model.dart';
import 'package:your_shop/data/repositories/address_repository.dart';
import 'package:your_shop/data/repositories/cart_repository.dart';
import 'package:your_shop/data/repositories/catalog_repository.dart';
import 'package:your_shop/data/repositories/order_repository.dart';
import 'package:your_shop/modules/cart/view_models/cart_view_model.dart';
import 'package:your_shop/modules/checkout/view_models/checkout_view_model.dart';

class _Messaging extends Mock implements FirebaseMessaging {}

class _NoBackend extends Mock implements FunctionsClient {
  @override
  bool get isConfigured => false;
}

void main() {
  late FakeFirebaseFirestore db;
  late CartViewModel cart;
  late OrderRepository orders;

  Future<void> boot(WidgetTester tester) async {
    db = FakeFirebaseFirestore();
    await db.doc('products/tee').set({
      'productId': 'tee',
      'productName': 'Linen tee',
      'salePrice': '49.90',
      'quantity': '4',
      'productSizes': ['S', 'M'],
      'email': 'seller@shop.com',
    });
    final auth = AuthService(
      auth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'alice', email: 'alice@example.com'),
      ),
    );
    final messaging = _Messaging();
    // The app still reads the token this way (see NotificationService).
    // ignore: deprecated_member_use
    when(messaging.getToken).thenAnswer((_) async => 'device-1');

    orders = OrderRepository(firestore: db, functions: _NoBackend());
    Get.put(auth);
    Get.put(NotificationService(messaging: messaging));
    cart = Get.put(
      CartViewModel(
        repository: CartRepository(firestore: db),
        catalog: CatalogRepository(
          source: FirestoreCatalogSource(firestore: db),
        ),
        auth: auth,
      ),
    );
    await AddressRepository(firestore: db).save(
      'alice',
      const AddressModel(
        fullName: 'Alice Tan',
        phone: '01712345678',
        address: '12A',
        city: 'Dhaka',
        postalCode: '1205',
        country: 'Bangladesh',
      ),
    );
    Get.put(
      CheckoutViewModel(
        auth: auth,
        addresses: AddressRepository(firestore: db),
        orders: orders,
        payments: PaymentService(gateway: DemoPaymentGateway(), orders: orders),
        cart: cart,
      ),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.checkout,
        getPages: [
          GetPage(name: AppRoutes.checkout, page: () => const Scaffold()),
          for (final r in [AppRoutes.orderSuccess, AppRoutes.orderDetail])
            GetPage(
              name: r,
              page: () => Scaffold(body: Text('$r ${Get.arguments}')),
            ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<ProductModel> product() async => ProductModel.fromMap({
    ...?(await db.doc('products/tee').get()).data(),
    'productId': 'tee',
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  tearDown(Get.reset);

  testWidgets('cash on delivery: order placed, stock reserved, cart emptied', (
    tester,
  ) async {
    await boot(tester);
    final checkout = Get.find<CheckoutViewModel>();
    final tee = await product();
    cart
      ..add(tee, size: 'S')
      ..add(tee, size: 'M')
      ..add(tee, size: 'M');
    await settle(tester);
    expect(cart.itemCount, 3);
    expect(checkout.address.value?.fullName, 'Alice Tan');
    expect(checkout.blocker, 'Choose a delivery date.');

    checkout.setDeliveryDate(DateTime(2026, 12, 1));
    await checkout.placeOrder();
    await settle(tester);

    final placed = await db.collection('orders').get();
    expect(placed.docs, hasLength(1));
    final order = placed.docs.single;
    expect(find.text('${AppRoutes.orderSuccess} ${order.id}'), findsOneWidget);
    expect(order.get('customerId'), 'alice');
    expect(order.get('customerDeviceToken'), 'device-1');
    expect(order.get('paymentStatus'), PaymentStatusValue.unpaid);
    expect(order.get('totalPrice'), closeTo(149.70, 0.001));
    expect((await db.doc('products/tee').get()).get('quantity'), '1');
    expect((await db.collection('users/alice/cart').get()).docs, isEmpty);
    expect(cart.isEmpty, isTrue);
  });

  testWidgets('card (test mode): order is paid after confirming', (
    tester,
  ) async {
    await boot(tester);
    final checkout = Get.find<CheckoutViewModel>();
    expect(cart.add(await product(), size: 'S'), CartAddResult.added);
    await settle(tester);
    checkout
      ..setDeliveryDate(DateTime(2026, 12, 1))
      ..setPaymentMethod(PaymentMethod.card);

    final placing = checkout.placeOrder();
    await settle(tester);
    expect(find.text('Test payment'), findsOneWidget);
    await tester.tap(find.text('Pay'));
    await settle(tester);
    await placing;
    await settle(tester);

    final order = (await db.collection('orders').get()).docs.single;
    expect(order.get('paymentGateway'), 'demo');
    expect(order.get('paymentStatus'), PaymentStatusValue.paid);
    expect(find.text('${AppRoutes.orderSuccess} ${order.id}'), findsOneWidget);
  });

  testWidgets('card cancelled: order stays reserved, awaiting payment', (
    tester,
  ) async {
    await boot(tester);
    final checkout = Get.find<CheckoutViewModel>();
    expect(cart.add(await product(), size: 'S'), CartAddResult.added);
    await settle(tester);
    checkout
      ..setDeliveryDate(DateTime(2026, 12, 1))
      ..setPaymentMethod(PaymentMethod.card);

    final placing = checkout.placeOrder();
    await settle(tester);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    await placing;
    await settle(tester);

    final order = (await db.collection('orders').get()).docs.single;
    expect(order.get('paymentStatus'), PaymentStatusValue.awaitingPayment);
    expect((await db.doc('products/tee').get()).get('quantity'), '3');
    expect(find.text('${AppRoutes.orderDetail} ${order.id}'), findsOneWidget);
    // Let the "not paid yet" snackbar finish.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
