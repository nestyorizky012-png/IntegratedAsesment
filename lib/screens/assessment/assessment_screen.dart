import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../providers/assessment_provider.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _index = 0;

  Future<bool> _confirmSubmit(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Konfirmasi Submit'),
      content: const Text('Kamu yakin ingin mengirim jawaban? Setelah submit, jawaban tidak bisa diubah.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Submit'),
        ),
      ],
    ),
  );
  return result ?? false;
}


  @override
  Widget build(BuildContext context) {
    final p = context.watch<AssessmentProvider>();
    final qs = p.questions;
    final q = qs[_index];
    final a = p.answerFor(q.id);

    final isLast = _index == qs.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Soal ${_index + 1}/${qs.length}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'reset') {
                p.reset();
                setState(() => _index = 0);
              }
              if (v == 'exit') Navigator.pop(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'reset', child: Text('Reset Jawaban')),
              PopupMenuItem(value: 'exit', child: Text('Keluar')),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: (_index + 1) / qs.length),
            const SizedBox(height: 16),

            Text(
              q.statement,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Jawaban Benar/Salah
            Card(
              child: Column(
                children: [
                  RadioListTile<bool>(
                    value: true,
                    groupValue: a.selectedAnswer,
                    title: const Text('Benar'),
                    onChanged: (v) {
                      if (v == null) return;
                      p.setTrueFalse(q.id, v);
                    },
                  ),
                  RadioListTile<bool>(
                    value: false,
                    groupValue: a.selectedAnswer,
                    title: const Text('Salah'),
                    onChanged: (v) {
                      if (v == null) return;
                      p.setTrueFalse(q.id, v);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(),

            // Alasan pilihan (unlock setelah pilih benar/salah)
            Text('Alasan:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            if (a.selectedAnswer == null)
              const Text('Pilih Benar/Salah terlebih dahulu untuk membuka pilihan alasan.')
            else
              Card(
                child: Column(
                  children: List.generate(q.reasoningOptions.length, (i) {
                    return RadioListTile<int>(
                      value: i,
                      groupValue: a.selectedReasonIndex,
                      title: Text(q.reasoningOptions[i]),
                      onChanged: (v) {
                        if (v == null) return;
                        p.setReason(q.id, v);
                      },
                    );
                  }),
                ),
              ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _index == 0 ? null : () => setState(() => _index--),
                    child: const Text('Sebelumnya'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                        // ... validasi lengkap
                        if (!isLast) {
                          setState(() => _index++);
                        } else {
                          if (!p.canSubmit()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Masih ada soal yang belum lengkap.')),
                            );
                            return;
                          }

                          final ok = await _confirmSubmit(context);
                          if (!ok) return;

                          Navigator.pushReplacementNamed(context, AppRoutes.result);
                        }
                      },

                    child: Text(isLast ? 'Submit' : 'Berikutnya'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
