import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../providers/assessment_provider.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final _hardestCtrl = TextEditingController();
  final _strategyCtrl = TextEditingController();

  @override
  void dispose() {
    _hardestCtrl.dispose();
    _strategyCtrl.dispose();
    super.dispose();
  }

  bool _valid() {
    return _hardestCtrl.text.trim().length >= 5 && _strategyCtrl.text.trim().length >= 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Refleksi Akhir', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade600],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amberAccent),
                        SizedBox(width: 8),
                        Text('Assessment as Learning', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Skor dan feedback kamu sudah tersimpan! Sekarang, tuliskan refleksi akhirmu tentang keseluruhan asesmen yang baru saja kamu kerjakan.',
                      style: TextStyle(color: Colors.white, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _QuestionField(
                number: '1',
                title: 'Bagian mana yang paling sulit bagimu?',
                controller: _hardestCtrl,
              ),
              const SizedBox(height: 24),

              _QuestionField(
                number: '2',
                title: 'Apa strategi belajarmu selanjutnya?',
                controller: _strategyCtrl,
              ),

              const SizedBox(height: 48),

              FilledButton.icon(
                onPressed: () {
                  if (!_valid()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Isi semua jawaban refleksi (min. 5 karakter).')),
                    );
                    return;
                  }
                  context.read<AssessmentProvider>().saveGlobalReflection(
                    hardest: _hardestCtrl.text.trim(),
                    strategy: _strategyCtrl.text.trim(),
                  );
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.portfolio, (_) => false);
                },
                icon: const Icon(Icons.check_circle_outline, size: 24),
                label: const Text('Simpan ke Portofolio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionField extends StatelessWidget {
  final String number;
  final String title;
  final TextEditingController controller;

  const _QuestionField({required this.number, required this.title, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.deepPurple.shade50, shape: BoxShape.circle),
                  child: Text(number, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.4))),
              ],
            ),
          ),
          const Divider(height: 1),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Ketik refleksimu di sini...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ],
      ),
    );
  }
}
