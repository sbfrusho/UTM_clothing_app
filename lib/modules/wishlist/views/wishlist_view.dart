import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/state_views.dart';
import '../view_models/wishlist_view_model.dart';

class WishlistView extends GetView<WishlistViewModel> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const LoadingView();
        }
        if (controller.error.value != null && controller.items.isEmpty) {
          return ErrorView(
            message: controller.error.value!,
            onRetry: controller.load,
          );
        }
        if (controller.items.isEmpty) {
          return const EmptyView(
            message: 'Tap the heart on a product to save it here.',
            icon: Icons.favorite_border,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: controller.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  onTap: () => controller.open(item),
                  leading: AppNetworkImage(
                    item.thumbnail,
                    width: 56,
                    height: 56,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    Formatters.price(item.price),
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  trailing: IconButton(
                    tooltip: 'Remove',
                    onPressed: () => controller.remove(item.productId),
                    icon: const Icon(Icons.favorite),
                    color: theme.colorScheme.primary,
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
