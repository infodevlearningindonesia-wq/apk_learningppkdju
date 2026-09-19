import 'package:flutter/material.dart';

import 'login_sreen.dart';

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
      appBar: AppBar(title: const Text('Konfirmasi Pendaftaran')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 76, color: Color(0xFF78C943)),
              const SizedBox(height: 24),
              Text(
                'Terima kasih, $name dari $city telah mendaftar.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginSreen()),
                  (route) => false,
                ),
                icon: const Icon(Icons.login),
                label: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
