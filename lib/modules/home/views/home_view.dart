import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/state_views.dart';
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
      appBar: AppBar(title: const Text(AppConfig.appName)),
      body: Obx(() {
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return const LoadingView();
        }
        if (controller.error.value != null && controller.categories.isEmpty) {
          return ErrorView(
            message: controller.error.value!,
            onRetry: controller.load,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onSubmitted: (q) {
                    if (q.trim().isNotEmpty) {
                      Get.toNamed(AppRoutes.search, arguments: q.trim());
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search products',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              BannerCarousel(urls: controller.banners.toList()),
              SectionHeader(
                title: 'Categories',
                subtitle: 'Explore the collection',
                onAction: () =>
                    Get.find<ShellViewModel>().goTo(ShellTab.categories),
              ),
              CategoryStrip(
                categories: controller.categories.toList(),
                onTap: (c) =>
                    Get.toNamed(AppRoutes.categoryProducts, arguments: c),
              ),
              const SectionHeader(
                title: 'New arrivals',
                subtitle: 'Fresh in the shop',
              ),
              SizedBox(
                height: 270,
                child: controller.latestProducts.isEmpty
                    ? const EmptyView(message: 'No products yet.')
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.latestProducts.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final product = controller.latestProducts[index];
                          return Obx(
                            () => ProductCard(
                              width: 170,
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
            ],
          ),
        );
      }),
    );
  }
}
