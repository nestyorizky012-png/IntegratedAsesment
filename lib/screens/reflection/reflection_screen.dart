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
  final _q1 = TextEditingController();
  final _q2 = TextEditingController();
  final _q3 = TextEditingController();

  @override
  void dispose() {
    _q1.dispose();
    _q2.dispose();
    _q3.dispose();
    super.dispose();
  }

  bool _valid() {
    return _q1.text.trim().length >= 5 &&
        _q2.text.trim().length >= 5 &&
        _q3.text.trim().length >= 5;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AssessmentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Jurnal Refleksi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Refleksi ini mendukung Assessment as Learning (AaL).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ringkasan hasil', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text('Skor jawaban: ${p.score()} / ${p.questions.length}'),
                    Text('Skor alasan: ${p.reasoningScore()} / ${p.questions.length}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _QuestionField(
              title: '1) Konsep apa yang paling kamu pahami hari ini?',
              controller: _q1,
            ),
            const SizedBox(height: 12),

            _QuestionField(
              title: '2) Bagian mana yang masih membingungkan / sulit?',
              controller: _q2,
            ),
            const SizedBox(height: 12),

            _QuestionField(
              title: '3) Strategi belajarmu selanjutnya apa?',
              controller: _q3,
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: () {
                if (!_valid()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Isi semua jawaban refleksi (min. 5 karakter).')),
                  );
                  return;
                }

                context.read<AssessmentProvider>().saveReflectionToPortfolio(
                      q1: _q1.text,
                      q2: _q2.text,
                      q3: _q3.text,
                    );

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.portfolio,
                  (_) => false,
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Simpan ke Portofolio'),
            ),

            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboard,
                (_) => false,
              ),
              child: const Text('Lewati & Kembali ke Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionField extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  const _QuestionField({
    required this.title,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tulis jawaban kamu...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
