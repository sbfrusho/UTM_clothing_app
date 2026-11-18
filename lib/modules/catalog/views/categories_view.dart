import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../view_models/categories_view_model.dart';

class CategoriesView extends GetView<CategoriesViewModel> {
  const CategoriesView({super.key});

  static const _grid = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 240,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 0.85,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const AppTopBar.large(
        title: 'Shop',
        subtitle: 'Browse by category',
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: _grid,
            itemCount: 6,
            itemBuilder: (_, _) => const Skeleton(radius: AppRadius.lg),
          );
        }
        if (controller.error.value != null) {
          return ErrorView(
            message: controller.error.value!,
            onRetry: controller.load,
          );
        }
        if (controller.categories.isEmpty) {
          return const EmptyView(
            message: 'Categories will appear here.',
            icon: Icons.grid_view_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            gridDelegate: _grid,
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => Get.toNamed<void>(
                  AppRoutes.categoryProducts,
                  arguments: category,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      category.imageUrl,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    // Soft gradient so the label stays legible on any photo.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                          stops: const [0.5, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
