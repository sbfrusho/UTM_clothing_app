import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../wishlist/view_models/wishlist_view_model.dart';
import '../view_models/category_products_view_model.dart';

class CategoryProductsView extends GetView<CategoryProductsViewModel> {
  const CategoryProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = Get.find<WishlistViewModel>();
    return Scaffold(
      appBar: AppTopBar(
        title: controller.category.name,
        actions: [
          AppIconButton(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onPressed: () => Get.toNamed<void>(AppRoutes.search),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const ProductGridSkeleton();
        if (controller.error.value != null && controller.products.isEmpty) {
          return ErrorView(
            message: controller.error.value!,
            onRetry: controller.refreshProducts,
          );
        }
        if (controller.products.isEmpty) {
          return const EmptyView(
            title: 'Nothing here yet',
            message: 'New products in this category are on their way.',
            icon: Icons.checkroom_outlined,
          );
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.extentAfter < 400) controller.loadMore();
            return false;
          },
          child: RefreshIndicator(
            onRefresh: controller.refreshProducts,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverGrid.builder(
                    gridDelegate: productGridDelegate,
                    itemCount: controller.products.length,
                    itemBuilder: (context, index) {
                      final product = controller.products[index];
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
                SliverToBoxAdapter(
                  child: controller.isLoadingMore.value
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
    );
  }
}
