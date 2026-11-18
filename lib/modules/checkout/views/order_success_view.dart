import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../shell/view_models/shell_view_model.dart';

/// Static confirmation screen; the order id comes in as the route argument.
class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  void _backToShop() {
    Get.until((route) => route.settings.name == AppRoutes.shell);
    Get.find<ShellViewModel>().goTo(ShellTab.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderId = Get.arguments as String?;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToShop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 96),
                const SizedBox(height: 24),
                Text(
                  'Order placed!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you. We are preparing your order'
                  '${orderId == null ? '' : ' #${orderId.substring(0, 6).toUpperCase()}'}.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                if (orderId != null)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: () =>
                        Get.offNamed(AppRoutes.orderDetail, arguments: orderId),
                    child: const Text('View order'),
                  ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _backToShop,
                  child: const Text('Continue shopping'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
