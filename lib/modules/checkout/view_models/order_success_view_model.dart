import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../shell/view_models/shell_view_model.dart';

/// After an order: the moment notifications are obviously useful, so the
/// permission is offered here rather than at first launch.
class OrderSuccessViewModel extends GetxController {
  OrderSuccessViewModel(this._notifications);

  final NotificationService _notifications;

  final String? orderId = Get.arguments as String?;
  final RxBool isAsking = false.obs;

  String get shortId => orderId == null
      ? ''
      : orderId!
            .substring(0, orderId!.length < 6 ? orderId!.length : 6)
            .toUpperCase();

  /// Show the prompt only when we know notifications are off.
  bool get offerNotifications => _notifications.enabled.value == false;

  Future<void> enableNotifications() async {
    isAsking.value = true;
    final ok = await _notifications.requestPermission();
    isAsking.value = false;
    if (ok) {
      AppSnackbar.success("We'll let you know when your order ships.");
    } else {
      AppSnackbar.info(
        'You can turn them on later in Profile or in system settings.',
        title: 'Notifications are off',
      );
    }
  }

  void viewOrder() =>
      Get.offNamed<void>(AppRoutes.orderDetail, arguments: orderId);

  void backToShop() {
    Get.until((route) => route.settings.name == AppRoutes.shell);
    Get.find<ShellViewModel>().goTo(ShellTab.home);
  }
}
