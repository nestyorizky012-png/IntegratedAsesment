import 'package:cloud_firestore/cloud_firestore.dart';

class StimulusModel {
  final String id;
  final String title;
  final String description;
  final String dataTable; // String JSON atau Markdown
  final DateTime createdAt;

  StimulusModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dataTable,
    required this.createdAt,
  });

  factory StimulusModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StimulusModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dataTable: data['data_table'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'data_table': dataTable,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
