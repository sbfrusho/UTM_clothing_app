import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../view_models/search_view_model.dart';

class SearchView extends GetView<SearchViewModel> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppTopBar(
        titleWidget: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextField(
            controller: controller.textController,
            autofocus: controller.query.value.isEmpty,
            onChanged: controller.onQueryChanged,
            textInputAction: TextInputAction.search,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Search products',
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              suffixIcon: Obx(
                () => controller.query.value.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          controller.textController.clear();
                          controller.onQueryChanged('');
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.results.isEmpty) {
          return const ListSkeleton();
        }
        if (controller.error.value != null) {
          return ErrorView(message: controller.error.value!);
        }
        if (controller.query.value.trim().length < 2) {
          return const EmptyView(
            title: 'Find something you love',
            message: 'Type at least 2 letters to search the shop.',
            icon: Icons.search_rounded,
          );
        }
        if (controller.results.isEmpty) {
          return EmptyView(
            title: 'No matches',
            message:
                'Nothing found for "${controller.query.value.trim()}". '
                'Try a different word.',
            icon: Icons.search_off_rounded,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: controller.results.length,
          separatorBuilder: (_, _) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final product = controller.results[index];
            return InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => Get.toNamed<void>(
                AppRoutes.productDetail,
                arguments: product,
              ),
              child: Row(
                children: [
                  AppNetworkImage(
                    product.thumbnail,
                    width: 64,
                    height: 64,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: theme.textTheme.titleSmall),
                        Text(
                          product.categoryName,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Formatters.price(product.price),
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
