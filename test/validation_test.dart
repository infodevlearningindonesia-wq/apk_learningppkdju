import 'package:devlearning_indonesia/services/validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validates a complete email address', () {
    expect(validateEmail('user@example.com'), isNull);
    expect(validateEmail('user@example'), isNotNull);
    expect(validateEmail('@example.com'), isNotNull);
    expect(validateEmail(''), 'Email wajib diisi');
  });
}