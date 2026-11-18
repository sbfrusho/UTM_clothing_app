import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../view_models/orders_view_model.dart';
import 'order_status_chip.dart';

class OrdersView extends GetView<OrdersViewModel> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const AppTopBar(title: 'My orders'),
      body: Obx(() {
        if (controller.isLoading.value) return const ListSkeleton();
        if (controller.error.value != null) {
          return ErrorView(
            message: controller.error.value!,
            onRetry: controller.load,
          );
        }
        if (controller.orders.isEmpty) {
          return const EmptyView(
            title: 'No orders yet',
            message: 'Orders you place will appear here with live status.',
            icon: Icons.receipt_long_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.orders.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                onTap: () =>
                    Get.toNamed(AppRoutes.orderDetail, arguments: order.id),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order #${order.shortId}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    OrderStatusChip(order.status),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${Formatters.dateTime(order.createdAt)} · '
                    '${Formatters.price(order.totalPrice)}'
                    '${order.isAwaitingPayment ? ' · Awaiting payment' : ''}',
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
