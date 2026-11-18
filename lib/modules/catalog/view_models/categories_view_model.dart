import 'package:get/get.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/catalog_repository.dart';

class CategoriesViewModel extends GetxController {
  CategoriesViewModel(this._catalog);

  final CatalogRepository _catalog;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      categories.assignAll(await _catalog.fetchCategories());
    } on AppException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
