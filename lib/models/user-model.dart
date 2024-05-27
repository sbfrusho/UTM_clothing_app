class User {
  String deviceToken;
  String email;
  bool isAdmin;
  String name;
  String phone;
  String uId;

  User({
    required this.deviceToken,
    required this.email,
    required this.isAdmin,
    required this.name,
    required this.phone,
    required this.uId,
  });

  // Factory constructor for creating a new User instance from a map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      deviceToken: map['deviceToken'] ?? '',
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      uId: map['uId'] ?? '',
    );
  }

  // Method for converting a User instance to a map
  Map<String, dynamic> toMap() {
    return {
      'deviceToken': deviceToken,
      'email': email,
      'isAdmin': isAdmin,
      'name': name,
      'phone': phone,
      'uId': uId,
    };
  }
}
