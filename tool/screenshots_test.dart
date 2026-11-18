// Renders key screens with fake data to PNGs for design review.
//
//   flutter test tool/screenshots_test.dart --update-goldens
//
// Output: tool/screenshots/*.png (not part of the normal test run).
// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_shop/app/routes/app_pages.dart';
import 'package:your_shop/app/routes/app_routes.dart';
import 'package:your_shop/core/services/auth_service.dart';
import 'package:your_shop/core/services/biometric_service.dart';
import 'package:your_shop/core/services/payment/payment_service.dart';
import 'package:your_shop/core/services/theme_service.dart';
import 'package:your_shop/core/theme/app_theme.dart';
import 'package:your_shop/data/models/address_model.dart';
import 'package:your_shop/data/models/category_model.dart';
import 'package:your_shop/data/models/order_model.dart';
import 'package:your_shop/data/models/product_model.dart';
import 'package:your_shop/data/models/user_model.dart';
import 'package:your_shop/data/models/wishlist_item_model.dart';
import 'package:your_shop/data/repositories/address_repository.dart';
import 'package:your_shop/data/repositories/auth_repository.dart';
import 'package:your_shop/data/repositories/catalog_repository.dart';
import 'package:your_shop/data/repositories/order_repository.dart';
import 'package:your_shop/data/repositories/user_repository.dart';
import 'package:your_shop/data/repositories/wishlist_repository.dart';
import 'package:your_shop/modules/cart/view_models/cart_view_model.dart';
import 'package:your_shop/modules/shell/view_models/shell_view_model.dart';
import 'package:your_shop/modules/wishlist/view_models/wishlist_view_model.dart';

// ---------------------------------------------------------------- fake data
ProductModel _p(
  String id,
  String name,
  String cat,
  String sale,
  String full, {
  int stock = 12,
  List<String> sizes = const [],
}) => ProductModel.fromMap({
  'productId': id,
  'productName': name,
  'categoryName': cat,
  'salePrice': sale,
  'fullPrice': full,
  'quantity': '$stock',
  'productSizes': sizes,
  'deliveryTime': '2–4 working days',
  'productDescription':
      'Cut from soft, breathable cotton with a relaxed fit. Pre-washed '
      'for a lived-in feel from the first wear.',
});

final _products = [
  _p(
    '1',
    'Linen Overshirt',
    'Shirts',
    '89',
    '119',
    sizes: ['S', 'M', 'L', 'XL'],
  ),
  _p('2', 'Everyday Cap', 'Caps', '35', '35', stock: 3),
  _p('3', 'Stoneware Mug', 'Mugs', '29', '39'),
  _p('4', 'Heavyweight Tee', 'T-shirts', '49', '49', sizes: ['S', 'M', 'L']),
  _p('5', 'Corporate Polo', 'Corporate', '69', '79', stock: 0),
  _p('6', 'Canvas Tote', 'Bags', '25', '25'),
];

const _categories = [
  CategoryModel(id: 'c1', name: 'T-shirts', imageUrl: ''),
  CategoryModel(id: 'c2', name: 'Shirts', imageUrl: ''),
  CategoryModel(id: 'c3', name: 'Caps', imageUrl: ''),
  CategoryModel(id: 'c4', name: 'Mugs', imageUrl: ''),
  CategoryModel(id: 'c5', name: 'Corporate', imageUrl: ''),
];

// -------------------------------------------------------------------- fakes
class _Auth extends GetxService implements AuthService {
  @override
  final Rxn<User> user = Rxn<User>();
  @override
  User? get currentUser => null;
  @override
  String? get uid => 'u1';
  @override
  String? get email => 'aisha@example.com';
  @override
  bool get isSignedIn => true;
  @override
  bool get isEmailVerified => true;
  @override
  List<String> get providerIds => const ['password'];
  @override
  bool get hasPassword => true;
  @override
  bool get hasGoogle => false;
  @override
  Future<void> signOut() async {}
}

class _Catalog extends Fake implements CatalogRepository {
  @override
  Future<List<String>> fetchBannerUrls() async => const [];
  @override
  Future<List<CategoryModel>> fetchCategories() async => _categories;
  @override
  Future<List<ProductModel>> fetchLatest({int limit = 10}) async => _products;
  @override
  Future<ProductModel?> fetchProduct(String id) async =>
      _products.firstWhere((p) => p.id == id);
  @override
  Future<List<ProductModel>> search(String q, {int scanLimit = 300}) async =>
      _products;
}

class _Users extends Fake implements UserRepository {
  @override
  Future<UserModel?> fetch(String uid) async => const UserModel(
    uid: 'u1',
    email: 'aisha@example.com',
    name: 'Aisha Rahman',
    phone: '0123',
  );
}

