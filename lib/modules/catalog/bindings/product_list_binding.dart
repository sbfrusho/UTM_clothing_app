import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../view_models/product_list_view_model.dart';

/// Accepts a [CategoryModel], [ProductListArgs] or nothing (all products).
class ProductListBinding extends Bindings {
  @override
  void dependencies() {
    final arg = Get.arguments;
    final args = switch (arg) {
      final ProductListArgs a => a,
      final CategoryModel c => ProductListArgs.category(c),
      _ => ProductListArgs.all,
    };
    Get.lazyPut(() => ProductListViewModel(Get.find(), args));
  }
}
