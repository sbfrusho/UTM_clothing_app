import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/catalog/product_filter.dart';
import '../../wishlist/view_models/wishlist_view_model.dart';
import '../view_models/product_list_view_model.dart';
import 'product_filter_sheet.dart';

class ProductListView extends GetView<ProductListViewModel> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = Get.find<WishlistViewModel>();
    return Scaffold(
      appBar: AppTopBar(
        title: controller.args.title,
        actions: [
          AppIconButton(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onPressed: () => Get.toNamed<void>(AppRoutes.search),
          ),
        ],
      ),
      body: Column(
        children: [
          const _Toolbar(),
          Expanded(
            child: Obx(() {
              final firstLoad =
                  controller.isLoading.value && controller.visible.isEmpty;
              if (firstLoad) return const ProductGridSkeleton();
              if (controller.error.value != null &&
                  controller.visible.isEmpty) {
                return ErrorView(
                  message: controller.error.value!,
                  onRetry: controller.refreshProducts,
                );
              }
              if (controller.visible.isEmpty) {
                return controller.filter.value.hasRefinements
                    ? EmptyView(
                        title: 'No matches',
                        message: 'No products match these filters.',
                        icon: Icons.filter_alt_off_outlined,
                        action: OutlinedButton(
                          onPressed: controller.clearFilters,
                          child: const Text('Clear filters'),
                        ),
                      )
                    : const EmptyView(
                        title: 'Nothing here yet',
                        message: 'New products are on their way.',
                        icon: Icons.checkroom_outlined,
                      );
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.extentAfter < 600) controller.loadMore();
                  return false;
                },
                child: RefreshIndicator(
                  onRefresh: controller.refreshProducts,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        sliver: SliverGrid.builder(
                          gridDelegate: productGridDelegate,
                          itemCount: controller.visible.length,
                          itemBuilder: (context, index) {
                            final product = controller.visible[index];
                            return Obx(
                              () => ProductCard(
                                product: product,
                                isWishlisted: wishlist.isWishlisted(product.id),
                                onToggleWishlist: () =>
                                    wishlist.toggle(product),
                                onTap: () => Get.toNamed<void>(
                                  AppRoutes.productDetail,
                                  arguments: product,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: controller.hasMore
                            ? const Padding(
                                padding: EdgeInsets.all(24),
                                child: LoadingView(),
                              )
                            : const SizedBox(height: 32),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Result count, sort menu and filter button.
class _Toolbar extends GetView<ProductListViewModel> {
  const _Toolbar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Obx(() {
        final filter = controller.filter.value;
        final count = controller.totalCount.value;
        return Row(
          children: [
            Expanded(
              child: Text(
                controller.isLoading.value && count == 0
                    ? ' '
                    : '$count ${count == 1 ? 'item' : 'items'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palette.mutedText,
                ),
              ),
            ),
            MenuAnchor(
              alignmentOffset: const Offset(-120, 4),
              menuChildren: [
                for (final sort in ProductSort.values)
                  MenuItemButton(
                    leadingIcon: Icon(
                      sort == filter.sort
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 20,
                    ),
                    onPressed: () => controller.setSort(sort),
                    child: Text(sort.label),
                  ),
              ],
              builder: (context, menu, _) => _ToolButton(
                icon: Icons.swap_vert_rounded,
                label: 'Sort',
                onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              ),
            ),
            const SizedBox(width: 8),
            _ToolButton(
              icon: Icons.tune_rounded,
              label: 'Filter',
              badge: filter.activeCount,
              onPressed: () => ProductFilterSheet.show(controller),
            ),
          ],
        );
      }),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = badge > 0;
    return Material(
      color: active ? scheme.primary : scheme.surfaceContainerLowest,
      shape: StadiumBorder(
        side: BorderSide(
          color: active ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? scheme.onPrimary : scheme.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                active ? '$label · $badge' : label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: active ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