class _Wishlist extends Fake implements WishlistRepository {
  @override
  Future<List<WishlistItemModel>> fetch(String email) async =>
      [_products[0], _products[2]].map(WishlistItemModel.fromProduct).toList();
  @override
  Future<void> save(String email, List<WishlistItemModel> items) async {}
}

class _Orders extends Fake implements OrderRepository {
  @override
  Future<List<OrderModel>> fetchForCustomer(String uid) async => [
    OrderModel.fromMap({
      'totalPrice': 118,
      'status': 'Shipped',
      'createdAt': DateTime(2026, 11, 12, 14, 30),
    }, id: 'a1b2c3d4'),
    OrderModel.fromMap({
      'totalPrice': 35,
      'status': 'Delivered',
      'createdAt': DateTime(2026, 10, 2, 9, 10),
    }, id: 'f9e8d7c6'),
  ];
}

class _Addresses extends Fake implements AddressRepository {
  @override
  Future<AddressModel?> fetchForUser(String email) async => null;
}

class _AuthRepo extends Fake implements AuthRepository {}

// ------------------------------------------------------------------ harness
Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(
        Future.value(ByteData.sublistView(File(f).readAsBytesSync())),
      );
    }
    await loader.load();
  }

  const dir = 'assets/fonts';
  await load('Manrope', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold'])
      '$dir/Manrope-$w.ttf',
  ]);
  await load('PlayfairDisplay', [
    '$dir/PlayfairDisplay-SemiBold.ttf',
    '$dir/PlayfairDisplay-Bold.ttf',
  ]);
  final flutterRoot =
      Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
  await load('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

void _registerFakes() {
  Get
    ..put<AuthService>(_Auth(), permanent: true)
    ..put(ThemeService(), permanent: true)
    ..put(BiometricService(), permanent: true)
    ..put(PaymentService(), permanent: true)
    ..put<CatalogRepository>(_Catalog())
    ..put<UserRepository>(_Users())
    ..put<WishlistRepository>(_Wishlist())
    ..put<OrderRepository>(_Orders())
    ..put<AddressRepository>(_Addresses())
    ..put<AuthRepository>(_AuthRepo())
    ..put(CartViewModel(), permanent: true)
    ..put(WishlistViewModel(), permanent: true);
}

Future<void> _shot(
  WidgetTester tester,
  String name, {
  required String route,
  Object? arguments,
  bool dark = false,
  void Function()? before,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2340)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  Get.reset();
  _registerFakes();
  before?.call();

  await tester.pumpWidget(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      getPages: AppPages.routes,
      // Routes that need arguments are pushed after a neutral first route.
      initialRoute: arguments == null ? route : AppRoutes.welcome,
    ),
  );
  if (arguments != null) {
    Get.toNamed<void>(route, arguments: arguments);
  }
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
  await expectLater(
    find.byType(GetMaterialApp),
    matchesGoldenFile('screenshots/$name.png'),
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await _loadFonts();
  });

  void fillCart() {
    Get.find<CartViewModel>()
      ..add(_products[0], size: 'M')
      ..add(_products[2])
      ..add(_products[2]);
  }

  testWidgets(
    'welcome',
    (t) => _shot(t, '01_welcome', route: AppRoutes.welcome),
  );
  testWidgets('login', (t) => _shot(t, '02_login', route: AppRoutes.login));
  testWidgets(
    'home',
    (t) => _shot(t, '03_home', route: AppRoutes.shell, before: fillCart),
  );
  testWidgets(
    'categories',
    (t) => _shot(
      t,
      '04_categories',
      route: AppRoutes.shell,
      before: () {
        Get.put(ShellViewModel()..goTo(ShellTab.categories));
      },
    ),
  );
  testWidgets(
    'product',
    (t) => _shot(
      t,
      '05_product',
      route: AppRoutes.productDetail,
      arguments: _products[0],
    ),
  );
  testWidgets(
    'cart',
    (t) => _shot(
      t,
      '06_cart',
      route: AppRoutes.shell,
      before: () {
        fillCart();
        Get.put(ShellViewModel()..goTo(ShellTab.cart));
      },
    ),
  );
  testWidgets(
    'profile',
    (t) => _shot(
      t,
      '07_profile',
      route: AppRoutes.shell,
      before: () {
        Get.put(ShellViewModel()..goTo(ShellTab.profile));
      },
    ),
  );
  testWidgets('orders', (t) => _shot(t, '08_orders', route: AppRoutes.orders));
  testWidgets(
    'home dark',
    (t) => _shot(
      t,
      '09_home_dark',
      route: AppRoutes.shell,
      dark: true,
      before: fillCart,
    ),
  );
  testWidgets(
    'product dark',
    (t) => _shot(
      t,
      '10_product_dark',
      route: AppRoutes.productDetail,
      arguments: _products[0],
      dark: true,
    ),
  );
}
