class PortfolioEntry {
  final DateTime createdAt;

  final int answerScore;
  final int reasoningScore;
  final int totalQuestions;

  final String q1Reflection; // apa yang dipahami
  final String q2Reflection; // yang masih sulit
  final String q3Reflection; // rencana strategi belajar

  PortfolioEntry({
    required this.createdAt,
    required this.answerScore,
    required this.reasoningScore,
    required this.totalQuestions,
    required this.q1Reflection,
    required this.q2Reflection,
    required this.q3Reflection,
  });
}
