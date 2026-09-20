import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang aplikasi')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.school_rounded, size: 56, color: Color(0xFF126B5B)),
            SizedBox(height: 18),
            Text('DevLearning Indonesia', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            SizedBox(height: 10),
            Text('Platform belajar sederhana untuk memulai dan memantau perjalanan pengembangan diri.'),
            SizedBox(height: 24),
            Text('Versi 1.0.0', style: TextStyle(color: Color(0xFF68736F))),
          ],
        ),
      ),
    );
  }
}
