import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  PreferenceHandler._();

  // ============================================================
  // KEYS
  // ============================================================

  static const _isLoginKey = 'isLogin';
  static const _userEmailKey = 'userEmail';
  static const _learningNotificationsKey = 'learning_notifications';
  static const _attendanceRecordsKey = 'attendance_records';
  static const _appVisitsKey = 'app_visits';

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

  static int get appVisitCount => _prefs.getInt(_appVisitsKey) ?? 0;

  static Future<bool> recordAppVisit() {
    return _prefs.setInt(_appVisitsKey, appVisitCount + 1);
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

  static String _completedLessonsStorageKey(String courseTitle) {
    final email = userEmail;
    final accountKey = email == null || email.trim().isEmpty
        ? 'guest'
        : email.trim().toLowerCase();
    return 'completed_${accountKey}_$courseTitle';
  }

  static List<String> completedLessons(String courseTitle) {
    return _readStringList(_completedLessonsStorageKey(courseTitle));
  }

  static Future<bool> setCompletedLessons(
    String courseTitle,
    List<String> lessonIds,
  ) {
    return _prefs.setStringList(
      _completedLessonsStorageKey(courseTitle),
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
    final records = attendanceRecords();
    if (records.isNotEmpty) {
      return records.map((record) => record['date']!).toList()..sort();
    }

    return _readStringList(
      _attendanceKey(),
    );
  }

  static List<Map<String, String>> attendanceRecords() {
    return attendanceRecordsFor(userEmail);
  }

  static List<Map<String, String>> attendanceRecordsFor(String? email) {
    final key = email == null || email.trim().isEmpty
        ? '${_attendanceRecordsKey}_guest'
        : '${_attendanceRecordsKey}_${email.trim().toLowerCase()}';

    try {
      return _prefs
          .getStringList(key)
          ?.map((value) {
            final record = jsonDecode(value) as Map<String, dynamic>;
            return {
              'date': record['date'] as String? ?? '',
              'status': record['status'] as String? ?? 'Hadir',
              'note': record['note'] as String? ?? '',
            };
          })
          .where((record) => record['date']!.isNotEmpty)
          .toList() ??
        <Map<String, String>>[];
    } catch (_) {
      return <Map<String, String>>[];
    }
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

  static Future<bool> markAttendanceToday({
    String status = 'Hadir',
    String note = '',
  }) async {
    final today = DateTime.now()
        .toIso8601String()
        .substring(0, 10);

    final records = attendanceRecords();
    if (records.isEmpty) {
      records.addAll(
        _readStringList(_attendanceKey()).map(
          (date) => {'date': date, 'status': 'Hadir', 'note': ''},
        ),
      );
    }

    records.removeWhere((record) => record['date'] == today);
    records.add({'date': today, 'status': status, 'note': note});
    records.sort((a, b) => a['date']!.compareTo(b['date']!));

    return _prefs.setStringList(
      _attendanceRecordsStorageKey(),
      records.map(jsonEncode).toList(),
    );
  }

  static String _attendanceRecordsStorageKey() {
    final email = userEmail;
    if (email == null || email.trim().isEmpty) {
      return '${_attendanceRecordsKey}_guest';
    }

    return '${_attendanceRecordsKey}_${email.trim().toLowerCase()}';
  }

  // ============================================================
  // CLEAR SESSION
  // ============================================================

  static Future<void> clearSession() async {
    final email = _prefs.getString(_userEmailKey);
    final currentAccountEmail = email == null || email.trim().isEmpty
        ? 'guest'
        : email.trim().toLowerCase();

    final keysToClear = <String>{
      _learningNotificationsStorageKey(),
      _attendanceKey(),
      'learning_notifications_guest',
      'attendance_guest',
      'attendance_${currentAccountEmail}',
      'learning_notifications_${currentAccountEmail}',
    };

    for (final key in _prefs.getKeys()) {
      if (key.startsWith('${_learningNotificationsKey}_') ||
          key.startsWith('${_attendanceRecordsKey}_') ||
          key == 'attendance_guest' ||
          key == 'learning_notifications_guest') {
        keysToClear.add(key);
      }
    }

    for (final key in keysToClear) {
      await _prefs.remove(key);
    }

    await _prefs.remove(_isLoginKey);
    await _prefs.remove(_userEmailKey);
  }
}
