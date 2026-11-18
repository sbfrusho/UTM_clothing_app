import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_palette.dart';
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
            onSubmitted: controller.submit,
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
                        onPressed: controller.clear,
                      ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (!controller.hasQuery) return const _Suggestions();
        if (controller.isLoading.value && controller.results.isEmpty) {
          return const ListSkeleton();
        }
        if (controller.error.value != null) {
          return ErrorView(message: controller.error.value!);
        }
        if (controller.results.isEmpty) {
          return EmptyView(
            title: 'No matches',
            message:
                'Nothing found for "${controller.query.value.trim()}". '
                'Check the spelling or try a broader word.',
            icon: Icons.search_off_rounded,
          );
        }
        final count = controller.results.length;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: count + 1,
          separatorBuilder: (_, i) =>
              i == 0 ? const SizedBox(height: 8) : const Divider(height: 24),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(
                '$count ${count == 1 ? 'result' : 'results'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.palette.mutedText,
                ),
              );
            }
            final product = controller.results[index - 1];
            return InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () {
                controller.onResultOpened();
                Get.toNamed<void>(AppRoutes.productDetail, arguments: product);
              },
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
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.inStock
                              ? product.categoryName
                              : '${product.categoryName} · Sold out',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.palette.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.price(product.price),
                        style: theme.textTheme.titleSmall,
                      ),
                      if (product.hasDiscount)
                        Text(
                          Formatters.price(product.fullPrice),
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: context.palette.mutedText,
                          ),
                        ),
                    ],
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

/// Shown before typing: recent searches and category shortcuts.
class _Suggestions extends GetView<SearchViewModel> {
  const _Suggestions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final recent = controller.recent;
      final categories = controller.categories;
      if (recent.isEmpty && categories.isEmpty) {
        return const EmptyView(
          title: 'Find something you love',
          message: 'Search by product name or category.',
          icon: Icons.search_rounded,
        );
      }
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (recent.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text('Recent', style: theme.textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: controller.clearRecent,
                  child: const Text('Clear'),
                ),
              ],
            ),
            for (final term in recent)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history_rounded),
                title: Text(term),
                onTap: () => controller.submit(term),
                trailing: IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => controller.removeRecent(term),
                ),
              ),
            const SizedBox(height: 16),
          ],
          if (categories.isNotEmpty) ...[
            Text('Browse categories', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categories)
                  ActionChip(
                    label: Text(c.name),
                    onPressed: () =>
                        Get.toNamed<void>(AppRoutes.productList, arguments: c),
                  ),
              ],
            ),
          ],
        ],
      );
    });
  }
}
