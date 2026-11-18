import 'package:get/get.dart';

import '../../../data/models/product_model.dart';
import '../view_models/product_detail_view_model.dart';

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() {
    final product = Get.arguments as ProductModel;
    Get.lazyPut(
      () => ProductDetailViewModel(Get.find(), Get.find(), Get.find(), product),
    );
  }
}
