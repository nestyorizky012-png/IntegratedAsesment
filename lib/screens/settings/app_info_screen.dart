import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Informasi Aplikasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.assessment_rounded, size: 80, color: Colors.deepPurple.shade900),
            ),
            const SizedBox(height: 24),
            Text(
              'Integrated Assessment',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Versi 1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Tentang Aplikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aplikasi ini merupakan produk purwarupa (prototype) dari penelitian Tesis mengenai "Pengembangan Aplikasi Mobile Asesmen for Learning dan As Learning pada Pendekatan Deep Learning Mata Pelajaran Informatika SMP".\n\nSistem mengadopsi model diagnosis kognitif (Rule-Based Engine) untuk memetakan capaian pemahaman teknis siswa secara otomatis.',
              style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            _buildCreditsRow(Icons.person, 'Peneliti', 'Nesty Orizky'),
            const SizedBox(height: 16),
            _buildCreditsRow(Icons.business, 'Institusi', 'Universitas Pendidikan Indonesia'),
            const SizedBox(height: 48),
            Text(
              '© ${DateTime.now().year} All Rights Reserved',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.deepPurple),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}
