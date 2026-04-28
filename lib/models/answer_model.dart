class AnswerModel {
  final String questionId;

  // --- Tier 1 & Tier 2 ---
  int? selectedOptionIndex;
  int? selectedReasonIndex;

  // --- Klasifikasi Two-Tier ---
  bool tier1Correct; // jawaban benar?
  bool tier2Correct; // alasan benar?
  String category;   // 'BB', 'BS', 'SB', 'SS'

  // --- Confidence ---
  int confidenceLevel;  // 1-4 (1=Sangat Tidak Yakin, 4=Sangat Yakin)
  bool isConfident;     // Y (level 3-4) / TY (level 1-2)

  // --- Waktu ---
  int timeTakenSeconds;
  String timeCategory; // 'cepat', 'sedang', 'lambat'

  // --- Skor Komponen ---
  double twoTierScore;    // 0, 1, atau 2
  double confidenceScore; // -0.5 s/d +1
  double timeScore;       // 0, 0.25, atau 0.5
  double totalItemScore;  // twoTier + confidence + time

  // --- Feedback Otomatis (AfL) ---
  String feedbackText;

  // --- Refleksi Per Soal (AaL) ---
  String? reflectionLearned;    // "Apa yang kamu pelajari?"
  String? reflectionDifficulty; // "Apa kesalahanmu?"

  AnswerModel({
    required this.questionId,
    this.selectedOptionIndex,
    this.selectedReasonIndex,
    this.tier1Correct = false,
    this.tier2Correct = false,
    this.category = 'SS',
    this.confidenceLevel = 0,
    this.isConfident = false,
    this.timeTakenSeconds = 0,
    this.timeCategory = 'sedang',
    this.twoTierScore = 0,
    this.confidenceScore = 0,
    this.timeScore = 0,
    this.totalItemScore = 0,
    this.feedbackText = '',
    this.reflectionLearned,
    this.reflectionDifficulty,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOptionIndex': selectedOptionIndex,
      'selectedReasonIndex': selectedReasonIndex,
      'tier1Correct': tier1Correct,
      'tier2Correct': tier2Correct,
      'category': category,
      'confidenceLevel': confidenceLevel,
      'isConfident': isConfident,
      'timeTakenSeconds': timeTakenSeconds,
      'timeCategory': timeCategory,
      'twoTierScore': twoTierScore,
      'confidenceScore': confidenceScore,
      'timeScore': timeScore,
      'totalItemScore': totalItemScore,
      'feedbackText': feedbackText,
      if (reflectionLearned != null) 'reflectionLearned': reflectionLearned,
      if (reflectionDifficulty != null) 'reflectionDifficulty': reflectionDifficulty,
    };
  }

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      questionId: json['questionId'] ?? '',
      selectedOptionIndex: json['selectedOptionIndex'],
      selectedReasonIndex: json['selectedReasonIndex'],
      tier1Correct: json['tier1Correct'] ?? false,
      tier2Correct: json['tier2Correct'] ?? false,
      category: json['category'] ?? 'SS',
      confidenceLevel: json['confidenceLevel'] ?? 0,
      isConfident: json['isConfident'] ?? false,
      timeTakenSeconds: json['timeTakenSeconds'] ?? 0,
      timeCategory: json['timeCategory'] ?? 'sedang',
      twoTierScore: (json['twoTierScore'] ?? 0).toDouble(),
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
      timeScore: (json['timeScore'] ?? 0).toDouble(),
      totalItemScore: (json['totalItemScore'] ?? 0).toDouble(),
      feedbackText: json['feedbackText'] ?? '',
      reflectionLearned: json['reflectionLearned'],
      reflectionDifficulty: json['reflectionDifficulty'],
    );
  }
}
