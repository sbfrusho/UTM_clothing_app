/// Firestore collection names and field keys shared with the admin app.
/// Changing any value here is a data migration, not a refactor.
abstract final class FirestorePaths {
  static const users = 'users';
  static const products = 'products';
  static const categories = 'categories';
  static const banners = 'banners';
  static const orders = 'orders';
  static const orderItems = 'items';
  static const addresses = 'addresses';

  /// Legacy `wishlist/{email}` document with a `wishlist` array. Read once to
  /// migrate into [userWishlist]; never written by this app any more.
  static const legacyWishlist = 'wishlist';

  /// `users/{uid}/cart/{productId__size}`.
  static const userCart = 'cart';

  /// `users/{uid}/wishlist/{productId}`.
  static const userWishlist = 'wishlist';
}
