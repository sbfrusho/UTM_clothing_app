import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/brand/app_logo.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../cart/view_models/cart_view_model.dart';
import '../../shell/view_models/shell_view_model.dart';
import '../../wishlist/view_models/wishlist_view_model.dart';
import '../view_models/home_view_model.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_strip.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = Get.find<WishlistViewModel>();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.error.value != null && controller.categories.isEmpty) {
            return ErrorView(
              message: controller.error.value!,
              onRetry: controller.load,
            );
          }
          final loading =
              controller.isLoading.value && controller.categories.isEmpty;
          return RefreshIndicator(
            onRefresh: controller.load,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _HomeHeader()),
                const SliverToBoxAdapter(child: _SearchPill()),
                if (loading)
                  const SliverToBoxAdapter(child: _HomeSkeleton())
                else ...[
                  if (controller.banners.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 20),
                      sliver: SliverToBoxAdapter(
                        child: BannerCarousel(
                          urls: controller.banners.toList(),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Categories',
                      onAction: () =>
                          Get.find<ShellViewModel>().goTo(ShellTab.categories),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: CategoryStrip(
                      categories: controller.categories.toList(),
                      onTap: (c) => Get.toNamed<void>(
                        AppRoutes.categoryProducts,
                        arguments: c,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'New arrivals',
                      subtitle: 'Fresh in this week',
                    ),
                  ),
                  if (controller.latestProducts.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: EmptyView(
                          message: 'New products will appear here.',
                          icon: Icons.checkroom_outlined,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      sliver: SliverGrid.builder(
                        gridDelegate: productGridDelegate,
                        itemCount: controller.latestProducts.length,
                        itemBuilder: (context, index) {
                          final product = controller.latestProducts[index];
                          return Obx(
                            () => ProductCard(
                              product: product,
                              isWishlisted: wishlist.isWishlisted(product.id),
                              onToggleWishlist: () => wishlist.toggle(product),
                              onTap: () => Get.toNamed<void>(
                                AppRoutes.productDetail,
                                arguments: product,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _HomeHeader extends GetView<HomeViewModel> {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = Get.find<CartViewModel>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          const AppLogo(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.greeting,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.palette.mutedText,
                    ),
                  ),
                  Text(
                    controller.firstName.value.isEmpty
                        ? 'Welcome back'
                        : controller.firstName.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => AppIconButton(
              icon: Icons.shopping_bag_outlined,
              tooltip: 'Cart',
              badgeCount: cart.itemCount,
              onPressed: () => Get.find<ShellViewModel>().goTo(ShellTab.cart),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Material(
        color: theme.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => Get.toNamed<void>(AppRoutes.search),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: palette.mutedText),
                const SizedBox(width: 12),
                Text(
                  'Search shirts, caps, mugs…',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 8,
            child: Skeleton(radius: AppRadius.xl),
          ),
          SizedBox(height: 28),
          Skeleton(height: 22, width: 140, radius: 6),
          SizedBox(height: 16),
          // Clipped so it never overflows on narrow phones.
          SizedBox(
            height: 72,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Skeleton(width: 72, height: 72, radius: 36),
                    SizedBox(width: 16),
                    Skeleton(width: 72, height: 72, radius: 36),
                    SizedBox(width: 16),
                    Skeleton(width: 72, height: 72, radius: 36),
                    SizedBox(width: 16),
                    Skeleton(width: 72, height: 72, radius: 36),
                    SizedBox(width: 16),
                    Skeleton(width: 72, height: 72, radius: 36),
                    SizedBox(width: 16),
                    Skeleton(width: 72, height: 72, radius: 36),
                    SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
