import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  PreferenceHandler._();

  // ============================================================
  // KEYS
  // ============================================================

  static const _isLoginKey = 'isLogin';
  static const _userEmailKey = 'userEmail';
  static const _learningNotificationsKey = 'learning_notifications';

  // ============================================================
  // SHARED PREFERENCES
  // ============================================================

  static SharedPreferences? _preferences;

  // ============================================================
  // INIT
  // ============================================================

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Memastikan SharedPreferences sudah tersedia.
  static SharedPreferences get _prefs {
    final prefs = _preferences;

    if (prefs == null) {
      throw StateError(
        'PreferenceHandler belum diinisialisasi. '
        'Panggil await PreferenceHandler.init() di main() '
        'sebelum menjalankan aplikasi.',
      );
    }

    return prefs;
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static bool get isLogin {
    return _prefs.getBool(_isLoginKey) ?? false;
  }

  static Future<bool> setLogin(bool value) {
    return _prefs.setBool(_isLoginKey, value);
  }

  // ============================================================
  // USER EMAIL
  // ============================================================

  static String? get userEmail {
    return _prefs.getString(_userEmailKey);
  }

  static Future<bool> setUserEmail(String email) {
    return _prefs.setString(
      _userEmailKey,
      email.trim().toLowerCase(),
    );
  }

  // ============================================================
  // COMPLETED LESSONS
  // ============================================================

  static List<String> completedLessons(String courseTitle) {
    return _readStringList(
      'completed_$courseTitle',
    );
  }

  static Future<bool> setCompletedLessons(
    String courseTitle,
    List<String> lessonIds,
  ) {
    return _prefs.setStringList(
      'completed_$courseTitle',
      List<String>.from(lessonIds),
    );
  }

  // ============================================================
  // LEARNING NOTIFICATIONS
  // ============================================================

  static String _learningNotificationsStorageKey() {
    final email = userEmail;

    if (email == null || email.trim().isEmpty) {
      return '${_learningNotificationsKey}_guest';
    }

    return '${_learningNotificationsKey}_${email.trim().toLowerCase()}';
  }

  static List<String> learningNotifications() {
    return _readStringList(_learningNotificationsStorageKey());
  }

  static Future<bool> addLearningNotification({
    required String title,
    required String message,
  }) async {
    final notifications = learningNotifications();
    final timestamp = DateTime.now().toIso8601String();

    notifications.insert(0, '$timestamp|$title|$message');

    return _prefs.setStringList(
      _learningNotificationsStorageKey(),
      notifications.take(30).toList(),
    );
  }

  // ============================================================
  // ATTENDANCE
  // ============================================================

  static String _attendanceKey() {
    final email = userEmail;

    if (email == null || email.trim().isEmpty) {
      return 'attendance_guest';
    }

    return 'attendance_${email.trim().toLowerCase()}';
  }

  static List<String> attendanceDates() {
    return _readStringList(
      _attendanceKey(),
    );
  }

  // ============================================================
  // READ STRING LIST
  // ============================================================

  static List<String> _readStringList(String key) {
    try {
      final value = _prefs.getStringList(key);

      if (value == null) {
        return <String>[];
      }

      return List<String>.from(value);
    } catch (_) {
      // Jika data lama tidak sesuai tipe,
      // kembalikan list kosong agar aplikasi tidak crash.
      return <String>[];
    }
  }

  // ============================================================
  // MARK ATTENDANCE TODAY
  // ============================================================

  static Future<bool> markAttendanceToday() async {
    final today = DateTime.now()
        .toIso8601String()
        .substring(0, 10);

    final dates = attendanceDates();

    if (!dates.contains(today)) {
      dates.add(today);
    }

    dates.sort();

    return _prefs.setStringList(
      _attendanceKey(),
      dates,
    );
  }

  // ============================================================
  // CLEAR SESSION
  // ============================================================

  static Future<void> clearSession() async {
    await _prefs.remove(_isLoginKey);
    await _prefs.remove(_userEmailKey);
  }
}
