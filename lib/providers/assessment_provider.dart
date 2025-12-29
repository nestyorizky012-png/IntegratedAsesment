import 'package:flutter/material.dart';
import '../models/answer_model.dart';
import '../models/question_model.dart';
import '../models/portfolio_entry.dart';

class AssessmentProvider extends ChangeNotifier {
  final List<QuestionModel> _questions = [
    QuestionModel(
      id: 'q1',
      statement: 'Algoritma adalah langkah-langkah penyelesaian masalah.',
      correctAnswer: true,
      reasoningOptions: [
        'Karena algoritma berisi urutan langkah untuk menyelesaikan masalah.',
        'Karena algoritma adalah perangkat keras komputer.',
        'Karena algoritma hanya digunakan untuk desain tampilan.',
        'Karena algoritma adalah jenis sistem operasi.',
      ],
      correctReasonIndex: 0,
    ),
    QuestionModel(
      id: 'q2',
      statement: 'Perulangan (loop) digunakan untuk memilih salah satu dari dua kondisi.',
      correctAnswer: false,
      reasoningOptions: [
        'Karena perulangan digunakan untuk menjalankan instruksi berulang kali.',
        'Karena perulangan sama dengan percabangan if-else.',
        'Karena perulangan digunakan untuk mematikan program.',
        'Karena perulangan hanya ada di perangkat keras.',
      ],
      correctReasonIndex: 0,
    ),
  ];

  final Map<String, AnswerModel> _answers = {};

  List<QuestionModel> get questions => _questions;

  AnswerModel answerFor(String qid) =>
      _answers.putIfAbsent(qid, () => AnswerModel(questionId: qid));

  void setTrueFalse(String qid, bool value) {
    final a = answerFor(qid);
    a.selectedAnswer = value;
    notifyListeners();
  }

  void setReason(String qid, int reasonIndex) {
    final a = answerFor(qid);
    a.selectedReasonIndex = reasonIndex;
    notifyListeners();
  }

  bool isQuestionComplete(String qid) {
    final a = _answers[qid];
    return a != null && a.selectedAnswer != null && a.selectedReasonIndex != null;
  }

  bool canSubmit() {
    for (final q in _questions) {
      if (!isQuestionComplete(q.id)) return false;
    }
    return true;
  }

  // Skor sederhana untuk matkul: nilai berdasarkan benar/salah saja
  int score() {
    int s = 0;
    for (final q in _questions) {
      final a = _answers[q.id];
      if (a?.selectedAnswer == q.correctAnswer) s++;
    }
    return s;
  }

  // (Opsional) skor penalaran: alasan benar
  int reasoningScore() {
    int s = 0;
    for (final q in _questions) {
      final a = _answers[q.id];
      if (a?.selectedReasonIndex == q.correctReasonIndex) s++;
    }
    return s;
  }

  void reset() {
    _answers.clear();
    notifyListeners();
  }

  final List<PortfolioEntry> _portfolio = [];
  
  List<PortfolioEntry> get portfolio => List.unmodifiable(_portfolio);

  void saveReflectionToPortfolio({
  required String q1,
  required String q2,
  required String q3,
}) {
  final entry = PortfolioEntry(
    createdAt: DateTime.now(),
    answerScore: score(),
    reasoningScore: reasoningScore(),
    totalQuestions: _questions.length,
    q1Reflection: q1.trim(),
    q2Reflection: q2.trim(),
    q3Reflection: q3.trim(),
  );

  _portfolio.insert(0, entry); // terbaru di atas
  notifyListeners();
}

}
