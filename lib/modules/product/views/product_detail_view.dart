import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../data/models/product_model.dart';
import '../view_models/product_detail_view_model.dart';

class ProductDetailView extends GetView<ProductDetailViewModel> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final product = controller.product.value;
      return Scaffold(
        appBar: AppBar(
          title: Text(product.name),
          actions: [
            IconButton(
              tooltip: controller.isWishlisted
                  ? 'Remove from wishlist'
                  : 'Add to wishlist',
              onPressed: controller.toggleWishlist,
              icon: Icon(
                controller.isWishlisted
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: product.images.isEmpty
                  ? const AppNetworkImage(null)
                  : PageView.builder(
                      itemCount: product.images.length,
                      onPageChanged: (i) => controller.imageIndex.value = i,
                      itemBuilder: (_, i) => AppNetworkImage(
                        product.images[i],
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
            if (product.images.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    product.images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: controller.imageIndex.value == i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: controller.imageIndex.value == i
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.price(product.price),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          Formatters.price(product.fullPrice),
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  _StockLabel(product: product),
                  if (product.sizes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Size', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.sizes
                          .map(
                            (size) => ChoiceChip(
                              label: Text(size),
                              selected: controller.selectedSize.value == size,
                              onSelected: (_) => controller.selectSize(size),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (product.deliveryTime.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text('Delivery: ${product.deliveryTime}'),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text('Description', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty
                        ? 'No description provided.'
                        : product.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                if (controller.canContactSupport) ...[
                  IconButton.outlined(
                    tooltip: 'Ask on WhatsApp',
                    onPressed: controller.contactSupport,
                    icon: const Icon(Icons.chat_outlined),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: product.inStock ? controller.addToCart : null,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text(
                      product.inStock ? 'Add to cart' : 'Out of stock',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _StockLabel extends StatelessWidget {
  const _StockLabel({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (product.stock) {
      0 => ('Out of stock', Colors.red.shade700),
      < 5 => ('Only ${product.stock} left', Colors.orange.shade800),
      _ => ('In stock', Colors.green.shade700),
    };
    return Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
