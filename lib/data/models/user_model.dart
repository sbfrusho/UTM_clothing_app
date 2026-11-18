import '../../core/utils/json_parsing.dart';

/// `users/{uid}`. Field names (including the historical `adress` spelling)
/// are shared with the admin app.
class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    this.name = '',
    this.phone = '',
    this.isAdmin = false,
    this.deviceToken = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.road = '',
    this.postalCode = '',
    this.address = '',
  });

  final String uid;
  final String email;
  final String name;
  final String phone;
  final bool isAdmin;
  final String deviceToken;
  final String city;
  final String state;
  final String country;
  final String road;
  final String postalCode;
  final String address;

  factory UserModel.fromMap(Map<String, dynamic> map, {String? uid}) =>
      UserModel(
        uid: asString(map['uId'], fallback: uid ?? ''),
        email: asString(map['email']),
        name: asString(map['name']),
        phone: asString(map['phone']),
        isAdmin: asBool(map['isAdmin']),
        deviceToken: asString(map['deviceToken']),
        city: asString(map['city']),
        state: asString(map['state']),
        country: asString(map['country']),
        road: asString(map['road']),
        postalCode: asString(map['postalCode']),
        address: asString(map['adress']),
      );

  Map<String, dynamic> toMap() => {
    'uId': uid,
    'email': email,
    'name': name,
    'phone': phone,
    'isAdmin': isAdmin,
    'deviceToken': deviceToken,
    'city': city,
    'state': state,
    'country': country,
    'road': road,
    'postalCode': postalCode,
    'adress': address,
  };

  /// Fields a customer may edit themselves.
  Map<String, dynamic> toProfileUpdate() => {
    'name': name,
    'phone': phone,
    'city': city,
    'state': state,
    'country': country,
    'road': road,
    'postalCode': postalCode,
    'adress': address,
  };

  UserModel copyWith({
    String? name,
    String? phone,
    String? city,
    String? state,
    String? country,
    String? road,
    String? postalCode,
    String? address,
  }) => UserModel(
    uid: uid,
    email: email,
    isAdmin: isAdmin,
    deviceToken: deviceToken,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    city: city ?? this.city,
    state: state ?? this.state,
    country: country ?? this.country,
    road: road ?? this.road,
    postalCode: postalCode ?? this.postalCode,
    address: address ?? this.address,
  );
}
