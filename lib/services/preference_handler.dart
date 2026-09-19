import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  PreferenceHandler._();

  static late SharedPreferences _preferences;
  static final ValueNotifier<Color> themeColor = ValueNotifier(
    const Color(0xFF78C943),
  );

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    final savedColor = _preferences.getInt('theme_color');
    if (savedColor != null) themeColor.value = Color(savedColor);
  }

  static Future<void> setLogin(bool value) {
    return _preferences.setBool('is_login', value);
  }

  static Future<void> setCurrentEmail(String email) {
    return _preferences.setString('current_email', email);
  }

  static Future<void> setProfilePhotoPath(String path) {
    return _preferences.setString('profile_photo_path', path);
  }

  static Future<void> setNotificationsEnabled(bool value) {
    return _preferences.setBool('notifications_enabled', value);
  }

  static Future<void> setAttendanceAlarmEnabled(bool value) {
    return _preferences.setBool('attendance_alarm_enabled', value);
  }

  static Future<void> setThemeColor(Color color) async {
    themeColor.value = color;
    await _preferences.setInt('theme_color', color.toARGB32());
  }

  static bool get isLogin => _preferences.getBool('is_login') ?? false;

  static String get currentEmail =>
      _preferences.getString('current_email') ?? 'peserta@devlearning.id';

    static String? get profilePhotoPath =>
      _preferences.getString('profile_photo_path');

      static bool get notificationsEnabled =>
        _preferences.getBool('notifications_enabled') ?? true;

      static bool get attendanceAlarmEnabled =>
        _preferences.getBool('attendance_alarm_enabled') ?? true;
}
