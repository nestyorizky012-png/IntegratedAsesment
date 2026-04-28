import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/answer_model.dart';
import '../models/question_model.dart';
import '../models/assessment_result_model.dart';
import '../core/scoring_engine.dart';
import '../core/feedback_generator.dart';

/// Fase asesmen per soal
enum AssessmentPhase {
  answering,   // Tier 1 + Tier 2
  confidence,  // Pilih tingkat keyakinan
  feedback,    // Tampilkan feedback otomatis
  reflection,  // Refleksi per soal
}

class AssessmentProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════
  //  DATA SOAL & STIMULUS
  // ═══════════════════════════════════════════════════════════
  List<QuestionModel> _questions = [];
  List<QuestionModel> get questions => _questions;
  
  String? _activeAssessmentId;
  String? get activeAssessmentId => _activeAssessmentId;

  String? _stimulusTitle;
  String get stimulusTitle => _stimulusTitle ?? 'Skenario Ujian';

  String? _stimulusText;
  String get stimulusText => _stimulusText ?? 'Memuat...';

  bool _isLoadingAssessment = false;
  bool get isLoadingAssessment => _isLoadingAssessment;

  Future<bool> loadRealAssessment(String bankId, String stimulusId) async {
    _isLoadingAssessment = true;
    notifyListeners();
    try {
      final db = FirebaseFirestore.instance;
      
      // Load Stimulus
      final stimDoc = await db.collection('stimulus').doc(stimulusId).get();
      if (stimDoc.exists && stimDoc.data() != null) {
        _stimulusTitle = stimDoc.data()!['title'] ?? 'Skenario Ujian';
        _stimulusText = stimDoc.data()!['description'] ?? 'Teks tidak ditemukan.';
      } else {
        _stimulusTitle = 'Skenario Ujian';
        _stimulusText = 'Stimulus tidak ditemukan di database.';
      }

      // Load Questions
      final qSnap = await db.collection('questions').where('stimulus_id', isEqualTo: stimulusId).get();
      _questions = qSnap.docs.map((d) => QuestionModel.fromFirestore(d)).toList();

      _activeAssessmentId = bankId;
      _isLoadingAssessment = false;
      notifyListeners();
      return _questions.isNotEmpty;
    } catch (e) {
      _isLoadingAssessment = false;
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  ASSESSMENT STATE
  // ═══════════════════════════════════════════════════════════
  final Map<String, AnswerModel> _answers = {};
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  QuestionModel get currentQuestion => _questions[_currentIndex];

  AnswerModel get currentAnswer {
    final qId = currentQuestion.id;
    return _answers.putIfAbsent(qId, () => AnswerModel(questionId: qId));
  }

  // --- Phase State Machine ---
  AssessmentPhase _phase = AssessmentPhase.answering;
  AssessmentPhase get phase => _phase;

  bool _isFinished = false;
  bool get isFinished => _isFinished;

  // --- Stopwatch per soal (bukan countdown timer!) ---
  final Stopwatch _stopwatch = Stopwatch();

  // ═══════════════════════════════════════════════════════════
  //  START ASSESSMENT
  // ═══════════════════════════════════════════════════════════
  void startAssessment() {
    _answers.clear();
    _currentIndex = 0;
    _isFinished = false;
    _phase = AssessmentPhase.answering;
    _stopwatch.reset();
    _stopwatch.start();
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  //  ACTION: PILIH JAWABAN (PHASE: ANSWERING)
  // ═══════════════════════════════════════════════════════════
  void selectOption(int index) {
    currentAnswer.selectedOptionIndex = index;
    notifyListeners();
  }

  void selectReasoning(int index) {
    currentAnswer.selectedReasonIndex = index;
    notifyListeners();
  }

  /// Simpan jawaban Tier1+Tier2, hitung skor two-tier, lanjut ke phase confidence
  void submitAnswerPhase() {
    final ans = currentAnswer;
    final q = currentQuestion;

    if (ans.selectedOptionIndex == null || ans.selectedReasonIndex == null) return;

    // Catat waktu
    _stopwatch.stop();
    ans.timeTakenSeconds = _stopwatch.elapsed.inSeconds;

    // Klasifikasi Two-Tier
    ans.tier1Correct = ans.selectedOptionIndex == q.correctOptionIndex;
    ans.tier2Correct = ans.selectedReasonIndex == q.correctReasonIndex;
    ans.category = ScoringEngine.classifyTwoTier(ans.tier1Correct, ans.tier2Correct);
    ans.twoTierScore = ScoringEngine.scoreTwoTier(ans.category);

    // Klasifikasi Waktu
    ans.timeCategory = ScoringEngine.classifyTime(ans.timeTakenSeconds);
    ans.timeScore = ScoringEngine.scoreTime(ans.timeCategory);

    // Pindah ke phase confidence
    _phase = AssessmentPhase.confidence;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  //  ACTION: PILIH CONFIDENCE (PHASE: CONFIDENCE)
  // ═══════════════════════════════════════════════════════════
  void setConfidence(int level) {
    final ans = currentAnswer;
    ans.confidenceLevel = level;
    ans.isConfident = ScoringEngine.isConfident(level);
    ans.confidenceScore = ScoringEngine.scoreConfidence(ans.category, ans.isConfident);

    // Hitung total item score
    ans.totalItemScore = ScoringEngine.calculateItemScore(
      ans.twoTierScore,
      ans.confidenceScore,
      ans.timeScore,
    );

    // Generate feedback otomatis
    ans.feedbackText = FeedbackGenerator.generatePerItemFeedback(
      category: ans.category,
      isConfident: ans.isConfident,
      timeCategory: ans.timeCategory,
    );

    // Pindah ke phase feedback
    _phase = AssessmentPhase.feedback;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  //  ACTION: LANJUT DARI FEEDBACK (PHASE: FEEDBACK)
  // ═══════════════════════════════════════════════════════════
  void proceedFromFeedback() {
    _phase = AssessmentPhase.reflection;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  //  ACTION: SIMPAN REFLEKSI PER SOAL & NEXT (PHASE: REFLECTION)
  // ═══════════════════════════════════════════════════════════
  void submitReflectionAndNext({required String learned, required String difficulty}) {
    currentAnswer.reflectionLearned = learned;
    currentAnswer.reflectionDifficulty = difficulty;

    // Lanjut ke soal berikutnya atau selesai
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _phase = AssessmentPhase.answering;
      _stopwatch.reset();
      _stopwatch.start();
      notifyListeners();
    } else {
      _finishAssessment();
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  FINISH & SAVE TO FIRESTORE
  // ═══════════════════════════════════════════════════════════
  String? _lastSavedResultId;

  Future<void> _finishAssessment() async {
    _isFinished = true;
    _stopwatch.stop();
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Hitung total
    double tScore = 0;
    int tTime = 0;
    final categoryCounts = <String, int>{'BB': 0, 'BS': 0, 'SB': 0, 'SS': 0};
    final timeCounts = <String, int>{'cepat': 0, 'sedang': 0, 'lambat': 0};
    int confidentCount = 0;
    int notConfidentCount = 0;

    for (final ans in _answers.values) {
      tScore += ans.totalItemScore;
      tTime += ans.timeTakenSeconds;
      categoryCounts[ans.category] = (categoryCounts[ans.category] ?? 0) + 1;
      timeCounts[ans.timeCategory] = (timeCounts[ans.timeCategory] ?? 0) + 1;
      if (ans.isConfident) {
        confidentCount++;
      } else {
        notConfidentCount++;
      }
    }

    final maxScore = _questions.length * ScoringEngine.maxItemScore;

    // Generate feedback agregat
    final overallFeedback = FeedbackGenerator.generateOverallFeedback(
      totalQuestions: _questions.length,
      totalScore: tScore,
      maxScore: maxScore,
      categoryCounts: categoryCounts,
      confidentCount: confidentCount,
      notConfidentCount: notConfidentCount,
      timeCounts: timeCounts,
    );

    final result = AssessmentResultModel(
      id: FirebaseFirestore.instance.collection('assessment_results').doc().id,
      assessmentId: _activeAssessmentId ?? 'unknown',
      userId: user.uid,
      createdAt: DateTime.now(),
      totalScore: tScore,
      maxPossibleScore: maxScore,
      totalTime: tTime,
      answers: _answers.values.toList(),
      overallFeedback: overallFeedback,
    );

    _lastSavedResultId = result.id;

    try {
      await FirebaseFirestore.instance
          .collection('assessment_results')
          .doc(result.id)
          .set(result.toJson());
      debugPrint('Berhasil menyimpan hasil asesmen ke Firestore');
    } catch (e) {
      debugPrint('Gagal menyimpan hasil: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  SAVE GLOBAL REFLECTION
  // ═══════════════════════════════════════════════════════════
  Future<void> saveGlobalReflection({required String hardest, required String strategy}) async {
    if (_lastSavedResultId != null) {
      try {
        await FirebaseFirestore.instance.collection('assessment_results').doc(_lastSavedResultId).update({
          'globalReflectionHardest': hardest,
          'globalReflectionStrategy': strategy,
        });
        debugPrint('Refleksi global berhasil disimpan');
      } catch (e) {
        debugPrint('Gagal menyimpan refleksi global: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  HELPER GETTERS
  // ═══════════════════════════════════════════════════════════
  AnswerModel answerFor(String qid) {
    return _answers[qid] ?? AnswerModel(questionId: qid);
  }

  double get totalScore {
    double s = 0;
    for (final ans in _answers.values) {
      s += ans.totalItemScore;
    }
    return s;
  }

  double get maxPossibleScore => _questions.length * ScoringEngine.maxItemScore;

  Map<String, int> get categoryCounts {
    final m = <String, int>{'BB': 0, 'BS': 0, 'SB': 0, 'SS': 0};
    for (final ans in _answers.values) {
      m[ans.category] = (m[ans.category] ?? 0) + 1;
    }
    return m;
  }

  int get confidentCount => _answers.values.where((a) => a.isConfident).length;
  int get notConfidentCount => _answers.values.where((a) => !a.isConfident).length;

  Map<String, int> get timeCounts {
    final m = <String, int>{'cepat': 0, 'sedang': 0, 'lambat': 0};
    for (final ans in _answers.values) {
      m[ans.timeCategory] = (m[ans.timeCategory] ?? 0) + 1;
    }
    return m;
  }

  String get overallFeedbackText {
    return FeedbackGenerator.generateOverallFeedback(
      totalQuestions: _questions.length,
      totalScore: totalScore,
      maxScore: maxPossibleScore,
      categoryCounts: categoryCounts,
      confidentCount: confidentCount,
      notConfidentCount: notConfidentCount,
      timeCounts: timeCounts,
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  RESET
  // ═══════════════════════════════════════════════════════════
  void reset() {
    _answers.clear();
    _currentIndex = 0;
    _isFinished = false;
    _phase = AssessmentPhase.answering;
    _activeAssessmentId = null;
    _lastSavedResultId = null;
    _stopwatch.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }
}
