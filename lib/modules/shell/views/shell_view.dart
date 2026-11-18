import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../cart/view_models/cart_view_model.dart';
import '../../cart/views/cart_view.dart';
import '../../catalog/views/categories_view.dart';
import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';
import '../../wishlist/view_models/wishlist_view_model.dart';
import '../../wishlist/views/wishlist_view.dart';
import '../view_models/shell_view_model.dart';

class ShellView extends GetView<ShellViewModel> {
  const ShellView({super.key});

  static const _tabs = <Widget>[
    HomeView(),
    CategoriesView(),
    WishlistView(),
    CartView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartViewModel>();
    final wishlist = Get.find<WishlistViewModel>();
    final scheme = Theme.of(context).colorScheme;
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentTab.value.index,
          children: _tabs,
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          child: NavigationBar(
            selectedIndex: controller.currentTab.value.index,
            onDestinationSelected: controller.select,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: 'Home'.tr,
              ),
              NavigationDestination(
                icon: const Icon(Icons.grid_view_outlined),
                selectedIcon: const Icon(Icons.grid_view_rounded),
                label: 'Shop'.tr,
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: wishlist.count > 0,
                  label: Text('${wishlist.count}'),
                  child: const Icon(Icons.favorite_border_rounded),
                ),
                selectedIcon: Badge(
                  isLabelVisible: wishlist.count > 0,
                  label: Text('${wishlist.count}'),
                  child: const Icon(Icons.favorite_rounded),
                ),
                label: 'Saved'.tr,
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: cart.itemCount > 0,
                  label: Text('${cart.itemCount}'),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: cart.itemCount > 0,
                  label: Text('${cart.itemCount}'),
                  child: const Icon(Icons.shopping_bag_rounded),
                ),
                label: 'Cart'.tr,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: 'Profile'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
