import '../../core/utils/json_parsing.dart';

/// Shipping address in `addresses/{id}` (linked to the user by email).
class AddressModel {
  const AddressModel({
    this.id,
    required this.email,
    required this.address,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  final String? id;
  final String email;
  final String address;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  /// One-line form used on orders.
  String get formatted => [
    address,
    street,
    city,
    state,
    postalCode,
    country,
  ].where((part) => part.trim().isNotEmpty).join(', ');

  factory AddressModel.fromMap(Map<String, dynamic> map, {String? id}) =>
      AddressModel(
        id: id,
        email: asString(map['email']),
        address: asString(map['address']),
        street: asString(map['street']),
        city: asString(map['city']),
        state: asString(map['state']),
        postalCode: asString(map['postalCode']),
        country: asString(map['country']),
      );

  Map<String, dynamic> toMap() => {
    'email': email,
    'address': address,
    'street': street,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
  };
}
