import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stimulus_model.dart';
import '../models/question_model.dart';
import '../models/assessment_bank_model.dart';
import '../models/assessment_result_model.dart';

class AdminFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- STIMULUS ---
  Stream<List<StimulusModel>> getStimulusStream() {
    return _db.collection('stimulus').orderBy('created_at', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StimulusModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addStimulus(StimulusModel stimulus) {
    return _db.collection('stimulus').doc(stimulus.id).set(stimulus.toJson())
        .timeout(const Duration(seconds: 15), onTimeout: () => throw Exception('Koneksi Internet Terputus atau Lemah.'));
  }

  Future<void> deleteStimulus(String id) {
    return _db.collection('stimulus').doc(id).delete()
        .timeout(const Duration(seconds: 15));
  }

  // --- QUESTIONS ---
  Stream<List<QuestionModel>> getQuestionsStream() {
    return _db.collection('questions').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addQuestion(QuestionModel question) {
    return _db.collection('questions').doc(question.id).set(question.toJson())
        .timeout(const Duration(seconds: 15), onTimeout: () => throw Exception('Gagal menyimpan soal, jaringan tidak stabil.'));
  }

  Future<void> deleteQuestion(String id) {
    return _db.collection('questions').doc(id).delete()
        .timeout(const Duration(seconds: 15));
  }

  // --- ASSESSMENT BANKS ---
  Stream<List<AssessmentBankModel>> getAssessmentBanksStream({bool onlyActive = false}) {
    Query query = _db.collection('assessment_banks');
    if (onlyActive) {
      query = query.where('is_active', isEqualTo: true);
    }
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => AssessmentBankModel.fromFirestore(doc)).toList();
      // Sort locally to prevent Firestore FAILED_PRECONDITION indexing issues
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> deleteAssessmentBank(String bankId) async {
    // Note: this deletes the bank. In a full system, you might also want to delete
    // the associated stimulus and questions, or just keep them orphaned.
    // For now, we delete the bank entry to immediately hide it from students.
    try {
      await _db.collection('assessment_banks').doc(bankId).delete()
        .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('Gagal menghapus Asesmen: $e');
    }
  }

  Future<void> addAssessmentBank(AssessmentBankModel bank) {
    return _db.collection('assessment_banks').doc(bank.id).set(bank.toJson())
        .timeout(const Duration(seconds: 15), onTimeout: () => throw Exception('Gagal menyimpan bank soal. Cek koneksi Wi-Fi Anda.'));
  }

  Future<void> toggleAssessmentBankStatus(String id, bool newStatus) {
    return _db.collection('assessment_banks').doc(id).update({'is_active': newStatus})
        .timeout(const Duration(seconds: 10));
  }

  // --- RESULTS & FEEDBACK ---
  Stream<List<AssessmentResultModel>> getAssessmentResultsStream(String bankId) {
    return _db.collection('assessment_results')
      .where('assessmentId', isEqualTo: bankId)
      .snapshots().map((snapshot) {
        final list = snapshot.docs.map((doc) => AssessmentResultModel.fromFirestore(doc)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort descending manually
        return list;
      });
  }

  Future<void> updateTeacherFeedback(String resultId, String feedback) {
    return _db.collection('assessment_results').doc(resultId).update({'teacherFeedback': feedback});
  }
}
