import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../cart/view_models/cart_view_model.dart';
import '../../cart/views/cart_view.dart';
import '../../catalog/views/categories_view.dart';
import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';
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
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentTab.value.index,
          children: _tabs,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentTab.value.index,
          onDestinationSelected: controller.select,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Categories',
            ),
            const NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Wishlist',
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
                child: const Icon(Icons.shopping_bag),
              ),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
