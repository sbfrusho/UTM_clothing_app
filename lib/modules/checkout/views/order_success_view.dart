import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/order_success_view_model.dart';

class OrderSuccessView extends GetView<OrderSuccessViewModel> {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.backToShop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: palette.success.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 56,
                      color: palette.success,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Order placed!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.orderId == null
                      ? 'Thank you. We are preparing your order.'
                      : 'Thank you. We are preparing order '
                            '#${controller.shortId}.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: palette.mutedText,
                  ),
                ),
                Obx(
                  () => controller.offerNotifications
                      ? Container(
                          margin: const EdgeInsets.only(top: 28),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: palette.accent.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_active_outlined),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Get notified when it ships',
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                              TextButton(
                                onPressed: controller.isAsking.value
                                    ? null
                                    : controller.enableNotifications,
                                child: Text('Turn on'.tr),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 32),
                if (controller.orderId != null)
                  OutlinedButton(
                    onPressed: controller.viewOrder,
                    child: Text('View order'.tr),
                  ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: controller.backToShop,
                  child: Text('Continue shopping'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
