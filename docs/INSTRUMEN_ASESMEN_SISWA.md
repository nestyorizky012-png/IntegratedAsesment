# INSTRUMEN ASESMEN SISWA
## Two-Tier Multiple Choice + Confidence Level + Refleksi

**Judul Skripsi**: Pengembangan Aplikasi Mobile Asesmen For Learning dan As Learning pada Pendekatan Deep Learning Mata Pelajaran Informatika SMP

| Komponen | Keterangan |
|----------|------------|
| Mata Pelajaran | Informatika |
| Materi | Analisis Data |
| Kelas / Semester | VIII / Genap |
| Jumlah Soal | 5 soal Two-Tier |
| Level Kognitif | C2, C3, C4, C5 |
| Waktu | Tidak dibatasi (dicatat otomatis oleh sistem) |

---

# BAGIAN A: STIMULUS / KASUS

## Skenario: "Survei Kegiatan Ekstrakurikuler SMP Nusantara"

SMP Nusantara melakukan survei terhadap **120 siswa kelas 8** mengenai kegiatan ekstrakurikuler yang diikuti. Data dikumpulkan menggunakan Google Forms dan diolah dalam spreadsheet. Berikut ringkasan datanya:

**Tabel 1. Jumlah Peserta Ekstrakurikuler**

| No | Ekstrakurikuler | Laki-laki | Perempuan | Total |
|----|----------------|:---------:|:---------:|:-----:|
| 1  | Pramuka        | 18        | 22        | 40    |
| 2  | Basket         | 15        | 5         | 20    |
| 3  | Robotika       | 12        | 8         | 20    |
| 4  | Seni Tari      | 3         | 17        | 20    |
| 5  | PMR            | 7         | 13        | 20    |

**Tabel 2. Rata-rata Nilai Informatika Berdasarkan Ekstrakurikuler**

| Ekstrakurikuler | Rata-rata Nilai | Nilai Tertinggi | Nilai Terendah |
|----------------|:---------------:|:---------------:|:--------------:|
| Pramuka        | 78              | 95              | 60             |
| Basket         | 72              | 88              | 55             |
| Robotika       | 85              | 98              | 70             |
| Seni Tari      | 76              | 90              | 62             |
| PMR            | 74              | 85              | 58             |

**Informasi tambahan:**
- Data dikumpulkan pada bulan Maret 2025
- Setiap siswa hanya boleh memilih **1 ekstrakurikuler**
- Nilai Informatika diambil dari rata-rata UTS dan UAS semester ganjil

---

# BAGIAN B: SOAL TWO-TIER

---

## SOAL 1 — Level C2 (Memahami)

### Tier 1 — Jawaban
**Berdasarkan Tabel 1, pernyataan berikut yang BENAR adalah...**

| Opsi | Jawaban |
|------|---------|
| A | Jumlah siswa perempuan yang mengikuti ekstrakurikuler lebih banyak dari laki-laki |
| B | Pramuka adalah satu-satunya ekstrakurikuler yang pesertanya lebih dari 30 siswa |
| C | Jumlah peserta semua ekstrakurikuler selain Pramuka sama banyak |
| D | Basket memiliki peserta paling sedikit di antara semua ekstrakurikuler |

**Kunci Jawaban Tier 1: C**

### Tier 2 — Alasan
**Alasan yang tepat untuk jawabanmu adalah...**

| Opsi | Alasan | Bobot |
|------|--------|:-----:|
| 1 | Karena total perempuan (22+5+8+17+13=65) lebih banyak dari total laki-laki (18+15+12+3+7=55) | 10 |
| 2 | Karena Pramuka memiliki 40 peserta yang merupakan jumlah terbesar | 10 |
| 3 | Karena Basket, Robotika, Seni Tari, dan PMR masing-masing memiliki total 20 peserta | 40 |
| 4 | Karena Basket dan Robotika sama-sama memiliki peserta laki-laki lebih banyak | 10 |

**Kunci Alasan Benar: Alasan 3**

---

## SOAL 2 — Level C3 (Mengaplikasikan)

### Tier 1 — Jawaban
**Jika guru ingin menghitung persentase siswa laki-laki yang mengikuti Robotika dari total seluruh peserta survei, rumus spreadsheet yang TEPAT adalah...**

