import 'package:flutter/widgets.dart';
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
import '../../../data/repositories/user_repository.dart';
import '../../cart/view_models/cart_view_model.dart';

enum DeliveryType {
  normal('Normal Delivery'),
  pickup('Pick up'),
  preferredTime('Preferred time');

  const DeliveryType(this.label);
  final String label;
}

class CheckoutViewModel extends GetxController {
  CheckoutViewModel({
    required AuthService auth,
    required UserRepository users,
    required AddressRepository addresses,
    required OrderRepository orders,
    required PaymentService payments,
    required this.cart,
  }) : _auth = auth,
       _users = users,
       _addresses = addresses,
       _orders = orders,
       _payments = payments;

  final AuthService _auth;
  final UserRepository _users;
  final AddressRepository _addresses;
  final OrderRepository _orders;
  final PaymentService _payments;
  final CartViewModel cart;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final Rxn<DateTime> deliveryDate = Rxn<DateTime>();
  final Rx<DeliveryType> deliveryType = DeliveryType.normal.obs;
  final Rx<PaymentMethod> paymentMethod = PaymentMethod.cashOnDelivery.obs;
  final RxBool isLoadingProfile = true.obs;
  final RxBool isSubmitting = false.obs;

  String get deliveryDateLabel => Formatters.date(deliveryDate.value);

  @override
  void onInit() {
    super.onInit();
    _prefill();
  }

  /// Pre-fills contact details from the profile and saved address.
  Future<void> _prefill() async {
    final uid = _auth.uid;
    final email = _auth.email;
    try {
      if (uid != null) {
        final profile = await _users.fetch(uid);
        nameController.text = profile?.name ?? '';
        phoneController.text = profile?.phone ?? '';
      }
      if (email != null) {
        final address = await _addresses.fetchForUser(email);
        addressController.text = address?.formatted ?? '';
      }
    } on AppException catch (e) {
      AppLogger.error('Checkout prefill failed', e);
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> openAddressBook() async {
    final result = await Get.toNamed(AppRoutes.address);
    if (result is AddressModel) addressController.text = result.formatted;
  }

  void setDeliveryDate(DateTime date) => deliveryDate.value = date;
  void setDeliveryType(DeliveryType type) => deliveryType.value = type;
  void setPaymentMethod(PaymentMethod method) => paymentMethod.value = method;

  Future<void> placeOrder() async {
    if (!cart.canCheckout) {
      AppSnackbar.error(
        cart.hasUnavailable
            ? 'Remove unavailable items from your cart first.'
            : 'Your cart is empty.',
      );
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (deliveryDate.value == null) {
      AppSnackbar.info(
        'Please choose a delivery date.',
        title: 'Delivery date',
      );
      return;
    }
    final uid = _auth.uid;
    final email = _auth.email;
    if (uid == null || email == null) {
      Get.offAllNamed(AppRoutes.welcome);
      return;
    }

    isSubmitting.value = true;
    try {
      final cartItems = cart.availableItems;

      // 1. Re-check stock and prices before any money moves.
      await _orders.verifyCart(cartItems);

      // 2. Take payment (card only).
      String? paymentReference;
      if (paymentMethod.value == PaymentMethod.card) {
        final result = await _payments.pay(cart.total);
        if (result.status == PaymentStatus.cancelled) return;
        if (!result.isSuccess) {
          AppSnackbar.error(result.message ?? 'Payment failed.');
          return;
        }
        paymentReference = result.reference;
      }

      // 3. Write the order and decrement stock atomically.
      final draft = OrderDraft(
        customerId: uid,
        customerEmail: email,
        customerName: nameController.text.trim(),
        customerPhone: phoneController.text.trim(),
        customerAddress: addressController.text.trim(),
        deliveryDate: Formatters.date(deliveryDate.value),
        deliveryType: deliveryType.value.label,
        paymentMethod: paymentMethod.value,
        paymentReference: paymentReference,
        deviceToken: await PushTokenService.getToken(),
        sellerIds: cart.sellerIds,
        items: cartItems
            .map(
              (i) => OrderItemModel(
                productId: i.productId,
                name: i.name,
                unitPrice: i.unitPrice,
                quantity: i.quantity,
                size: i.size,
                imageUrl: i.imageUrl,
              ),
            )
            .toList(),
      );

      try {
        final orderId = await _orders.placeOrder(draft, cartItems);
        cart.clear();
        Get.offNamed(AppRoutes.orderSuccess, arguments: orderId);
      } on AppException catch (e) {
        if (paymentReference != null) {
          // Paid but stock changed in between: needs a refund (Sprint 7
          // moves this server-side so it cannot happen).
          AppLogger.error('Order failed after payment $paymentReference', e);
          AppSnackbar.error(
            '${e.message}\nYour payment ($paymentReference) will be refunded.',
            title: 'Order not placed',
          );
          return;
        }
        rethrow;
      }
    } on AppException catch (e) {
      AppSnackbar.error(e.message, title: 'Order not placed');
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
