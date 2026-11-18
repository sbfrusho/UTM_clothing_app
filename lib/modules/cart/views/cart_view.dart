import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/state_views.dart';
import '../../shell/view_models/shell_view_model.dart';
import '../view_models/cart_view_model.dart';

class CartView extends GetView<CartViewModel> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Obx(() {
        if (controller.isEmpty) {
          return EmptyView(
            message: 'Your cart is empty.',
            icon: Icons.shopping_bag_outlined,
            action: FilledButton.tonal(
              onPressed: () => Get.find<ShellViewModel>().goTo(ShellTab.home),
              child: const Text('Start shopping'),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return Dismissible(
              key: ValueKey(item.key),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => controller.remove(item.key),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete_outline),
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      AppNetworkImage(
                        item.imageUrl,
                        width: 72,
                        height: 72,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                            if (item.size.isNotEmpty)
                              Text(
                                'Size: ${item.size}',
                                style: theme.textTheme.bodySmall,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.price(item.total),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _QuantityStepper(
                        quantity: item.quantity,
                        onDecrement: () => controller.decrement(item.key),
                        onIncrement: () {
                          if (!controller.increment(item.key)) {
                            AppSnackbar.info(
                              'No more stock available.',
                              title: 'Stock limit',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: Obx(
        () => controller.isEmpty
            ? const SizedBox.shrink()
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total (${controller.itemCount} items)',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              Formatters.price(controller.total),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: FilledButton(
                          onPressed: () => Get.toNamed(AppRoutes.checkout),
                          child: const Text('Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: quantity == 1 ? 'Remove' : 'Decrease',
          onPressed: onDecrement,
          icon: Icon(quantity == 1 ? Icons.delete_outline : Icons.remove),
        ),
        Text('$quantity', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          tooltip: 'Increase',
          onPressed: onIncrement,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