| Opsi | Jawaban |
|------|---------|
| A | `=12/120*100` |
| B | `=12/20*100` |
| C | `=20/120*100` |
| D | `=12/55*100` |

**Kunci Jawaban Tier 1: A**

### Tier 2 — Alasan
**Alasan yang tepat untuk jawabanmu adalah...**

| Opsi | Alasan | Bobot |
|------|--------|:-----:|
| 1 | Persentase dihitung dari jumlah laki-laki Robotika (12) dibagi total peserta survei (120) lalu dikali 100 | 40 |
| 2 | Persentase dihitung dari jumlah laki-laki Robotika (12) dibagi total peserta Robotika (20) lalu dikali 100 | 10 |
| 3 | Persentase dihitung dari total Robotika (20) dibagi total peserta survei (120) lalu dikali 100 | 10 |
| 4 | Persentase dihitung dari jumlah laki-laki Robotika (12) dibagi total laki-laki seluruh ekskul (55) lalu dikali 100 | 10 |

**Kunci Alasan Benar: Alasan 1**

---

## SOAL 3 — Level C3 (Mengaplikasikan)

### Tier 1 — Jawaban
**Jenis diagram yang PALING TEPAT digunakan untuk membandingkan komposisi laki-laki dan perempuan di setiap ekstrakurikuler adalah...**

| Opsi | Jawaban |
|------|---------|
| A | Diagram lingkaran (pie chart) |
| B | Diagram batang bertumpuk (stacked bar chart) |
| C | Diagram garis (line chart) |
| D | Diagram titik (scatter plot) |

**Kunci Jawaban Tier 1: B**

### Tier 2 — Alasan
**Alasan yang tepat untuk jawabanmu adalah...**

| Opsi | Alasan | Bobot |
|------|--------|:-----:|
| 1 | Diagram lingkaran cocok karena menampilkan proporsi dari keseluruhan data | 10 |
| 2 | Diagram batang bertumpuk menampilkan perbandingan komposisi subkategori (L/P) di setiap kategori sekaligus menunjukkan totalnya | 40 |
| 3 | Diagram garis cocok karena menunjukkan tren perubahan data dari waktu ke waktu | 10 |
| 4 | Diagram titik cocok karena menunjukkan hubungan antara dua variabel berbeda | 10 |

**Kunci Alasan Benar: Alasan 2**

---

## SOAL 4 — Level C4 (Menganalisis)

### Tier 1 — Jawaban
**Berdasarkan Tabel 1 dan Tabel 2, kesimpulan yang dapat diambil dari hubungan antara jenis ekstrakurikuler dan rata-rata nilai Informatika adalah...**

| Opsi | Jawaban |
|------|---------|
| A | Semakin banyak peserta ekstrakurikuler, semakin tinggi rata-rata nilainya |
| B | Ekstrakurikuler yang berhubungan dengan teknologi/sains cenderung memiliki rata-rata nilai Informatika lebih tinggi |
| C | Siswa perempuan mendapat nilai Informatika lebih tinggi dari laki-laki |
| D | Tidak ada hubungan antara jenis ekstrakurikuler dan nilai Informatika |

**Kunci Jawaban Tier 1: B**

### Tier 2 — Alasan
**Alasan yang tepat untuk jawabanmu adalah...**

| Opsi | Alasan | Bobot |
|------|--------|:-----:|
| 1 | Pramuka memiliki peserta terbanyak (40) dan rata-rata nilainya 78, sehingga jumlah peserta menentukan nilai | 10 |
| 2 | Robotika yang berkaitan dengan teknologi memiliki rata-rata tertinggi (85) dan nilai terendahnya pun paling tinggi (70) dibanding ekstrakurikuler lain | 40 |
| 3 | Semua ekstrakurikuler memiliki rata-rata nilai di atas 70, jadi semuanya sama saja | 10 |
| 4 | Basket memiliki rata-rata terendah (72) karena pesertanya kebanyakan laki-laki | 10 |

**Kunci Alasan Benar: Alasan 2**

---

## SOAL 5 — Level C5 (Mengevaluasi)

### Tier 1 — Jawaban
**Seorang siswa menyajikan data Tabel 1 menggunakan diagram lingkaran (pie chart) dengan 5 bagian berukuran sama (masing-masing 20%). Evaluasi terhadap penyajian data tersebut adalah...**

