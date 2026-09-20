class User {
  const User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.city,
    this.createdAt,
  });

  final int? id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String city;
  final String? createdAt;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'city': city,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      password: map['password'] as String? ?? '',
      city: map['city'] as String? ?? '',
      createdAt: map['created_at'] as String?,
    );
  }
}
