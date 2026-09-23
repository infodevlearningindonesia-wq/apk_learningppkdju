import 'package:flutter/material.dart';
import 'package:devlearning_indonesia/auth/login_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({
    super.key,
    required this.name,
    required this.city,
  });

  final String name;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pendaftaran berhasil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: Color(0xFF3F7D27),
              ),
              const SizedBox(height: 24),
              Text(
                'Selamat, $name!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Peserta dari $city telah berhasil terdaftar.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF68736F),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  ),
                  child: const Text('Oke'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
