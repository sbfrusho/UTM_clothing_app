import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../data/models/product_model.dart';
import '../view_models/product_detail_view_model.dart';

class ProductDetailView extends GetView<ProductDetailViewModel> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Obx(() {
      final product = controller.product.value;
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 5,
                    child: ColoredBox(
                      color: palette.imageBackground,
                      child: product.images.isEmpty
                          ? const AppNetworkImage(null)
                          : PageView.builder(
                              itemCount: product.images.length,
                              onPageChanged: (i) =>
                                  controller.imageIndex.value = i,
                              itemBuilder: (_, i) =>
                                  AppNetworkImage(product.images[i]),
                            ),
                    ),
                  ),
                  // Floating controls over the image instead of a bar.
                  Positioned(
                    left: 16,
                    right: 16,
                    top: MediaQuery.paddingOf(context).top + 8,
                    child: Row(
                      children: [
                        AppIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          tooltip: 'Back',
                          onPressed: () => Get.back<void>(),
                        ),
                        const Spacer(),
                        AppIconButton(
                          icon: controller.isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          tooltip: controller.isWishlisted
                              ? 'Remove from wishlist'
                              : 'Add to wishlist',
                          onPressed: controller.toggleWishlist,
                        ),
                      ],
                    ),
                  ),
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: controller.imageIndex.value == i ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: controller.imageIndex.value == i
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              sliver: SliverList.list(
                children: [
                  if (product.categoryName.isNotEmpty)
                    Text(
                      product.categoryName.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.4,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(product.name, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.price(product.price),
                        style: theme.textTheme.titleLarge,
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 10),
                        Text(
                          Formatters.price(product.fullPrice),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: palette.mutedText,
                          ),
                        ),
                      ],
                      const Spacer(),
                      _StockLabel(product: product),
                    ],
                  ),
                  if (product.sizes.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text('Select size', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: product.sizes
                          .map(
                            (size) => ChoiceChip(
                              label: SizedBox(
                                width: 32,
                                child: Text(size, textAlign: TextAlign.center),
                              ),
                              selected: controller.selectedSize.value == size,
                              onSelected: (_) => controller.selectSize(size),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 28),
                  _InfoTile(
                    icon: Icons.local_shipping_outlined,
                    title: 'Delivery',
                    value: product.deliveryTime.isEmpty
                        ? 'Standard delivery'
                        : product.deliveryTime,
                  ),
                  const SizedBox(height: 28),
                  Text('Details', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty
                        ? 'No description provided.'
                        : product.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: palette.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  if (controller.canContactSupport) ...[
                    AppIconButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      size: 54,
                      tooltip: 'Ask on WhatsApp',
                      onPressed: controller.contactSupport,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: product.inStock ? controller.addToCart : null,
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: Text(product.inStock ? 'Add to cart' : 'Sold out'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(value, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StockLabel extends StatelessWidget {
  const _StockLabel({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final (text, color) = switch (product.stock) {
      0 => ('Sold out', scheme.error),
      < 5 => ('Only ${product.stock} left', palette.warning),
      _ => ('In stock', palette.success),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
