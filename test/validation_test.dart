import 'package:devlearning_indonesia/adminmaster/admin_account_policy.dart';
import 'package:devlearning_indonesia/services/preference_handler.dart';
import 'package:devlearning_indonesia/services/validation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('validates a complete email address', () {
    expect(validateEmail('user@example.com'), isNull);
    expect(validateEmail('user@example'), isNotNull);
    expect(validateEmail('@example.com'), isNotNull);
    expect(validateEmail(''), 'Email wajib diisi');
  });

  test('clearSession removes stored notifications and attendance for the account', () async {
    SharedPreferences.setMockInitialValues({
      'isLogin': true,
      'userEmail': 'rina@example.com',
      'learning_notifications_rina@example.com': ['2024-01-01|Judul|Pesan'],
      'attendance_rina@example.com': ['2024-01-01'],
      'attendance_guest': ['2024-01-02'],
    });

    await PreferenceHandler.init();
    await PreferenceHandler.clearSession();

    expect(PreferenceHandler.isLogin, isFalse);
    expect(PreferenceHandler.userEmail, isNull);
    expect(PreferenceHandler.learningNotifications(), isEmpty);
    expect(PreferenceHandler.attendanceDates(), isEmpty);
  });

  test('admin account management blocks the current admin account from self-edit and deletion', () {
    expect(
      AdminAccountPolicy.isSelfAccount('admin@devlearning.id', 'admin@devlearning.id'),
      isTrue,
    );
    expect(
      AdminAccountPolicy.canManageAccount(
        currentEmail: 'admin@devlearning.id',
        targetEmail: 'admin@devlearning.id',
      ),
      isFalse,
    );
    expect(
      AdminAccountPolicy.canManageAccount(
        currentEmail: 'admin@devlearning.id',
        targetEmail: 'pengajar@devlearning.id',
      ),
      isTrue,
    );
  });
}