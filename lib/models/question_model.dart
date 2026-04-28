import 'package:cloud_firestore/cloud_firestore.dart';

class ReasoningOption {
  final String text;
  final int weight;

  ReasoningOption({required this.text, required this.weight});

  factory ReasoningOption.fromJson(Map<String, dynamic> json) {
    return ReasoningOption(
      text: json['text'] ?? '',
      weight: json['weight'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'weight': weight,
    };
  }
}

class QuestionModel {
  final String id;
  final String? stimulusId; 
  final String stimulus;
  final String questionText;
  final String level;
  
  final List<String> options;
  final int correctOptionIndex;

  final List<ReasoningOption> reasoningOptions;
  final int correctReasonIndex; // Index alasan yang benar (ditandai guru)

  QuestionModel({
    required this.id,
    this.stimulusId,
    required this.stimulus,
    required this.questionText,
    this.level = 'applying',
    required this.options,
    required this.correctOptionIndex,
    required this.reasoningOptions,
    this.correctReasonIndex = 0,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Backward compat: if correct_reason not set, find highest weight
    int correctReason = data['correct_reason'] ?? -1;
    final reasoningList = (data['reasoning'] as List<dynamic>?)
        ?.map((e) => ReasoningOption.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    if (correctReason < 0 && reasoningList.isNotEmpty) {
      int maxWeight = 0;
      for (int i = 0; i < reasoningList.length; i++) {
        if (reasoningList[i].weight > maxWeight) {
          maxWeight = reasoningList[i].weight;
          correctReason = i;
        }
      }
    }
    if (correctReason < 0) correctReason = 0;

    return QuestionModel(
      id: doc.id,
      stimulusId: data['stimulus_id'],
      stimulus: data['stimulus'] ?? '',
      questionText: data['question_text'] ?? '',
      level: data['level'] ?? 'applying',
      options: List<String>.from(data['options'] ?? []),
      correctOptionIndex: data['correct_answer'] ?? 0,
      reasoningOptions: reasoningList,
      correctReasonIndex: correctReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stimulus_id': stimulusId,
      'stimulus': stimulus,
      'question_text': questionText,
      'level': level,
      'options': options,
      'correct_answer': correctOptionIndex,
      'reasoning': reasoningOptions.map((e) => e.toJson()).toList(),
      'correct_reason': correctReasonIndex,
    };
  }
}
