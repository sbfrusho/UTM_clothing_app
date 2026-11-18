import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../../cart/view_models/cart_view_model.dart';

enum ShellTab { home, categories, wishlist, cart, profile }

class ShellViewModel extends GetxController {
  final Rx<ShellTab> currentTab = ShellTab.home.obs;

  @override
  void onReady() {
    super.onReady();
    // App launched by tapping an order notification.
    if (Get.isRegistered<NotificationService>()) {
      Get.find<NotificationService>().openPendingIfAny();
    }
  }

  void select(int index) => goTo(ShellTab.values[index]);

  void goTo(ShellTab tab) {
    currentTab.value = tab;
    // Opening the cart re-checks prices and stock against the catalogue.
    if (tab == ShellTab.cart && Get.isRegistered<CartViewModel>()) {
      Get.find<CartViewModel>().refreshFromCatalog();
    }
  }
}
