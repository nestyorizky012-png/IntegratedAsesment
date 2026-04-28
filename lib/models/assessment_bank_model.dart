import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentBankModel {
  final String id;
  final String title;
  final String subject;
  final int durationMinutes;
  final String creatorName;
  final String imageUrl;
  final String stimulusId; // Tying bank to a specific case study (stimulus)
  final bool isActive;
  final DateTime createdAt;

  AssessmentBankModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.durationMinutes,
    required this.creatorName,
    required this.imageUrl,
    required this.stimulusId,
    this.isActive = true,
    required this.createdAt,
  });

  factory AssessmentBankModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssessmentBankModel(
      id: doc.id,
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      durationMinutes: data['duration_minutes'] ?? 0,
      creatorName: data['creator_name'] ?? '',
      imageUrl: data['image_url'] ?? 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?q=80&w=2073&auto=format&fit=crop',
      stimulusId: data['stimulus_id'] ?? '',
      isActive: data['is_active'] ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subject': subject,
      'duration_minutes': durationMinutes,
      'creator_name': creatorName,
      'image_url': imageUrl.isEmpty ? 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?q=80&w=2073&auto=format&fit=crop' : imageUrl,
      'stimulus_id': stimulusId,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
