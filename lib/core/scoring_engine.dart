/// Mesin penilaian untuk instrumen asesmen Two-Tier + Confidence + Waktu
/// Sesuai rubrik skripsi: AfL + AaL + Deep Learning
class ScoringEngine {
  // ═══════════════════════════════════════════════════════════
  //  KLASIFIKASI TWO-TIER
  // ═══════════════════════════════════════════════════════════
  
  /// Klasifikasi berdasarkan kebenaran jawaban (Tier 1) dan alasan (Tier 2)
  /// BB = Benar-Benar, BS = Benar-Salah, SB = Salah-Benar, SS = Salah-Salah
  static String classifyTwoTier(bool tier1Correct, bool tier2Correct) {
    if (tier1Correct && tier2Correct) return 'BB';
    if (tier1Correct && !tier2Correct) return 'BS';
    if (!tier1Correct && tier2Correct) return 'SB';
    return 'SS';
  }

  /// Skor Two-Tier: BB=2, BS=1, SB=1, SS=0
  static double scoreTwoTier(String category) {
    switch (category) {
      case 'BB': return 2.0;
      case 'BS': return 1.0;
      case 'SB': return 1.0;
      case 'SS': return 0.0;
      default: return 0.0;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  CONFIDENCE
  // ═══════════════════════════════════════════════════════════
  
  /// Konversi level confidence (1-4) ke boolean Y/TY
  /// Level 1-2 = TY (Tidak Yakin), Level 3-4 = Y (Yakin)
  static bool isConfident(int level) => level >= 3;

  /// Skor Confidence berdasarkan kategori dan keyakinan
  /// BB + Y = +1, BB + TY = +0.5
  /// SB + Y = -0.25, SS + Y = -0.5
  /// lainnya = 0
  static double scoreConfidence(String category, bool confident) {
    if (category == 'BB' && confident) return 1.0;
    if (category == 'BB' && !confident) return 0.5;
    if (category == 'SB' && confident) return -0.25;
    if (category == 'SS' && confident) return -0.5;
    return 0.0;
  }

  // ═══════════════════════════════════════════════════════════
  //  WAKTU
  // ═══════════════════════════════════════════════════════════
  
  /// Klasifikasi waktu pengerjaan
  /// Cepat: ≤ 30 detik, Sedang: 31-120 detik, Lambat: > 120 detik
  static String classifyTime(int seconds) {
    if (seconds <= 30) return 'cepat';
    if (seconds <= 120) return 'sedang';
    return 'lambat';
  }

  /// Skor Waktu: Cepat=+0.5, Sedang=+0.25, Lambat=0
  static double scoreTime(String timeCategory) {
    switch (timeCategory) {
      case 'cepat': return 0.5;
      case 'sedang': return 0.25;
      case 'lambat': return 0.0;
      default: return 0.0;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  SKOR TOTAL PER SOAL
  // ═══════════════════════════════════════════════════════════
  
  /// Hitung skor total per item = twoTier + confidence + time
  /// Max per item = 2 + 1 + 0.5 = 3.5
  static double calculateItemScore(double twoTier, double confidence, double time) {
    return twoTier + confidence + time;
  }

  /// Skor maksimal per soal
  static double get maxItemScore => 3.5;
}
