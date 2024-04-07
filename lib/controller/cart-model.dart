import 'package:flutter/material.dart';

class Cart{

  late final int? id;
  final String? productId;
  final String? productName;
  final int? initialPrice;
  final int? productPrice;
  final ValueNotifier<int> quantity;
  final String? unitTag;
  final String? productImage;

  Cart({
    required this.id,
    required this.productId,
    required this.productName,
    required this.initialPrice,
    required this.productPrice,
    required this.quantity,
    required this.unitTag,
    required this.productImage,
  });

  Cart.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        productId = map['productId'],
        productName = map['productName'],
        initialPrice = map['initialPrice'],
        productPrice = map['productPrice'],
        quantity = ValueNotifier<int>(map['quantity']),
        unitTag = map['unitTag'],
        productImage = map['productImage'];

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'initialPrice': initialPrice,
      'productPrice': productPrice,
      'quantity': quantity.value,
      'unitTag': unitTag,
      'productImage': productImage,
    };
  }

  Map<String, dynamic> quantityMap() {
    return {
      'productId': productId,
      'quantity': quantity.value,
    };
  }
}