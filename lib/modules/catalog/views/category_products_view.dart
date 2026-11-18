import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../wishlist/view_models/wishlist_view_model.dart';
import '../view_models/category_products_view_model.dart';

class CategoryProductsView extends GetView<CategoryProductsViewModel> {
  const CategoryProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = Get.find<WishlistViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text(controller.category.name)),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();
        if (controller.error.value != null && controller.products.isEmpty) {
          return ErrorView(
            message: controller.error.value!,
            onRetry: controller.refreshProducts,
          );
        }
        if (controller.products.isEmpty) {
          return const EmptyView(
            message: 'No products in this category yet.',
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
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                    itemCount: controller.products.length,
                    itemBuilder: (context, index) {
                      final product = controller.products[index];
                      return Obx(
                        () => ProductCard(
                          product: product,
                          isWishlisted: wishlist.isWishlisted(product.id),
                          onToggleWishlist: () => wishlist.toggle(product),
                          onTap: () => Get.toNamed(
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
                      : const SizedBox(height: 24),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
