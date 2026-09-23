import 'package:devlearning_indonesia/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('User stores profile photo in database map', () {
    final user = User(
      id: 1,
      name: 'Rina',
      email: 'rina@example.com',
      phone: '08123456789',
      password: 'secret',
      city: 'Bandung',
      profilePhoto: '/tmp/avatar.png',
    );

    expect(user.toMap()['profile_photo'], '/tmp/avatar.png');

    final fromMap = User.fromMap(user.toMap());
    expect(fromMap.profilePhoto, '/tmp/avatar.png');
  });
}
