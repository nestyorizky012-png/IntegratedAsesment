import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../providers/assessment_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  String _labelFromRatios(double ansRatio, double reasonRatio) {
    // sederhana + enak buat laporan
    if (ansRatio >= 0.8 && reasonRatio >= 0.8) return 'Pemahaman mendalam';
    if (ansRatio >= 0.6 && reasonRatio >= 0.6) return 'Pemahaman cukup';
    if (ansRatio >= 0.4) return 'Perlu penguatan konsep';
    return 'Perlu pendampingan';
  }

  String _feedbackFromLabel(String label) {
    switch (label) {
      case 'Pemahaman mendalam':
        return 'Bagus! Kamu tidak hanya menjawab benar, tapi juga memilih alasan yang sesuai. Pertahankan dan coba soal yang lebih menantang.';
      case 'Pemahaman cukup':
        return 'Sudah cukup baik. Periksa kembali beberapa konsep dan pastikan alasan yang dipilih benar-benar sesuai konteks soal.';
      case 'Perlu penguatan konsep':
        return 'Fokus menguatkan konsep dasar. Coba baca ulang materi dan perhatikan perbedaan istilah (mis. percabangan vs perulangan).';
      default:
        return 'Mulai dari materi dasar dan contoh sederhana. Diskusikan dengan guru/teman lalu ulangi asesmen.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AssessmentProvider>();
    final total = p.questions.length;

    final ansScore = p.score();
    final reasonScore = p.reasoningScore();

    final ansRatio = total == 0 ? 0.0 : ansScore / total;
    final reasonRatio = total == 0 ? 0.0 : reasonScore / total;

    final label = _labelFromRatios(ansRatio, reasonRatio);
    final feedback = _feedbackFromLabel(label);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil & Analitik'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'reset') {
                p.reset();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.dashboard,
                  (_) => false,
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'reset', child: Text('Reset & Kembali')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ringkasan skor
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ringkasan', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            title: 'Skor Jawaban',
                            value: '$ansScore / $total',
                            icon: Icons.check_circle_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            title: 'Skor Alasan',
                            value: '$reasonScore / $total',
                            icon: Icons.psychology_outlined,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.insights_outlined),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Kategori: $label',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Text('Umpan balik (AfL):', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(feedback),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Detail per soal
            Text('Detail Jawaban & Alasan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            ...p.questions.map((q) {
              final a = p.answerFor(q.id);

              final userAns = a.selectedAnswer;
              final userAnsText = userAns == null ? '-' : (userAns ? 'Benar' : 'Salah');
              final correctAnsText = q.correctAnswer ? 'Benar' : 'Salah';
              final isCorrectAns = userAns != null && userAns == q.correctAnswer;

              final userReasonIdx = a.selectedReasonIndex;
              final userReasonText = (userReasonIdx != null && userReasonIdx >= 0 && userReasonIdx < q.reasoningOptions.length)
                  ? q.reasoningOptions[userReasonIdx]
                  : '-';

              final correctReasonText = (q.correctReasonIndex >= 0 && q.correctReasonIndex < q.reasoningOptions.length)
                  ? q.reasoningOptions[q.correctReasonIndex]
                  : '-';

              final isCorrectReason = userReasonIdx != null && userReasonIdx == q.correctReasonIndex;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.statement,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Chip(label: Text(isCorrectAns ? 'Jawaban: Benar' : 'Jawaban: Salah')),
                          const SizedBox(width: 8),
                          Chip(label: Text(isCorrectReason ? 'Alasan: Tepat' : 'Alasan: Kurang tepat')),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Text('Jawaban kamu: $userAnsText'),
                      Text('Kunci jawaban: $correctAnsText'),

                      const Divider(height: 24),

                      Text('Alasan kamu:', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 6),
                      Text(userReasonText),

                      const SizedBox(height: 12),
                      Text('Alasan ideal:', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 6),
                      Text(correctReasonText),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Tombol lanjut AaL
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.reflection),
              icon: const Icon(Icons.edit_note),
              label: const Text('Lanjut: Isi Jurnal Refleksi'),
            ),
            const SizedBox(height: 10),

            OutlinedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboard,
                (_) => false,
              ),
              child: const Text('Kembali ke Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}
