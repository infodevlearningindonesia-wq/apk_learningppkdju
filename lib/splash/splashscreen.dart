import 'package:devlearning_indonesia/auth/login_sreen.dart';
import 'package:devlearning_indonesia/home/home_screen.dart';
import 'package:devlearning_indonesia/services/preference_handler.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _routeAfterSplash();
  }

  Future<void> _routeAfterSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final destination = PreferenceHandler.isLogin
        ? const HomeScreen()
        : const LoginSreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF82D64D), Color(0xFFC5E95C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/icon_app/icon-logo.jpg',
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'DevLearning Indonesia',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(color: Color(0x55000000), blurRadius: 4),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Color(0xFFFFD330)),
              const SizedBox(height: 16),
              const Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Color(0x55000000), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
