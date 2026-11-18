import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/payment/payment_gateway.dart';
import '../../../core/services/payment/payment_service.dart';
import '../../../core/services/push_token_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../cart/view_models/cart_view_model.dart';
import '../../profile/view_models/address_book_view_model.dart';

enum DeliveryType {
  normal('Normal Delivery'),
  pickup('Pick up'),
  preferredTime('Preferred time');

  const DeliveryType(this.label);
  final String label;
}

/// Checkout. Orders are created **first** (stock reserved, cart emptied in
/// one transaction); card payment then pays for that stored order.
class CheckoutViewModel extends GetxController {
  CheckoutViewModel({
    required AuthService auth,
    required AddressRepository addresses,
    required OrderRepository orders,
    required PaymentService payments,
    required this.cart,
  }) : _auth = auth,
       _addresses = addresses,
       _orders = orders,
       _payments = payments;

  final AuthService _auth;
  final AddressRepository _addresses;
  final OrderRepository _orders;
  final PaymentService _payments;
  final CartViewModel cart;

  final Rxn<AddressModel> address = Rxn<AddressModel>();
  final Rxn<DateTime> deliveryDate = Rxn<DateTime>();
  final Rx<DeliveryType> deliveryType = DeliveryType.normal.obs;
  final Rx<PaymentMethod> paymentMethod = PaymentMethod.cashOnDelivery.obs;
  final RxBool isLoadingAddress = true.obs;
  final RxBool isSubmitting = false.obs;

  /// Shown on the button while the order is being written or paid.
  final RxString stage = ''.obs;

  String get deliveryDateLabel => Formatters.date(deliveryDate.value);
  bool get isTestPayments => _payments.isTestMode;

  @override
  void onInit() {
    super.onInit();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final uid = _auth.uid;
    try {
      if (uid != null) {
        final book = await _addresses.fetchAll(uid);
        address.value = book.isEmpty ? null : book.first; // default first
      }
    } on AppException catch (e) {
      AppLogger.error('Checkout address load failed', e);
    } finally {
      isLoadingAddress.value = false;
    }
  }

  Future<void> chooseAddress() async {
    final picked = await Get.toNamed<AddressModel>(
      AppRoutes.address,
      arguments: AddressBookArgs.select,
    );
    if (picked != null) address.value = picked;
  }

  Future<void> addAddress() async {
    final saved = await Get.toNamed<AddressModel>(AppRoutes.addressForm);
    if (saved != null) address.value = saved;
  }

  void setDeliveryDate(DateTime date) => deliveryDate.value = date;
  void setDeliveryType(DeliveryType type) => deliveryType.value = type;
  void setPaymentMethod(PaymentMethod method) => paymentMethod.value = method;

  /// What's missing before an order can be placed, or null.
  String? get blocker {
    if (!cart.canCheckout) {
      return cart.hasUnavailable
          ? 'Remove unavailable items from your cart first.'
          : 'Your cart is empty.';
    }
    if (address.value == null) return 'Add a delivery address.';
    if (deliveryDate.value == null) return 'Choose a delivery date.';
    return null;
  }

  Future<void> placeOrder() async {
    if (isSubmitting.value) return;
    final problem = blocker;
    if (problem != null) {
      AppSnackbar.info(problem);
      return;
    }
    final uid = _auth.uid;
    final email = _auth.email;
    final to = address.value!;
    if (uid == null || email == null) return;

    isSubmitting.value = true;
    final lines = cart.availableItems;
    final isCard = paymentMethod.value == PaymentMethod.card;
    try {
      // 1. Re-check stock and prices against the server.
      stage.value = 'Checking stock…';
      await _orders.verifyCart(lines);

      // 2. Create the order: stock reserved, cart emptied, atomically.
      stage.value = 'Placing order…';
      final draft = OrderDraft(
        customerId: uid,
        customerEmail: email,
        customerName: to.fullName,
        customerPhone: to.phone,
        customerAddress: to.formatted,
        deliveryDate: Formatters.date(deliveryDate.value),
        deliveryType: deliveryType.value.label,
        paymentMethod: paymentMethod.value,
        paymentGateway: isCard ? _payments.gatewayId : GatewayId.cod,
        deviceToken: await PushTokenService.getToken(),
        sellerIds: cart.sellerIds,
        items: [
          for (final i in lines)
            OrderItemModel(
              productId: i.productId,
              name: i.name,
              unitPrice: i.unitPrice,
              quantity: i.quantity,
              size: i.size,
              imageUrl: i.imageUrl,
            ),
        ],
      );
      final orderId = await _orders.placeOrder(draft, lines);
      cart.clear();

      if (!isCard) {
        Get.offNamed<void>(AppRoutes.orderSuccess, arguments: orderId);
        return;
      }

      // 3. Pay for the stored order.
      stage.value = 'Waiting for payment…';
      final result = await _payments.payForOrder(orderId, draft.total);
      if (result.isSuccess) {
        Get.offNamed<void>(AppRoutes.orderSuccess, arguments: orderId);
      } else {
        // The order stays reserved; it can be paid or cancelled from its
        // page, and is released automatically after the payment window.
        Get.offNamed<void>(AppRoutes.orderDetail, arguments: orderId);
        AppSnackbar.info(
          '${result.status == PaymentStatus.cancelled ? 'Payment cancelled.' : result.message ?? 'Payment failed.'} '
          'Your items are reserved for '
          '${OrderModel.paymentWindow.inMinutes} minutes.',
          title: 'Order not paid yet',
        );
      }
    } on AppException catch (e) {
      AppSnackbar.error(e.message, title: 'Order not placed');
    } finally {
      isSubmitting.value = false;
      stage.value = '';
    }
  }
}
