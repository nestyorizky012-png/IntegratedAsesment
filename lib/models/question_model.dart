class QuestionModel {
  final String id;
  final String statement; // pernyataan untuk True/False
  final bool correctAnswer; // true = Benar, false = Salah

  // alasan pilihan (sesuai konteks)
  final List<String> reasoningOptions;

  // (opsional) alasan yang benar untuk validasi/rubrik
  final int correctReasonIndex;

  QuestionModel({
    required this.id,
    required this.statement,
    required this.correctAnswer,
    required this.reasoningOptions,
    required this.correctReasonIndex,
  });
}
