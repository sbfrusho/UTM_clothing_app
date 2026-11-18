import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'app_network_image.dart';

/// Product tile: image on a soft cream card, name and price beneath.
/// Stateless: wishlist state and actions come from the owning view.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isWishlisted = false,
    this.onToggleWishlist,
    this.width,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final bool isWishlisted;
  final VoidCallback? onToggleWishlist;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return SizedBox(
      width: width,
      child: Semantics(
        button: true,
        label: '${product.name}, ${Formatters.price(product.price)}',
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: palette.imageBackground,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: AppNetworkImage(
                        product.thumbnail,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    if (product.hasDiscount || !product.inStock)
                      Positioned(
                        left: 10,
                        top: 10,
                        child: _Tag(
                          !product.inStock
                              ? 'Sold out'
                              : '-${product.discountPercent}%',
                          dark: !product.inStock,
                        ),
                      ),
                    if (onToggleWishlist != null)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: _HeartButton(
                          active: isWishlisted,
                          onPressed: onToggleWishlist!,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              if (product.categoryName.isNotEmpty)
                Text(
                  product.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    Formatters.price(product.price),
                    style: theme.textTheme.titleMedium,
                  ),
                  if (product.hasDiscount) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        Formatters.price(product.fullPrice),
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Tooltip(
          message: active ? 'Remove from wishlist' : 'Add to wishlist',
          child: SizedBox.square(
            dimension: 36,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, a) =>
                  ScaleTransition(scale: a, child: child),
              child: Icon(
                active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(active),
                size: 19,
                color: scheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {this.dark = false});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: dark ? scheme.inverseSurface : palette.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: dark ? scheme.onInverseSurface : scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