| Opsi | Jawaban |
|------|---------|
| A | Penyajian sudah benar karena ada 5 ekstrakurikuler |
| B | Penyajian kurang tepat karena proporsi peserta tiap ekstrakurikuler berbeda |
| C | Penyajian sudah benar karena Basket, Robotika, Seni Tari, dan PMR memang sama |
| D | Penyajian kurang tepat karena diagram lingkaran tidak boleh digunakan untuk data kategori |

**Kunci Jawaban Tier 1: B**

### Tier 2 — Alasan
**Alasan yang tepat untuk jawabanmu adalah...**

| Opsi | Alasan | Bobot |
|------|--------|:-----:|
| 1 | Diagram lingkaran harus menampilkan proporsi sesuai data asli; Pramuka (33.3%) seharusnya lebih besar dari yang lain (masing-masing 16.7%) | 40 |
| 2 | Semua ukuran bagian sama karena memang ada 5 kelompok data yang setara | 10 |
| 3 | Diagram lingkaran tidak cocok untuk menampilkan data kategori, seharusnya menggunakan diagram batang | 10 |
| 4 | Penyajian sudah benar karena yang penting semua data sudah tercantum dalam diagram | 10 |

**Kunci Alasan Benar: Alasan 1**

---

# BAGIAN C: TINGKAT KEYAKINAN (CONFIDENCE LEVEL)

Setelah menjawab **setiap soal**, siswa diminta memilih tingkat keyakinan:

| Level | Label | Klasifikasi |
|:-----:|-------|:-----------:|
| 1 | Sangat Tidak Yakin | TY (Tidak Yakin) |
| 2 | Tidak Yakin | TY (Tidak Yakin) |
| 3 | Yakin | Y (Yakin) |
| 4 | Sangat Yakin | Y (Yakin) |

---

# BAGIAN D: REFLEKSI PER SOAL (Assessment as Learning)

Setelah melihat feedback otomatis, siswa menjawab 2 pertanyaan refleksi:

1. **"Apa yang kamu pelajari dari soal ini?"**
2. **"Apa kesalahanmu atau yang masih sulit?"**

---

# BAGIAN E: REFLEKSI AKHIR (Assessment as Learning)

Setelah semua soal selesai, siswa menjawab 2 pertanyaan refleksi global:

1. **"Bagian mana yang paling sulit bagimu?"**
2. **"Apa strategi belajarmu selanjutnya?"**

---

# BAGIAN F: RUBRIK PENILAIAN

## F.1 Klasifikasi Two-Tier

| Kategori | Tier 1 (Jawaban) | Tier 2 (Alasan) | Skor | Interpretasi |
|:--------:|:----------------:|:---------------:|:----:|--------------|
| **BB** | ✅ Benar | ✅ Benar | **2** | Paham konsep dan alasan (Deep Understanding) |
| **BS** | ✅ Benar | ❌ Salah | **1** | Jawaban hafalan tanpa pemahaman (Surface) |
| **SB** | ❌ Salah | ✅ Benar | **1** | Paham konsep tapi gagal menerapkan (Misconception) |
| **SS** | ❌ Salah | ❌ Salah | **0** | Belum memahami materi (Not Understanding) |

## F.2 Skor Confidence

| Kategori | Yakin (Y) | Tidak Yakin (TY) |
|:--------:|:---------:|:----------------:|
| **BB** | +1.0 | +0.5 |
| **BS** | 0 | 0 |
| **SB** | −0.25 | 0 |
| **SS** | −0.5 | 0 |

## F.3 Skor Waktu

| Kategori | Rentang Waktu | Skor |
|----------|:-------------:|:----:|
| Cepat | ≤ 30 detik | +0.5 |
| Sedang | 31–120 detik | +0.25 |
| Lambat | > 120 detik | 0 |

## F.4 Perhitungan Skor Total

```
Skor per Soal  = Skor Two-Tier + Skor Confidence + Skor Waktu
Maksimal       = 2 + 1 + 0.5 = 3.5 poin

Skor Total     = Σ Skor per Soal (5 soal)
Maksimal Total = 5 × 3.5 = 17.5 poin
Persentase     = (Skor Total / 17.5) × 100%
```

