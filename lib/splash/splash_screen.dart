import 'package:flutter/material.dart';
import 'package:devlearning_indonesia/auth/login_screen.dart';
import 'package:devlearning_indonesia/auth/role_home_screen.dart';
import 'package:devlearning_indonesia/services/preference_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirectAfterSplash();
  }

  Future<void> _redirectAfterSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final destination = PreferenceHandler.isLogin
      ? const RoleHomeScreen()
      : const LoginScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon_app/icon-logo.jpg',
              width: 140,
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 28),
            Text(
              'DevLearning Indonesia',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF126B5B),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
