import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/scoring_engine.dart';
import '../../providers/assessment_provider.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final _reflLearnedCtrl = TextEditingController();
  final _reflDifficultyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssessmentProvider>().startAssessment();
    });
  }

  @override
  void dispose() {
    _reflLearnedCtrl.dispose();
    _reflDifficultyCtrl.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Ujian?'),
        content: const Text('Progres kamu akan hilang jika keluar sekarang.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ═══════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AssessmentProvider>();

    // Auto-redirect to result when finished
    if (p.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.result);
      });
      return const Scaffold(
        backgroundColor: Colors.deepPurple,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (p.questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('Memuat Soal...')));
    }

    return WillPopScope(
      onWillPop: () => _confirmExit(context),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          title: Text(
            'Soal ${p.currentIndex + 1}/${p.questions.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _confirmExit(context)) {
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
          actions: [
            // Phase indicator chip
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text(
                  _phaseLabel(p.phase),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: _phaseColor(p.phase),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (p.currentIndex + _phaseProgress(p.phase)) / p.questions.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple.shade700),
              minHeight: 6,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildPhaseContent(p),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _phaseLabel(AssessmentPhase phase) {
    switch (phase) {
      case AssessmentPhase.answering: return 'MENJAWAB';
      case AssessmentPhase.confidence: return 'KEYAKINAN';
      case AssessmentPhase.feedback: return 'FEEDBACK';
      case AssessmentPhase.reflection: return 'REFLEKSI';
    }
  }

  Color _phaseColor(AssessmentPhase phase) {
    switch (phase) {
      case AssessmentPhase.answering: return Colors.deepPurple;
      case AssessmentPhase.confidence: return Colors.orange;
      case AssessmentPhase.feedback: return Colors.teal;
      case AssessmentPhase.reflection: return Colors.indigo;
    }
  }

  double _phaseProgress(AssessmentPhase phase) {
    switch (phase) {
      case AssessmentPhase.answering: return 0.0;
      case AssessmentPhase.confidence: return 0.25;
      case AssessmentPhase.feedback: return 0.5;
      case AssessmentPhase.reflection: return 0.75;
    }
  }

  Widget _buildPhaseContent(AssessmentProvider p) {
    switch (p.phase) {
      case AssessmentPhase.answering:
        return _buildAnsweringPhase(p);
      case AssessmentPhase.confidence:
        return _buildConfidencePhase(p);
      case AssessmentPhase.feedback:
        return _buildFeedbackPhase(p);
      case AssessmentPhase.reflection:
        return _buildReflectionPhase(p);
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  PHASE 1: ANSWERING (Tier 1 + Tier 2)
  // ═══════════════════════════════════════════════════════════
  Widget _buildAnsweringPhase(AssessmentProvider p) {
    final q = p.currentQuestion;
    final a = p.currentAnswer;
    final canProceed = a.selectedOptionIndex != null && a.selectedReasonIndex != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stimulus/Case
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueGrey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.article_outlined, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text('Skenario/Kasus', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
              ]),
              const SizedBox(height: 12),
              Text(q.stimulus, style: TextStyle(height: 1.5, color: Colors.blueGrey.shade900)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Question text
        Text(q.questionText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4)),
        const SizedBox(height: 24),

        // --- Tier 1 ---
        Text('Pilih Jawaban:', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...List.generate(q.options.length, (i) {
          return _buildOptionCard(
            isSelected: a.selectedOptionIndex == i,
            title: '${String.fromCharCode(65 + i)}. ${q.options[i]}',
            onTap: () => p.selectOption(i),
          );
        }),
        const SizedBox(height: 16),

        // --- Tier 2 ---
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: a.selectedOptionIndex == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 32),
                    Text('Pilih Alasan:', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...List.generate(q.reasoningOptions.length, (i) {
                      return _buildOptionCard(
                        isSelected: a.selectedReasonIndex == i,
                        title: q.reasoningOptions[i].text,
                        onTap: () => p.selectReasoning(i),
                      );
                    }),
                  ],
                ),
        ),
        const SizedBox(height: 24),

        // Submit button
        FilledButton(
          onPressed: canProceed ? () => p.submitAnswerPhase() : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.deepPurple,
          ),
          child: const Text('Simpan Jawaban', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  PHASE 2: CONFIDENCE (Tingkat Keyakinan)
  // ═══════════════════════════════════════════════════════════
  Widget _buildConfidencePhase(AssessmentProvider p) {
    final labels = ['Sangat Tidak Yakin', 'Tidak Yakin', 'Yakin', 'Sangat Yakin'];
    final icons = [Icons.sentiment_very_dissatisfied, Icons.sentiment_dissatisfied, Icons.sentiment_satisfied, Icons.sentiment_very_satisfied];
    final colors = [Colors.red.shade400, Colors.orange.shade400, Colors.lightGreen.shade500, Colors.green.shade600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.orange.shade700, Colors.orange.shade400]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            children: [
              Icon(Icons.psychology, color: Colors.white, size: 48),
              SizedBox(height: 12),
              Text('Seberapa yakin kamu\ndengan jawabanmu?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.3)),
              SizedBox(height: 8),
              Text('Pilihlah tingkat keyakinanmu dengan jujur.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        ...List.generate(4, (i) {
          final level = i + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => p.setConfidence(level),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors[i].withOpacity(0.4), width: 2),
                  boxShadow: [BoxShadow(color: colors[i].withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Icon(icons[i], color: colors[i], size: 36),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(labels[i], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colors[i])),
                          const SizedBox(height: 4),
                          Text('Level $level', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: colors[i], size: 16),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  PHASE 3: FEEDBACK (Assessment for Learning)
  // ═══════════════════════════════════════════════════════════
  Widget _buildFeedbackPhase(AssessmentProvider p) {
    final a = p.currentAnswer;
    final q = p.currentQuestion;

    final categoryColor = {
      'BB': Colors.green, 'BS': Colors.orange, 'SB': Colors.amber.shade700, 'SS': Colors.red,
    }[a.category] ?? Colors.grey;

    final categoryLabel = {
      'BB': 'Benar & Alasan Benar', 'BS': 'Benar & Alasan Salah',
      'SB': 'Salah & Alasan Benar', 'SS': 'Salah & Alasan Salah',
    }[a.category] ?? '';

    final correctAnsText = q.options[q.correctOptionIndex];
    final correctReasonText = q.reasoningOptions.isNotEmpty 
        ? q.reasoningOptions[q.correctReasonIndex].text : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kategori badge
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: categoryColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: categoryColor, borderRadius: BorderRadius.circular(30)),
                child: Text(a.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              ),
              const SizedBox(height: 8),
              Text(categoryLabel, style: TextStyle(fontWeight: FontWeight.w600, color: categoryColor, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Skor: ${a.totalItemScore.toStringAsFixed(2)} / ${ScoringEngine.maxItemScore}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Koreksi jawaban
        _buildCorrectionCard(
          title: 'Jawaban',
          isCorrect: a.tier1Correct,
          userAnswer: a.selectedOptionIndex != null ? q.options[a.selectedOptionIndex!] : '-',
          correctAnswer: correctAnsText,
        ),
        const SizedBox(height: 8),
        _buildCorrectionCard(
          title: 'Alasan',
          isCorrect: a.tier2Correct,
          userAnswer: a.selectedReasonIndex != null ? q.reasoningOptions[a.selectedReasonIndex!].text : '-',
          correctAnswer: correctReasonText,
        ),
        const SizedBox(height: 16),

        // Feedback paragraf
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
                Text('Feedback', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
              const SizedBox(height: 12),
              Text(a.feedbackText, style: const TextStyle(color: Colors.white, height: 1.6, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Skor breakdown
        Row(
          children: [
            _buildScoreChip('Two-Tier', a.twoTierScore, '2.0'),
            const SizedBox(width: 8),
            _buildScoreChip('Keyakinan', a.confidenceScore, '1.0'),
            const SizedBox(width: 8),
            _buildScoreChip('Waktu', a.timeScore, '0.5'),
          ],
        ),
        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: () => p.proceedFromFeedback(),
          icon: const Icon(Icons.edit_note),
          label: const Text('Lanjut: Refleksi Soal Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.indigo,
          ),
        ),
      ],
    );
  }

  Widget _buildCorrectionCard({required String title, required bool isCorrect, required String userAnswer, required String correctAnswer}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green.shade600 : Colors.red.shade600, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$title Kamu: $userAnswer', style: TextStyle(color: isCorrect ? Colors.green.shade900 : Colors.red.shade900, fontSize: 13)),
                if (!isCorrect) ...[
                  const SizedBox(height: 4),
                  Text('Kunci: $correctAnswer', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChip(String label, double score, String max) {
    final isNeg = score < 0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isNeg ? Colors.red.shade50 : Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(score.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isNeg ? Colors.red : Colors.deepPurple)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  PHASE 4: REFLECTION PER SOAL (Assessment as Learning)
  // ═══════════════════════════════════════════════════════════
  Widget _buildReflectionPhase(AssessmentProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo.shade800, Colors.indigo.shade400]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 40),
              SizedBox(height: 12),
              Text('Refleksi Soal Ini', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Tuliskan apa yang kamu rasakan dan pelajari dari soal ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildReflectionField(
          number: '1',
          title: 'Apa yang kamu pelajari dari soal ini?',
          controller: _reflLearnedCtrl,
        ),
        const SizedBox(height: 16),
        _buildReflectionField(
          number: '2',
          title: 'Apa kesalahanmu atau yang masih sulit?',
          controller: _reflDifficultyCtrl,
        ),
        const SizedBox(height: 32),

        FilledButton.icon(
          onPressed: () {
            if (_reflLearnedCtrl.text.trim().length < 3 || _reflDifficultyCtrl.text.trim().length < 3) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Isi kedua refleksi terlebih dahulu (min. 3 karakter).')),
              );
              return;
            }
            p.submitReflectionAndNext(
              learned: _reflLearnedCtrl.text.trim(),
              difficulty: _reflDifficultyCtrl.text.trim(),
            );
            _reflLearnedCtrl.clear();
            _reflDifficultyCtrl.clear();
          },
          icon: Icon(p.currentIndex < p.questions.length - 1 ? Icons.arrow_forward : Icons.check_circle_outline),
          label: Text(
            p.currentIndex < p.questions.length - 1 ? 'Lanjut ke Soal Berikutnya' : 'Selesai & Lihat Hasil',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: p.currentIndex < p.questions.length - 1 ? Colors.deepPurple : Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionField({required String number, required String title, required TextEditingController controller}) {
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
                  decoration: BoxDecoration(color: Colors.indigo.shade50, shape: BoxShape.circle),
                  child: Text(number, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.4))),
              ],
            ),
          ),
          const Divider(height: 1),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
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

  // ═══════════════════════════════════════════════════════════
  //  SHARED WIDGET: Option Card
  // ═══════════════════════════════════════════════════════════
  Widget _buildOptionCard({required bool isSelected, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 24, width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.deepPurple : Colors.grey, width: 2),
                color: isSelected ? Colors.deepPurple : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.deepPurple.shade900 : Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
