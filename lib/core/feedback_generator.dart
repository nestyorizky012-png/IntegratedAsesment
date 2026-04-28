/// Generator feedback otomatis untuk instrumen asesmen
/// Menghasilkan paragraf Bahasa Indonesia sederhana untuk siswa SMP
class FeedbackGenerator {
  // ═══════════════════════════════════════════════════════════
  //  FEEDBACK PER SOAL (Assessment for Learning)
  // ═══════════════════════════════════════════════════════════

  /// Generate feedback paragraf per soal
  /// Struktur: [hasil utama] + [arah konsep] + [confidence] + [waktu]
  static String generatePerItemFeedback({
    required String category,
    required bool isConfident,
    required String timeCategory,
  }) {
    final hasilUtama = _hasilUtama(category);
    final arahan = _arahan(category);
    final confidence = _confidenceFeedback(category, isConfident);
    final waktu = _waktuFeedback(timeCategory);

    return '$hasilUtama $arahan $confidence $waktu';
  }

  static String _hasilUtama(String category) {
    switch (category) {
      case 'BB':
        return 'Kamu sudah paham dengan baik! Jawaban dan alasanmu tepat.';
      case 'BS':
        return 'Jawabanmu benar, tapi alasan yang kamu pilih belum tepat.';
      case 'SB':
        return 'Alasanmu sudah tepat, tapi jawaban utamamu belum benar.';
      case 'SS':
        return 'Jawaban dan alasanmu belum tepat.';
      default:
        return 'Soal belum dijawab lengkap.';
    }
  }

  static String _arahan(String category) {
    switch (category) {
      case 'BB':
        return 'Pertahankan pemahaman ini dan terus kembangkan.';
      case 'BS':
        return 'Coba perbaiki pemahamanmu tentang alasan di balik jawaban.';
      case 'SB':
        return 'Kamu perlu lebih teliti dalam menerapkan konsep ke jawaban.';
      case 'SS':
        return 'Pelajari kembali materi ini dari awal agar lebih paham.';
      default:
        return '';
    }
  }

  static String _confidenceFeedback(String category, bool isConfident) {
    if (isConfident && (category == 'SS' || category == 'SB' || category == 'BS')) {
      return 'Kamu merasa yakin, tapi masih ada kesalahan — cek ulang pemahamanmu.';
    }
    if (isConfident && category == 'BB') {
      return 'Kamu yakin dan jawabanmu memang benar, bagus sekali!';
    }
    if (!isConfident && category == 'BB') {
      return 'Kamu masih ragu, padahal jawabanmu sudah benar — percaya diri!';
    }
    if (!isConfident) {
      return 'Kamu masih ragu — coba pelajari lagi agar lebih mantap.';
    }
    return '';
  }

  static String _waktuFeedback(String timeCategory) {
    switch (timeCategory) {
      case 'cepat':
        return 'Kamu mengerjakan dengan cepat.';
      case 'sedang':
        return 'Waktu pengerjaanmu cukup baik.';
      case 'lambat':
        return 'Kamu meluangkan waktu untuk berpikir mendalam.';
      default:
        return '';
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  FEEDBACK HALAMAN HASIL (Agregat)
  // ═══════════════════════════════════════════════════════════

  /// Generate feedback agregat untuk halaman hasil
  static String generateOverallFeedback({
    required int totalQuestions,
    required double totalScore,
    required double maxScore,
    required Map<String, int> categoryCounts,
    required int confidentCount,
    required int notConfidentCount,
    required Map<String, int> timeCounts,
  }) {
    final persen = maxScore > 0 ? (totalScore / maxScore * 100).round() : 0;
    final bb = categoryCounts['BB'] ?? 0;
    final bs = categoryCounts['BS'] ?? 0;
    final sb = categoryCounts['SB'] ?? 0;
    final ss = categoryCounts['SS'] ?? 0;

    // 1. Ringkasan nilai
    final ringkasan = 'Dari $totalQuestions soal, kamu mendapatkan skor $persen%.';

    // 2. Analisis pemahaman
    String analisis;
    if (bb == totalQuestions) {
      analisis = 'Luar biasa! Semua jawaban dan alasanmu tepat.';
    } else if (bb >= totalQuestions * 0.6) {
      analisis = 'Kamu memahami sebagian besar materi dengan baik ($bb dari $totalQuestions soal benar sempurna).';
    } else if (ss >= totalQuestions * 0.5) {
      analisis = 'Kamu perlu belajar lebih banyak — sebagian besar jawaban dan alasanmu belum tepat.';
    } else {
      analisis = 'Pemahamanmu sudah mulai terbentuk. $bb soal benar sempurna, $bs jawabanmu benar tapi alasan kurang tepat, dan $sb alasanmu benar tapi jawaban kurang tepat.';
    }

    // 3. Analisis confidence
    String confAnalisis;
    if (confidentCount > notConfidentCount) {
      confAnalisis = 'Secara keseluruhan kamu cukup yakin dengan jawabanmu ($confidentCount dari $totalQuestions soal).';
    } else {
      confAnalisis = 'Kamu masih kurang yakin di beberapa soal ($notConfidentCount dari $totalQuestions soal).';
    }

    // 4. Analisis waktu
    final cepat = timeCounts['cepat'] ?? 0;
    final lambat = timeCounts['lambat'] ?? 0;
    String waktuAnalisis;
    if (cepat > totalQuestions ~/ 2) {
      waktuAnalisis = 'Waktu pengerjaanmu tergolong cepat secara keseluruhan.';
    } else if (lambat > totalQuestions ~/ 2) {
      waktuAnalisis = 'Kamu meluangkan banyak waktu untuk berpikir mendalam.';
    } else {
      waktuAnalisis = 'Waktu pengerjaanmu cukup seimbang.';
    }

    // 5. Rekomendasi
    String rekomendasi;
    if (bb == totalQuestions) {
      rekomendasi = 'Terus pertahankan dan coba tantangan yang lebih sulit!';
    } else if (bs > sb && bs > 0) {
      rekomendasi = 'Fokuskan belajar pada penguatan alasan dan penalaran logis, karena jawabanmu benar tapi alasan pendukungnya kurang tepat.';
    } else if (sb > bs && sb > 0) {
      rekomendasi = 'Kamu sudah paham konsepnya, tapi perlu lebih teliti saat menerapkan ke jawaban.';
    } else if (ss > 0) {
      rekomendasi = 'Disarankan membaca ulang materi dan berdiskusi dengan teman atau guru untuk memperkuat pemahaman.';
    } else {
      rekomendasi = 'Terus berlatih dan jangan ragu bertanya jika ada yang belum jelas.';
    }

    return '$ringkasan $analisis $confAnalisis $waktuAnalisis $rekomendasi';
  }
}
