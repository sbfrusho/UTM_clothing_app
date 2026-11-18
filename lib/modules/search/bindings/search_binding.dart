import 'package:get/get.dart';

import '../view_models/search_view_model.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    final initial = Get.arguments is String ? Get.arguments as String : '';
    Get.lazyPut(() => SearchViewModel(Get.find(), initial));
  }
}
