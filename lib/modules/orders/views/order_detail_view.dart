import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/order_model.dart';
import '../view_models/order_detail_view_model.dart';
import 'order_status_chip.dart';

class OrderDetailView extends GetView<OrderDetailViewModel> {
  const OrderDetailView({super.key});

  Future<void> _confirmCancel(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: const Text(
          'The items go back on sale. Anything you paid is refunded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (ok ?? false) await controller.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Scaffold(
      appBar: const AppTopBar(title: 'Order details'),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();
        final order = controller.order.value;
        if (order == null) {
          return ErrorView(
            message: controller.error.value ?? 'Order not found.',
            onRetry: controller.load,
          );
        }
        Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedText,
                  ),
                ),
              ),
              Expanded(child: Text(value)),
            ],
          ),
        );
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.shortId}',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                OrderStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Placed ${Formatters.dateTime(order.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedText,
              ),
            ),
            if (order.isAwaitingPayment) ...[
              const SizedBox(height: 16),
              _PaymentBanner(order: order),
            ],
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _Timeline(order: order),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    row('Deliver to', order.customerName),
                    row('Phone', order.customerPhone),
                    row('Address', order.customerAddress),
                    row(
                      'Delivery',
                      [
                        order.deliveryType,
                        order.deliveryDate,
                      ].where((s) => s.isNotEmpty).join(' · '),
                    ),
                    row(
                      'Payment',
                      '${order.paymentMethod} · ${order.paymentSummary}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Items', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    AppNetworkImage(
                      item.imageUrl.isEmpty ? null : item.imageUrl,
                      width: 56,
                      height: 56,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: theme.textTheme.titleSmall),
                          Text(
                            '${item.quantity} × '
                            '${Formatters.price(item.unitPrice)}'
                            '${item.size.isEmpty ? '' : ' · Size ${item.size}'}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(Formatters.price(item.total)),
                  ],
                ),
              ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text('Total', style: theme.textTheme.titleMedium),
                ),
                Text(
                  Formatters.price(order.totalPrice),
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            if (controller.canCancel(order)) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                onPressed: controller.isBusy.value
                    ? null
                    : () => _confirmCancel(context),
                child: const Text('Cancel order'),
              ),
            ] else if (order.orderStatus == OrderStatus.pending) ...[
              const SizedBox(height: 16),
              Text(
                'Paid orders are cancelled by the shop. Contact us and '
                "we'll refund you.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedText,
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _PaymentBanner extends GetView<OrderDetailViewModel> {
  const _PaymentBanner({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final deadline = order.paymentDeadline;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Payment needed', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            deadline == null
                ? 'Your items are reserved for a short time.'
                : 'Your items are reserved until '
                      '${TimeOfDay.fromDateTime(deadline).format(context)}. '
                      'After that the order is released.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Obx(
            () => FilledButton(
              onPressed: controller.isBusy.value ? null : controller.pay,
              child: Text('Pay ${Formatters.price(order.totalPrice)}'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pending → Confirmed → Shipped → Delivered, or a cancelled marker.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final scheme = theme.colorScheme;

    final steps = order.isCancelled
        ? [OrderStatus.pending, OrderStatus.cancelled]
        : OrderStatus.timeline;
    final reached = order.isCancelled
        ? 1
        : OrderStatus.timeline.indexOf(order.orderStatus);

    String caption(OrderStatus s) => switch (s) {
      OrderStatus.pending => 'Order placed',
      OrderStatus.confirmed => 'Confirmed by the shop',
      OrderStatus.shipped => 'On the way',
      OrderStatus.delivered => 'Delivered',
      OrderStatus.cancelled => 'Cancelled',
    };

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= reached
                              ? (steps[i] == OrderStatus.cancelled
                                    ? scheme.error
                                    : scheme.primary)
                              : scheme.surfaceContainerHigh,
                          border: Border.all(
                            color: i <= reached
                                ? Colors.transparent
                                : scheme.outlineVariant,
                          ),
                        ),
                        child: i <= reached
                            ? Icon(
                                steps[i] == OrderStatus.cancelled
                                    ? Icons.close_rounded
                                    : Icons.check_rounded,
                                size: 12,
                                color: scheme.onPrimary,
                              )
                            : null,
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            color: i < reached
                                ? scheme.primary
                                : scheme.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caption(steps[i]),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: i <= reached ? null : palette.mutedText,
                          ),
                        ),
                        if (order.statusHistory[steps[i]] != null ||
                            (i == 0 && order.createdAt != null))
                          Text(
                            Formatters.dateTime(
                              order.statusHistory[steps[i]] ?? order.createdAt,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.mutedText,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
