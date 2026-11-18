import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../view_models/wishlist_view_model.dart';

class WishlistView extends GetView<WishlistViewModel> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const AppTopBar.large(
        title: 'Saved',
        subtitle: 'Pieces you love, in one place',
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const ListSkeleton();
        }
        if (controller.error.value != null && controller.items.isEmpty) {
          return ErrorView(
            message: controller.error.value!,
            onRetry: controller.load,
          );
        }
        if (controller.items.isEmpty) {
          return const EmptyView(
            title: 'Nothing saved yet',
            message:
                'Tap the heart on any product to keep it here, on any device.',
            icon: Icons.favorite_border_rounded,
          );
        }
        // Read eagerly: rows are built lazily, outside Obx tracking.
        final liveById = {...controller.live};
        final liveLoaded = controller.liveLoaded.value;
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: controller.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.items[index];
              final live = liveById[item.productId];
              final price = live?.price ?? item.price;
              final soldOut = live != null && !live.inStock;
              final removed = liveLoaded && live == null;
              final dropped = live != null && live.price < item.price - 0.005;
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => controller.open(item),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        AppNetworkImage(
                          item.thumbnail,
                          width: 72,
                          height: 84,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: theme.textTheme.titleSmall,
                              ),
                              if (item.categoryName.isNotEmpty)
                                Text(
                                  item.categoryName,
                                  style: theme.textTheme.bodySmall,
                                ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    Formatters.price(price),
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  if (dropped)
                                    Text(
                                      'Price dropped',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: context.palette.success,
                                          ),
                                    ),
                                  if (soldOut || removed)
                                    Text(
                                      removed
                                          ? 'No longer available'
                                          : 'Sold out',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Remove from saved',
                              onPressed: () =>
                                  controller.remove(item.productId),
                              icon: const Icon(Icons.favorite_rounded),
                            ),
                            IconButton(
                              tooltip: 'Add to cart',
                              onPressed: soldOut || live == null
                                  ? null
                                  : () => controller.moveToCart(item),
                              icon: const Icon(Icons.add_shopping_cart_rounded),
                            ),
                          ],
                        ),
                      ],
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
