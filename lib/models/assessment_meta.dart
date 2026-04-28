class AssessmentMeta {
  final String id;
  final String title;
  final String subject;
  final int totalQuestions;
  final int durationMinutes;
  final String? creatorName;
  final String? imageUrl;

  AssessmentMeta({
    required this.id,
    required this.title,
    required this.subject,
    required this.totalQuestions,
    required this.durationMinutes,
    this.creatorName,
    this.imageUrl,
  });
}
