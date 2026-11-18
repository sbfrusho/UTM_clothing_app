import 'package:get/get.dart';

import '../view_models/legal_view_model.dart';

class LegalBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(LegalViewModel.new);
}
