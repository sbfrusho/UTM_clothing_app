import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import 'product_card.dart';

/// Horizontally scrolling row of [ProductCard]s (home "On sale",
/// "You may also like").
class ProductRail extends StatelessWidget {
  const ProductRail({
    super.key,
    required this.products,
    required this.onTap,
    required this.wishlistedIds,
    required this.onToggleWishlist,
    this.cardWidth = 160,
  });

  final List<ProductModel> products;
  final void Function(ProductModel) onTap;

  /// Computed by the caller inside an `Obx`: cards are built lazily,
  /// outside its tracking, so they can't read reactive state themselves.
  final Set<String> wishlistedIds;
  final void Function(ProductModel) onToggleWishlist;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    // Card = square-ish image + two text lines; scale with text size.
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final height = cardWidth / 0.6 * 0.92 + (textScale - 1) * 40;
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final p = products[i];
          return ProductCard(
            product: p,
            width: cardWidth,
            isWishlisted: wishlistedIds.contains(p.id),
            onToggleWishlist: () => onToggleWishlist(p),
            onTap: () => onTap(p),
          );
        },
      ),
    );
  }
}
