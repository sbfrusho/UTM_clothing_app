import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../utils/formatters.dart';
import 'app_network_image.dart';

/// Grid/list card for a product. Stateless: wishlist state and actions are
/// passed in by the view that owns the view model.
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
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(product.thumbnail),
                    if (product.hasDiscount)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _Badge(
                          '-${product.discountPercent}%',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    if (!product.inStock)
                      const Positioned(
                        left: 8,
                        bottom: 8,
                        child: _Badge('Out of stock', color: Colors.black87),
                      ),
                    if (onToggleWishlist != null)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton.filledTonal(
                          visualDensity: VisualDensity.compact,
                          tooltip: isWishlisted
                              ? 'Remove from wishlist'
                              : 'Add to wishlist',
                          onPressed: onToggleWishlist,
                          icon: Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isWishlisted
                                ? theme.colorScheme.primary
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          Formatters.price(product.price),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
