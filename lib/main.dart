import 'dart:async';

import 'package:devlearning_indonesia/splash/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'database/database_helper.dart';
import 'services/preference_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.init();
  await PreferenceHandler.init();
  runApp(const DevLearningApp());
}

class DevLearningApp extends StatefulWidget {
  const DevLearningApp({super.key});

  @override
  State<DevLearningApp> createState() => _DevLearningAppState();
}

class _DevLearningAppState extends State<DevLearningApp> {
  Timer? _testAlarmTimer;
  Timer? _alarmSoundTimer;
  bool _popupShown = false;

  @override
  void initState() {
    super.initState();
    _testAlarmTimer = Timer(const Duration(seconds: 4), _showTestAlarm);
  }

  @override
  void dispose() {
    _testAlarmTimer?.cancel();
    _alarmSoundTimer?.cancel();
    super.dispose();
  }

  Future<void> _showTestAlarm() async {
    if (!mounted || _popupShown) return;
    _popupShown = true;
    _alarmSoundTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      SystemSound.play(SystemSoundType.alert);
    });
    SystemSound.play(SystemSoundType.alert);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Alarm Tes'),
        content: const Text('Waktu 4 detik sudah lewat.'),
        actions: [
          FilledButton.icon(
            onPressed: () {
              _alarmSoundTimer?.cancel();
              _alarmSoundTimer = null;
              Navigator.of(dialogContext).pop();
            },
            icon: const Icon(Icons.notifications_off_outlined),
            label: const Text('Stop Alarm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: PreferenceHandler.themeColor,
      builder: (context, primaryColor, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DevLearning Indonesia',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              primary: primaryColor,
              secondary: const Color(0xFFFFD330),
            ),
            scaffoldBackgroundColor: const Color(0xFFF7FCEB),
            useMaterial3: true,
          ),
          home: const Splashscreen(),
        );
      },
    );
  }
}
