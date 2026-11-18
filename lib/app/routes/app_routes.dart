abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail = '/verify-email';
  static const appLock = '/app-lock';

  /// Bottom-navigation shell: home, categories, wishlist, cart, profile.
  static const shell = '/main';

  /// Product grid: a category, everything, or a preset filter.
  static const productList = '/products';
  static const productDetail = '/product';
  static const productGallery = '/product/gallery';
  static const search = '/search';
  static const checkout = '/checkout';
  static const orderSuccess = '/order-success';
  static const orders = '/orders';
  static const orderDetail = '/orders/detail';
  static const editProfile = '/profile/edit';
  static const deleteAccount = '/profile/delete';

  /// Privacy policy or terms; pass a `LegalPage`. Public (linked from
  /// registration).
  static const legal = '/legal';

  /// Address book; pass `AddressBookArgs.select` to pick one.
  static const address = '/profile/address';
  static const addressForm = '/profile/address/edit';
}
