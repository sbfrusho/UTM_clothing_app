import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../view_models/orders_view_model.dart';
import 'order_status_chip.dart';

class OrdersView extends GetView<OrdersViewModel> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();
        if (controller.error.value != null) {
          return ErrorView(
            message: controller.error.value!,
            onRetry: controller.load,
          );
        }
        if (controller.orders.isEmpty) {
          return const EmptyView(
            message: 'You have not placed any orders yet.',
            icon: Icons.receipt_long_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
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
                          'Order #${order.id.substring(0, 6).toUpperCase()}',
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
                      '${Formatters.price(order.totalPrice)}',
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
