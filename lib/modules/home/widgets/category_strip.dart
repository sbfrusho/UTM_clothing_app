import 'package:flutter/material.dart';

import '../../../core/widgets/app_network_image.dart';
import '../../../data/models/category_model.dart';

class CategoryStrip extends StatelessWidget {
  const CategoryStrip({
    super.key,
    required this.categories,
    required this.onTap,
  });

  final List<CategoryModel> categories;
  final ValueChanged<CategoryModel> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onTap(category),
            child: SizedBox(
              width: 76,
              child: Column(
                children: [
                  AppNetworkImage(
                    category.imageUrl,
                    width: 72,
                    height: 72,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
