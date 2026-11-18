import 'package:get/get.dart';

import '../../modules/auth/bindings/auth_bindings.dart';
import '../../modules/auth/views/app_lock_view.dart';
import '../../modules/auth/views/forgot_password_view.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/auth/views/verify_email_view.dart';
import '../../modules/auth/views/welcome_view.dart';
import '../../modules/catalog/bindings/product_list_binding.dart';
import '../../modules/catalog/views/product_list_view.dart';
import '../../modules/checkout/bindings/checkout_binding.dart';
import '../../modules/checkout/views/checkout_view.dart';
import '../../modules/checkout/views/order_success_view.dart';
import '../../modules/orders/bindings/orders_bindings.dart';
import '../../modules/orders/views/order_detail_view.dart';
import '../../modules/orders/views/orders_view.dart';
import '../../modules/product/bindings/product_detail_binding.dart';
import '../../modules/product/views/product_detail_view.dart';
import '../../modules/product/views/product_gallery_view.dart';
import '../../modules/profile/bindings/profile_bindings.dart';
import '../../modules/profile/views/address_book_view.dart';
import '../../modules/profile/views/address_form_view.dart';
import '../../modules/profile/views/edit_profile_view.dart';
import '../../modules/search/bindings/search_binding.dart';
import '../../modules/search/views/search_view.dart';
import '../../modules/shell/bindings/shell_binding.dart';
import '../../modules/shell/views/shell_view.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import '../middlewares/auth_middleware.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final _auth = [AuthMiddleware()];

  static final routes = <GetPage<dynamic>>[
    // Public
    GetPage(
      name: AppRoutes.splash,
      page: SplashView.new,
      binding: SplashBinding(),
    ),
    GetPage(name: AppRoutes.welcome, page: WelcomeView.new),
    GetPage(
      name: AppRoutes.login,
      page: LoginView.new,
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: RegisterView.new,
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: ForgotPasswordView.new,
      binding: ForgotPasswordBinding(),
    ),

    // Signed in, email not yet verified
    GetPage(
      name: AppRoutes.verifyEmail,
      page: VerifyEmailView.new,
      binding: VerifyEmailBinding(),
      middlewares: [AuthMiddleware(requireVerified: false)],
    ),

    // Signed in and verified
    GetPage(
      name: AppRoutes.appLock,
      page: AppLockView.new,
      binding: AppLockBinding(),
      middlewares: _auth,
      popGesture: false,
    ),
    GetPage(
      name: AppRoutes.shell,
      page: ShellView.new,
      binding: ShellBinding(),
      middlewares: _auth,
    ),
    GetPage(
      name: AppRoutes.productList,
      page: ProductListView.new,
      binding: ProductListBinding(),
      middlewares: _auth,
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: ProductDetailView.new,
      binding: ProductDetailBinding(),
      middlewares: _auth,
    ),
    GetPage(
      name: AppRoutes.productGallery,
      page: ProductGalleryView.new,
      middlewares: _auth,
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.search,
      page: SearchView.new,
      binding: SearchBinding(),
      middlewares: _auth,
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: CheckoutView.new,
      binding: CheckoutBinding(),
      middlewares: _auth,
    ),
    GetPage(
      name: AppRoutes.orderSuccess,
      page: OrderSuccessView.new,
      binding: OrderSuccessBinding(),
      middlewares: _auth,
    ),
    GetPage(
      name: AppRoutes.orders,
      page: OrdersView.new,
      binding: OrdersBinding(),
      middlewares: _auth,
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: OrderDetailView.new,
      binding: OrderDetailBinding(),
      middlewares: _auth,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: EditProfileView.new,
      binding: EditProfileBinding(),
      middlewares: _auth,
    ),
    GetPage(
      name: AppRoutes.address,
      page: AddressBookView.new,
      binding: AddressBookBinding(),
      middlewares: _auth,
    ),
    GetPage(
      name: AppRoutes.addressForm,
      page: AddressFormView.new,
      binding: AddressFormBinding(),
      middlewares: _auth,
    ),
  ];
}
