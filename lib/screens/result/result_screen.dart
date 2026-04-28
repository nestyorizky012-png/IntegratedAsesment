import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/scoring_engine.dart';
import '../../providers/assessment_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AssessmentProvider>();
    final total = p.questions.length;
    final score = p.totalScore;
    final maxScore = p.maxPossibleScore;
    final persen = maxScore > 0 ? (score / maxScore * 100).round() : 0;
    final cats = p.categoryCounts;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Hasil & Analitik', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═══ SKOR UTAMA ═══
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 140, width: 140,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: persen / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                            strokeCap: StrokeCap.round,
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('$persen%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                                const Text('Skor Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('${score.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ═══ DISTRIBUSI KATEGORI ═══
              Row(children: [
                _buildCatChip('BB', cats['BB'] ?? 0, Colors.green),
                const SizedBox(width: 8),
                _buildCatChip('BS', cats['BS'] ?? 0, Colors.orange),
                const SizedBox(width: 8),
                _buildCatChip('SB', cats['SB'] ?? 0, Colors.amber.shade700),
                const SizedBox(width: 8),
                _buildCatChip('SS', cats['SS'] ?? 0, Colors.red),
              ]),
              const SizedBox(height: 16),

              // ═══ CONFIDENCE & WAKTU ═══
              Row(children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.psychology,
                    iconColor: Colors.orange,
                    label: 'Yakin',
                    value: '${p.confidentCount}/$total',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.timer_outlined,
                    iconColor: Colors.blue,
                    label: 'Waktu Total',
                    value: _formatTime(p.timeCounts),
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              // ═══ FEEDBACK AGREGAT (AfL) ═══
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.teal.shade700, Colors.teal.shade400]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.lightbulb, color: Colors.amberAccent, size: 20),
                      SizedBox(width: 8),
                      Text('Analisis & Rekomendasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ]),
                    const SizedBox(height: 12),
                    Text(p.overallFeedbackText, style: const TextStyle(color: Colors.white, height: 1.6, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ═══ DETAIL PER SOAL ═══
              const Text('Detail Per Soal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...p.questions.asMap().entries.map((entry) {
                final i = entry.key;
                final q = entry.value;
                final a = p.answerFor(q.id);

                final catColor = {
                  'BB': Colors.green, 'BS': Colors.orange, 'SB': Colors.amber.shade700, 'SS': Colors.red,
                }[a.category] ?? Colors.grey;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: catColor.withOpacity(0.3)),
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(top: 12),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(8)),
                          child: Text(a.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Soal ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Text(
                          '${a.totalItemScore.toStringAsFixed(1)}/${ScoringEngine.maxItemScore}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: catColor),
                        ),
                      ],
                    ),
                    children: [
                      Text(q.questionText, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4)),
                      const SizedBox(height: 8),
                      Row(children: [
                        _buildMiniChip('Keyakinan', a.isConfident ? 'Yakin' : 'Ragu', a.isConfident ? Colors.green : Colors.orange),
                        const SizedBox(width: 8),
                        _buildMiniChip('Waktu', '${a.timeTakenSeconds}s (${a.timeCategory})', Colors.blue),
                      ]),
                      if (a.reflectionLearned != null || a.reflectionDifficulty != null) ...[
                        const Divider(height: 16),
                        if (a.reflectionLearned != null)
                          Text('💡 ${a.reflectionLearned}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3)),
                        if (a.reflectionDifficulty != null)
                          Text('⚠️ ${a.reflectionDifficulty}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3)),
                      ],
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // ═══ TOMBOL LANJUT ═══
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.reflection),
                icon: const Icon(Icons.edit_note, size: 24),
                label: const Text('Lanjut: Refleksi Akhir', style: TextStyle(fontSize: 16)),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(Map<String, int> timeCounts) {
    final c = timeCounts['cepat'] ?? 0;
    final s = timeCounts['sedang'] ?? 0;
    final l = timeCounts['lambat'] ?? 0;
    if (c > s && c > l) return 'Cepat';
    if (l > c && l > s) return 'Lambat';
    return 'Sedang';
  }

  Widget _buildCatChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required Color iconColor, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text('$label: $value', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
