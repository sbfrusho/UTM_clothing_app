import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:your_shop/core/utils/app_logger.dart';
class QuantityChecker {
  
Future<bool> updateProductQuantity(String productId, int orderedQuantity) async {
    AppLogger.debug('Updating product $productId quantity to $orderedQuantity');
    try {
      DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(productId);
      DocumentSnapshot productDoc = await productRef.get();
      if (productDoc.exists) {
        int currentQuantity = int.parse(productDoc['quantity']);
        AppLogger.debug(currentQuantity);
        if (currentQuantity == 0) {
          AppLogger.debug('Product $productId is unavailable');
          return false; // Product is unavailable
        }
        int newQuantity = currentQuantity - orderedQuantity;
        if (newQuantity < 0) {
          AppLogger.debug('Insufficient quantity for product $productId');
          return false; // Not enough quantity
        }
        String update = newQuantity.toString();
        await productRef.update({'quantity': update});
        AppLogger.debug('Updated product $productId quantity to $update');
        return true; // Quantity updated successfully
      } else {
        AppLogger.debug('Product $productId does not exist');
        return false; // Product does not exist
      }
    } catch (error) {
      AppLogger.debug('Error updating product quantity: $error');
      return false; // Error occurred
    }
  }
}
