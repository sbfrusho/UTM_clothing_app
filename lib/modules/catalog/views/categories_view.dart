import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/state_views.dart';
import '../view_models/categories_view_model.dart';

class CategoriesView extends GetView<CategoriesViewModel> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Obx(() {
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return const LoadingView();
        }
        if (controller.error.value != null) {
          return ErrorView(
            message: controller.error.value!,
            onRetry: controller.load,
          );
        }
        if (controller.categories.isEmpty) {
          return const EmptyView(message: 'No categories yet.');
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Get.toNamed(
                    AppRoutes.categoryProducts,
                    arguments: category,
                  ),
                  child: Column(
                    children: [
                      Expanded(child: AppNetworkImage(category.imageUrl)),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          category.name,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
