import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/state_views.dart';
import '../view_models/search_view_model.dart';

class SearchView extends GetView<SearchViewModel> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller.textController,
          autofocus: controller.query.value.isEmpty,
          onChanged: controller.onQueryChanged,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search products',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            filled: false,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.results.isEmpty) {
          return const LoadingView();
        }
        if (controller.error.value != null) {
          return ErrorView(message: controller.error.value!);
        }
        if (controller.query.value.trim().length < 2) {
          return const EmptyView(
            message: 'Type at least 2 letters to search.',
            icon: Icons.search,
          );
        }
        if (controller.results.isEmpty) {
          return EmptyView(
            message: 'No results for "${controller.query.value.trim()}".',
            icon: Icons.search_off,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.results.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final product = controller.results[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: AppNetworkImage(
                  product.thumbnail,
                  width: 56,
                  height: 56,
                  borderRadius: BorderRadius.circular(8),
                ),
                title: Text(product.name),
                subtitle: Text(
                  '${product.categoryName} · ${Formatters.price(product.price)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Get.toNamed(AppRoutes.productDetail, arguments: product),
              ),
            );
          },
        );
      }),
    );
  }
}
