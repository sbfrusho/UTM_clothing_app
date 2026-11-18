import 'package:get/get.dart';

enum ShellTab { home, categories, wishlist, cart, profile }

class ShellViewModel extends GetxController {
  final Rx<ShellTab> currentTab = ShellTab.home.obs;

  void select(int index) => currentTab.value = ShellTab.values[index];

  void goTo(ShellTab tab) => currentTab.value = tab;
}
