class AnswerModel {
  final String questionId;
  bool? selectedAnswer; // null kalau belum pilih
  int? selectedReasonIndex; // null kalau belum pilih alasan

  AnswerModel({
    required this.questionId,
    this.selectedAnswer,
    this.selectedReasonIndex,
  });
}
