import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/state_views.dart';
import '../../shell/view_models/shell_view_model.dart';
import '../view_models/cart_view_model.dart';

class CartView extends GetView<CartViewModel> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(
      () => Scaffold(
        appBar: AppTopBar.large(
          title: 'Cart',
          subtitle: controller.isEmpty
              ? null
              : '${controller.itemCount} '
                    '${controller.itemCount == 1 ? 'item' : 'items'}',
        ),
        body: controller.isEmpty
            ? EmptyView(
                title: 'Your cart is empty',
                message: 'Pieces you add will wait for you here.',
                icon: Icons.shopping_bag_outlined,
                action: SizedBox(
                  width: 200,
                  child: FilledButton(
                    onPressed: () =>
                        Get.find<ShellViewModel>().goTo(ShellTab.home),
                    child: const Text('Start shopping'),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: controller.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            AppNetworkImage(
                              item.imageUrl,
                              width: 84,
                              height: 96,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            const SizedBox(width: 14),
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
                                      'Size ${item.size}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          Formatters.price(item.total),
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                      _QuantityStepper(
                                        quantity: item.quantity,
                                        onDecrement: () =>
                                            controller.decrement(item.key),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        bottomNavigationBar: controller.isEmpty
            ? null
            : _CheckoutBar(total: controller.total),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subtotal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.palette.mutedText,
                    ),
                  ),
                  Text(
                    Formatters.price(total),
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 180,
              child: FilledButton(
                onPressed: () => Get.toNamed<void>(AppRoutes.checkout),
                child: const Text('Checkout'),
              ),
            ),
          ],
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
    final scheme = Theme.of(context).colorScheme;
    Widget button(IconData icon, String tip, VoidCallback onTap) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Tooltip(
        message: tip,
        child: SizedBox.square(dimension: 34, child: Icon(icon, size: 18)),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            quantity == 1 ? 'Remove' : 'Decrease',
            onDecrement,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          button(Icons.add_rounded, 'Increase', onIncrement),
        ],
      ),
    );
  }
}
