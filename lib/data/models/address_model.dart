import '../../core/utils/json_parsing.dart';

/// A saved delivery address at `users/{uid}/addresses/{id}`.
class AddressModel {
  const AddressModel({
    this.id,
    this.label = '',
    required this.fullName,
    required this.phone,
    required this.address,
    this.street = '',
    required this.city,
    this.state = '',
    required this.postalCode,
    required this.country,
    this.isDefault = false,
  });

  final String? id;

  /// "Home", "Work"… optional.
  final String label;
  final String fullName;
  final String phone;

  /// House / building / unit.
  final String address;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  String get displayLabel => label.trim().isEmpty ? fullName : label.trim();

  /// One-line form stored on orders.
  String get formatted => [
    address,
    street,
    '$postalCode $city'.trim(),
    state,
    country,
  ].where((part) => part.trim().isNotEmpty).join(', ');

  factory AddressModel.fromMap(Map<String, dynamic> map, {String? id}) =>
      AddressModel(
        id: id,
        label: asString(map['label']),
        fullName: asString(map['fullName']),
        phone: asString(map['phone']),
        address: asString(map['address']),
        street: asString(map['street']),
        city: asString(map['city']),
        state: asString(map['state']),
        postalCode: asString(map['postalCode']),
        country: asString(map['country']),
        isDefault: asBool(map['isDefault']),
      );

  Map<String, dynamic> toMap() => {
    'label': label,
    'fullName': fullName,
    'phone': phone,
    'address': address,
    'street': street,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
    'isDefault': isDefault,
  };

  AddressModel copyWith({String? id, bool? isDefault}) => AddressModel(
    id: id ?? this.id,
    label: label,
    fullName: fullName,
    phone: phone,
    address: address,
    street: street,
    city: city,
    state: state,
    postalCode: postalCode,
    country: country,
    isDefault: isDefault ?? this.isDefault,
  );
}