## F.5 Contoh Perhitungan

| Soal | Tier 1 | Tier 2 | Kategori | Skor TT | Confidence | Skor CF | Waktu | Skor W | **Total** |
|:----:|:------:|:------:|:--------:|:-------:|:----------:|:-------:|:-----:|:------:|:---------:|
| 1 | ✅ | ✅ | BB | 2 | Yakin | +1.0 | 25s | +0.5 | **3.5** |
| 2 | ✅ | ❌ | BS | 1 | Yakin | 0 | 45s | +0.25 | **1.25** |
| 3 | ✅ | ✅ | BB | 2 | Tidak Yakin | +0.5 | 90s | +0.25 | **2.75** |
| 4 | ❌ | ❌ | SS | 0 | Yakin | −0.5 | 150s | 0 | **-0.5** |
| 5 | ❌ | ✅ | SB | 1 | Tidak Yakin | 0 | 60s | +0.25 | **1.25** |
| | | | | | | | | **Total** | **8.25** |

Persentase = (8.25 / 17.5) × 100% = **47.1%**

---

# BAGIAN G: TEMPLATE FEEDBACK OTOMATIS (Assessment for Learning)

## G.1 Feedback Per Soal

Feedback otomatis dihasilkan berdasarkan kombinasi **Kategori + Confidence + Waktu**:

### Komponen 1 — Hasil Utama
| Kategori | Template |
|:--------:|----------|
| BB | "Kamu sudah paham dengan baik! Jawaban dan alasanmu tepat." |
| BS | "Jawabanmu benar, tapi alasan yang kamu pilih belum tepat." |
| SB | "Alasanmu sudah tepat, tapi jawaban utamamu belum benar." |
| SS | "Jawaban dan alasanmu belum tepat." |

### Komponen 2 — Arahan
| Kategori | Template |
|:--------:|----------|
| BB | "Pertahankan pemahaman ini dan terus kembangkan." |
| BS | "Coba perbaiki pemahamanmu tentang alasan di balik jawaban." |
| SB | "Kamu perlu lebih teliti dalam menerapkan konsep ke jawaban." |
| SS | "Pelajari kembali materi ini dari awal agar lebih paham." |

### Komponen 3 — Confidence
| Kondisi | Template |
|---------|----------|
| BB + Yakin | "Kamu yakin dan jawabanmu memang benar, bagus sekali!" |
| BB + Tidak Yakin | "Kamu masih ragu, padahal jawabanmu sudah benar — percaya diri!" |
| Salah + Yakin | "Kamu merasa yakin, tapi masih ada kesalahan — cek ulang pemahamanmu." |
| Salah + Tidak Yakin | "Kamu masih ragu — coba pelajari lagi agar lebih mantap." |

### Komponen 4 — Waktu
| Kategori | Template |
|----------|----------|
| Cepat | "Kamu mengerjakan dengan cepat." |
| Sedang | "Waktu pengerjaanmu cukup baik." |
| Lambat | "Kamu meluangkan waktu untuk berpikir mendalam." |

## G.2 Feedback Agregat (Halaman Hasil)

Feedback agregat mencakup 5 komponen:
1. **Ringkasan skor**: Persentase dan jumlah soal
2. **Analisis pemahaman**: Berdasarkan distribusi BB/BS/SB/SS
3. **Analisis confidence**: Proporsi yakin vs tidak yakin
4. **Analisis waktu**: Kategori waktu dominan
5. **Rekomendasi belajar**: Saran berdasarkan pola kesalahan

---

# BAGIAN H: KISI-KISI SOAL

| No | Indikator | Level | Soal |
|:--:|-----------|:-----:|:----:|
| 1 | Mengidentifikasi informasi yang benar dari tabel data | C2 | 1 |
| 2 | Menerapkan rumus persentase pada spreadsheet | C3 | 2 |
| 3 | Menerapkan pemilihan jenis diagram yang sesuai untuk data | C3 | 3 |
| 4 | Menganalisis hubungan antar variabel dalam data | C4 | 4 |
| 5 | Mengevaluasi ketepatan penyajian data dalam diagram | C5 | 5 |

---

*Instrumen ini dirancang untuk digunakan dalam aplikasi mobile berbasis Flutter dengan sistem penilaian otomatis dan feedback adaptif.*
