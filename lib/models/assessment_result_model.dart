import 'package:cloud_firestore/cloud_firestore.dart';
import 'answer_model.dart';

class AssessmentResultModel {
  final String id;
  final String assessmentId;
  final String userId; 
  final DateTime createdAt;
  
  // --- Skor Baru ---
  final double totalScore;
  final double maxPossibleScore;
  final int totalTime;
  final List<AnswerModel> answers;

  // --- Feedback Agregat (AfL) ---
  final String? overallFeedback;

  // --- Refleksi Global (AaL) ---
  final String? globalReflectionHardest;  // Bagian tersulit
  final String? globalReflectionStrategy; // Strategi belajar selanjutnya

  // --- Feedback Guru ---
  final String? teacherFeedback;

  AssessmentResultModel({
    required this.id,
    required this.assessmentId,
    required this.userId,
    required this.createdAt,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.totalTime,
    required this.answers,
    this.overallFeedback,
    this.globalReflectionHardest,
    this.globalReflectionStrategy,
    this.teacherFeedback,
  });

  factory AssessmentResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final answersData = data['answers'] as List<dynamic>? ?? [];

    return AssessmentResultModel(
      id: doc.id,
      assessmentId: data['assessmentId'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalScore: (data['totalScore'] ?? 0).toDouble(),
      maxPossibleScore: (data['maxPossibleScore'] ?? 0).toDouble(),
      totalTime: data['totalTime'] ?? 0,
      answers: answersData.map((e) => AnswerModel.fromJson(e as Map<String, dynamic>)).toList(),
      overallFeedback: data['overallFeedback'],
      globalReflectionHardest: data['globalReflectionHardest'],
      globalReflectionStrategy: data['globalReflectionStrategy'],
      teacherFeedback: data['teacherFeedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assessmentId': assessmentId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalScore': totalScore,
      'maxPossibleScore': maxPossibleScore,
      'totalTime': totalTime,
      'answers': answers.map((a) => a.toJson()).toList(),
      if (overallFeedback != null) 'overallFeedback': overallFeedback,
      if (globalReflectionHardest != null) 'globalReflectionHardest': globalReflectionHardest,
      if (globalReflectionStrategy != null) 'globalReflectionStrategy': globalReflectionStrategy,
      if (teacherFeedback != null) 'teacherFeedback': teacherFeedback,
    };
  }

  /// Helper: Hitung distribusi kategori (BB/BS/SB/SS)
  Map<String, int> get categoryDistribution {
    final map = <String, int>{'BB': 0, 'BS': 0, 'SB': 0, 'SS': 0};
    for (final a in answers) {
      map[a.category] = (map[a.category] ?? 0) + 1;
    }
    return map;
  }

  /// Helper: Persentase skor
  double get scorePercentage => maxPossibleScore > 0 ? (totalScore / maxPossibleScore * 100) : 0;
}
