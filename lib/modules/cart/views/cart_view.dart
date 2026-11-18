import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/cart_item_model.dart';
import '../../shell/view_models/shell_view_model.dart';
import '../view_models/cart_view_model.dart';

class CartView extends GetView<CartViewModel> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppTopBar.large(
          title: 'Cart',
          subtitle: controller.isEmpty
              ? null
              : '${controller.itemCount} '
                    '${controller.itemCount == 1 ? 'item' : 'items'}',
        ),
        body: controller.isLoading.value && controller.isEmpty
            ? const ListSkeleton()
            : controller.isEmpty
            ? EmptyView(
                title: 'Your cart is empty',
                message:
                    'Pieces you add will wait for you here, on any device.',
                icon: Icons.shopping_bag_outlined,
                action: SizedBox(
                  width: 200,
                  child: FilledButton(
                    onPressed: () =>
                        Get.find<ShellViewModel>().goTo(ShellTab.home),
                    child: Text('Start shopping'.tr),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    controller.refreshFromCatalog(fromServer: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    if (controller.notices.isNotEmpty)
                      _NoticeBanner(
                        notices: controller.notices.toList(),
                        onClose: controller.dismissNotices,
                      ),
                    for (final item in controller.items) ...[
                      _CartLine(item: item),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
        bottomNavigationBar: controller.isEmpty
            ? null
            : controller.hasUnavailable
            ? _UnavailableBar(onRemove: controller.removeUnavailable)
            : _CheckoutBar(total: controller.total),
      ),
    );
  }
}

class _CartLine extends GetView<CartViewModel> {
  const _CartLine({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final available = item.isAvailable;
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
              Opacity(
                opacity: available ? 1 : 0.45,
                child: AppNetworkImage(
                  item.imageUrl,
                  width: 84,
                  height: 96,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: available ? null : palette.mutedText,
                      ),
                    ),
                    if (item.size.isNotEmpty)
                      Text(
                        'Size ${item.size}',
                        style: theme.textTheme.bodySmall,
                      ),
                    if (available &&
                        item.maxQuantity > 0 &&
                        item.maxQuantity < 5)
                      Text(
                        'Only ${item.maxQuantity} left',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: palette.warning,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: available
                              ? Text(
                                  Formatters.price(item.total),
                                  style: theme.textTheme.titleMedium,
                                )
                              : Text(
                                  'Unavailable',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                        ),
                        if (available)
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
                          )
                        else
                          TextButton(
                            onPressed: () => controller.remove(item.key),
                            child: Text('Remove'.tr),
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
  }
}

/// What changed since the user last saw the cart.
class _NoticeBanner extends StatelessWidget {
  const _NoticeBanner({required this.notices, required this.onClose});

  final List<String> notices;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      decoration: BoxDecoration(
        color: palette.accent.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline_rounded, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your cart was updated',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                for (final n in notices)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(n, style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Dismiss'.tr,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _UnavailableBar extends StatelessWidget {
  const _UnavailableBar({required this.onRemove});

  final VoidCallback onRemove;

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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Some items are no longer available.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: onRemove,
              child: Text('Remove unavailable items'.tr),
            ),
          ],
        ),
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
                child: Text('Checkout'.tr),
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
