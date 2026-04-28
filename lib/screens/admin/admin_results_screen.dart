import 'package:flutter/material.dart';
import '../../models/assessment_bank_model.dart';
import '../../models/assessment_result_model.dart';
import '../../core/scoring_engine.dart';
import '../../services/admin_firestore_service.dart';

class AdminResultsScreen extends StatelessWidget {
  const AdminResultsScreen({super.key});

  void _showFeedbackDialog(BuildContext context, AssessmentResultModel result) {
    final tc = TextEditingController(text: result.teacherFeedback);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Detail & Umpan Balik'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skor
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('${result.scorePercentage.round()}%',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900)),
                    Text('${result.totalScore.toStringAsFixed(1)} / ${result.maxPossibleScore.toStringAsFixed(1)}',
                      style: TextStyle(color: Colors.deepPurple.shade700, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Distribusi Kategori
              Row(
                children: [
                  _catChip('BB', result.categoryDistribution['BB'] ?? 0, Colors.green),
                  const SizedBox(width: 4),
                  _catChip('BS', result.categoryDistribution['BS'] ?? 0, Colors.orange),
                  const SizedBox(width: 4),
                  _catChip('SB', result.categoryDistribution['SB'] ?? 0, Colors.amber.shade700),
                  const SizedBox(width: 4),
                  _catChip('SS', result.categoryDistribution['SS'] ?? 0, Colors.red),
                ],
              ),
              const SizedBox(height: 16),

              // Detail Per Soal
              const Text('Detail Per Soal:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ...result.answers.asMap().entries.map((entry) {
                final i = entry.key;
                final a = entry.value;
                final catColor = {'BB': Colors.green, 'BS': Colors.orange, 'SB': Colors.amber.shade700, 'SS': Colors.red}[a.category] ?? Colors.grey;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: catColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(6)),
                            child: Text(a.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          Text('Soal ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const Spacer(),
                          Text('${a.totalItemScore.toStringAsFixed(1)}/${ScoringEngine.maxItemScore}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: catColor)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [
                          _miniTag(a.isConfident ? 'Yakin' : 'Ragu', a.isConfident ? Colors.green : Colors.orange),
                          _miniTag('${a.timeTakenSeconds}s', Colors.blue),
                          _miniTag(a.timeCategory, Colors.blueGrey),
                        ],
                      ),
                      if (a.reflectionLearned != null) ...[
                        const SizedBox(height: 6),
                        Text('💡 ${a.reflectionLearned}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                      ],
                      if (a.reflectionDifficulty != null)
                        Text('⚠️ ${a.reflectionDifficulty}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Refleksi Global
              const Text('Refleksi Akhir:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🔹 Bagian Tersulit: ${result.globalReflectionHardest ?? "-"}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('🔹 Strategi Belajar: ${result.globalReflectionStrategy ?? "-"}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Input Feedback Guru
              const Text('Umpan Balik Guru:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: tc,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tuliskan catatan apresiasi / evaluasi...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              try {
                await AdminFirestoreService().updateTeacherFeedback(result.id, tc.text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Umpan Balik Terkirim!')));
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                }
              }
            },
            child: const Text('Kirim ke Siswa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bank = ModalRoute.of(context)!.settings.arguments as AssessmentBankModel;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text('Hasil: ${bank.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<AssessmentResultModel>>(
        stream: AdminFirestoreService().getAssessmentResultsStream(bank.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.blueGrey.shade200),
                  const SizedBox(height: 16),
                  const Text('Belum ada pengerjaan.', style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final r = results[index];
              final dateStr = '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}';
              final hasFeedback = r.teacherFeedback != null && r.teacherFeedback!.isNotEmpty;
              final persen = r.scorePercentage.round();
              final dist = r.categoryDistribution;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () => _showFeedbackDialog(context, r),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.deepPurple.shade50,
                              child: Icon(Icons.person, color: Colors.deepPurple.shade900),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ID: ${r.userId.length > 8 ? '${r.userId.substring(0, 8)}...' : r.userId}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text(dateStr, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('$persen%', style: TextStyle(color: Colors.deepPurple.shade900, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Category badges
                        Row(
                          children: [
                            _catChip('BB', dist['BB'] ?? 0, Colors.green),
                            const SizedBox(width: 4),
                            _catChip('BS', dist['BS'] ?? 0, Colors.orange),
                            const SizedBox(width: 4),
                            _catChip('SB', dist['SB'] ?? 0, Colors.amber.shade700),
                            const SizedBox(width: 4),
                            _catChip('SS', dist['SS'] ?? 0, Colors.red),
                            const Spacer(),
                            Icon(
                              hasFeedback ? Icons.mark_email_read : Icons.edit_note,
                              size: 18,
                              color: hasFeedback ? Colors.blue : Colors.deepPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasFeedback ? 'Terkirim' : 'Beri Feedback',
                              style: TextStyle(fontSize: 11, color: hasFeedback ? Colors.blue : Colors.deepPurple, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static Widget _catChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text('$label:$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  static Widget _miniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
