import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/state_views.dart';
import '../view_models/order_detail_view_model.dart';
import 'order_status_chip.dart';

class OrderDetailView extends GetView<OrderDetailViewModel> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
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
                width: 120,
                child: Text(label, style: theme.textTheme.bodySmall),
              ),
              Expanded(child: Text(value)),
            ],
          ),
        );
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Order #${order.id.substring(0, 6).toUpperCase()}',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        OrderStatusChip(order.status),
                      ],
                    ),
                    const Divider(height: 24),
                    row('Placed on', Formatters.dateTime(order.createdAt)),
                    row('Delivery date', order.deliveryDate),
                    row(
                      'Payment',
                      '${order.paymentMethod} (${order.paymentStatus})',
                    ),
                    row('Name', order.customerName),
                    row('Phone', order.customerPhone),
                    row('Address', order.customerAddress),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Items', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Card(
                child: ListTile(
                  leading: item.imageUrl.isEmpty
                      ? const Icon(Icons.checkroom_outlined)
                      : AppNetworkImage(
                          item.imageUrl,
                          width: 48,
                          height: 48,
                          borderRadius: BorderRadius.circular(8),
                        ),
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.quantity} × ${Formatters.price(item.unitPrice)}'
                    '${item.size.isEmpty ? '' : ' · Size ${item.size}'}',
                  ),
                  trailing: Text(Formatters.price(item.total)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total ${Formatters.price(order.totalPrice)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
