import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../view_models/category_products_view_model.dart';

class CategoryProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () =>
          CategoryProductsViewModel(Get.find(), Get.arguments as CategoryModel),
    );
  }
}
