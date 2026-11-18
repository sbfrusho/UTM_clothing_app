import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/payment/payment_service.dart';
import '../../core/services/session_service.dart';
import '../../data/repositories/address_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../modules/cart/view_models/cart_view_model.dart';
import '../../modules/wishlist/view_models/wishlist_view_model.dart';

/// App-wide dependencies.
///
/// Repositories are lazy singletons (`fenix` recreates them if disposed).
/// Cart and wishlist view models are shared by several screens, so they
/// live for the whole session.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final auth = Get.put(AuthService(), permanent: true);
    Get.put(SessionService(auth, Get.find()), permanent: true);
    Get.put(PaymentService(), permanent: true);

    Get.lazyPut(AuthRepository.new, fenix: true);
    Get.lazyPut(UserRepository.new, fenix: true);
    Get.lazyPut(CatalogRepository.new, fenix: true);
    Get.lazyPut(WishlistRepository.new, fenix: true);
    Get.lazyPut(AddressRepository.new, fenix: true);
    Get.lazyPut(OrderRepository.new, fenix: true);

    Get.put(CartViewModel(), permanent: true);
    Get.put(WishlistViewModel(), permanent: true);
  }
}
