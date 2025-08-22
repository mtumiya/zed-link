enum UserRole { client, supplier, courier, admin }

class User {
  final String id;
  final String phoneNumber;
  final String name;
  final UserRole role;
  final String? email;
  final String? address;
  final bool isVerified;
  final DateTime createdAt;
  
  User({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.role,
    this.email,
    this.address,
    this.isVerified = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'role': role.toString(),
      'email': email,
      'address': address,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => UserRole.client,
      ),
      email: json['email'],
      address: json['address'],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}