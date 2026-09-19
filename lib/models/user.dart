class User {
  const User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.city,
    this.photoPath,
  });

  final int? id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String city;
  final String? photoPath;

  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'city': city,
    };
    if (photoPath != null) map['photo_path'] = photoPath;
    if (id != null) map['id'] = id;
    return map;
  }

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: (map['phone'] as String?) ?? '',
      password: map['password'] as String,
      city: map['city'] as String,
        photoPath: (map['photo_path'] as String?)?.isEmpty == true
          ? null
          : map['photo_path'] as String?,
    );
  }
}
