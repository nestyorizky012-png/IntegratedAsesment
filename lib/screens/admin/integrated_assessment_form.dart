import 'package:flutter/material.dart';
import '../../models/assessment_bank_model.dart';
import '../../models/stimulus_model.dart';
import '../../models/question_model.dart';
import '../../services/admin_firestore_service.dart';

class QuestionFormState {
  TextEditingController textCtrl = TextEditingController();
  String level = 'applying';
  List<TextEditingController> optionCtrls = List.generate(4, (_) => TextEditingController());
  int correctOptionIndex = 0;
  List<TextEditingController> reasonCtrls = List.generate(4, (_) => TextEditingController());
  List<TextEditingController> weightCtrls = List.generate(4, (i) => TextEditingController(text: '${10 * (4-i)}'));
  int correctReasonIndex = 0; // Alasan yang benar
}

class IntegratedAssessmentForm extends StatefulWidget {
  const IntegratedAssessmentForm({super.key});

  @override
  State<IntegratedAssessmentForm> createState() => _IntegratedAssessmentFormState();
}

class _IntegratedAssessmentFormState extends State<IntegratedAssessmentForm> {
  final AdminFirestoreService _dbService = AdminFirestoreService();
  int _currentStep = 0;
  bool _isSaving = false;

  // Step 0: Assessment Info
  final _bankTitleCtrl = TextEditingController();
  final _bankSubjectCtrl = TextEditingController();
  final _bankDurationCtrl = TextEditingController(text: '60');
  final _bankCreatorCtrl = TextEditingController();
  final _bankImgCtrl = TextEditingController();

  // Step 1: Stimulus
  final _stimTitleCtrl = TextEditingController();
  final _stimDescCtrl = TextEditingController();
  final _stimTableCtrl = TextEditingController();

  // Step 2: Questions
  final List<QuestionFormState> _questions = [QuestionFormState()]; // Start with 1 empty question

  Future<void> _submitAll() async {
    // 1. Validasi Minimal
    if (_bankTitleCtrl.text.isEmpty || _stimTitleCtrl.text.isEmpty || _stimDescCtrl.text.isEmpty || _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Peringatan: Lengkapi seluruh informasi dasar dan minimal sertakan 1 soal.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final stimulusId = DateTime.now().millisecondsSinceEpoch.toString();
      final bankId = 'BANK_$stimulusId';

      // 2. Tembak Stimulus
      final stimulusModel = StimulusModel(
        id: stimulusId,
        title: _stimTitleCtrl.text.trim(),
        description: _stimDescCtrl.text.trim(),
        dataTable: _stimTableCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      await _dbService.addStimulus(stimulusModel);

      // 3. Tembak Loop Soal-soal
      for (var qState in _questions) {
        final List<ReasoningOption> reasonings = [];
        for(int i=0; i<4; i++) {
           reasonings.add(ReasoningOption(
             text: qState.reasonCtrls[i].text.trim(),
             weight: int.tryParse(qState.weightCtrls[i].text) ?? 10
           ));
        }

        final qModel = QuestionModel(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            stimulusId: stimulusId,
            stimulus: stimulusModel.description,
            questionText: qState.textCtrl.text.trim(),
            level: qState.level,
            options: qState.optionCtrls.map((c) => c.text.trim()).toList(),
            correctOptionIndex: qState.correctOptionIndex,
            reasoningOptions: reasonings,
            correctReasonIndex: qState.correctReasonIndex,
        );
        await _dbService.addQuestion(qModel);
      }

      // 4. Tembak Bank Wadah Utama
      final bankModel = AssessmentBankModel(
        id: bankId,
        title: _bankTitleCtrl.text.trim(),
        subject: _bankSubjectCtrl.text.trim(),
        durationMinutes: int.tryParse(_bankDurationCtrl.text) ?? 60,
        creatorName: _bankCreatorCtrl.text.trim(),
        imageUrl: _bankImgCtrl.text.trim(),
        stimulusId: stimulusId,
        isActive: true, // Auto publish
        createdAt: DateTime.now(),
      );
      await _dbService.addAssessmentBank(bankModel);

      // Selesai
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sukses! Asesmen, Kasus, dan Soal berhasil disimpan ke Database secara paralel.')));
        
        // Reset form
        setState(() {
          _currentStep = 0;
          _bankTitleCtrl.clear(); _bankSubjectCtrl.clear(); _bankCreatorCtrl.clear();
          _stimTitleCtrl.clear(); _stimDescCtrl.clear(); _stimTableCtrl.clear();
          _questions.clear(); _questions.add(QuestionFormState());
        });
      }
    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
       if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaving) {
      return const Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Menyimpan Asesmen Raksasa ke Firestore... (Jangan ditutup)'),
        ],
      ));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Input Asesmen (Wizard Terpadu)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stepper(
        type: MediaQuery.of(context).size.width >= 800 ? StepperType.horizontal : StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            _submitAll();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: isLast ? Colors.green.shade700 : Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
                  ),
                  child: Text(isLast ? 'Publish Ujian Ke Siswa' : 'Lanjut'),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 16),
                  TextButton(onPressed: details.onStepCancel, child: const Text('Kembali')),
                ]
              ],
            ),
          );
        },
        steps: [
          // TAHAP 1
          Step(
            isActive: _currentStep >= 0,
            title: const Text('1. Info Bank Soal'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: _bankTitleCtrl, decoration: const InputDecoration(labelText: 'Judul Asesmen (Maks 3 Kata)')),
                const SizedBox(height: 16),
                TextField(controller: _bankSubjectCtrl, decoration: const InputDecoration(labelText: 'Mata Pelajaran')),
                const SizedBox(height: 16),
                TextField(controller: _bankCreatorCtrl, decoration: const InputDecoration(labelText: 'Nama Guru Pembuat')),
                const SizedBox(height: 16),
                TextField(controller: _bankDurationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Waktu Pengerjaan (Menit)')),
                const SizedBox(height: 16),
                TextField(controller: _bankImgCtrl, decoration: const InputDecoration(labelText: 'Link URL Gambar Sampul Kartu (Kosongi jika tak ada)')),
              ]
            ),
          ),
          
          // TAHAP 2
          Step(
            isActive: _currentStep >= 1,
            title: const Text('2. Kasus / Stimulus'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Layar stimulus yang akan dibaca pertama kali oleh siswa.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(controller: _stimTitleCtrl, decoration: const InputDecoration(labelText: 'Judul Topik Pembacaan')),
                const SizedBox(height: 16),
                TextField(
                  controller: _stimDescCtrl, 
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: 'Ketik Narasi Panjang Cerita/Kasus di sini', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _stimTableCtrl, 
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Tabel Dukungan Data (Opsional)', border: OutlineInputBorder()),
                ),
              ]
            ),
          ),

          // TAHAP 3
          Step(
            isActive: _currentStep >= 2,
            title: const Text('3. Daftar Soal Two-Tier'),
            content: Column(
               children: [
                  ...List.generate(_questions.length, (index) {
                     final q = _questions[index];
                     return Card(
                       margin: const EdgeInsets.only(bottom: 24),
                       elevation: 4,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.deepPurple.shade100)),
                       child: Padding(
                         padding: const EdgeInsets.all(24.0),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.stretch,
                           children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('SOAL #${index+1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                                    setState(() => _questions.removeAt(index));
                                  })
                                ],
                              ),
                              const Divider(),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextField(controller: q.textCtrl, decoration: const InputDecoration(labelText: 'Pertanyaan', border: OutlineInputBorder())),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 1,
                                    child: DropdownButtonFormField<String>(
                                      value: q.level,
                                      decoration: const InputDecoration(labelText: 'Level', border: OutlineInputBorder()),
                                      items: const [
                                        DropdownMenuItem(value: 'understanding', child: Text('Understanding (C2)')),
                                        DropdownMenuItem(value: 'applying', child: Text('Applying (C3)')),
                                        DropdownMenuItem(value: 'reflecting', child: Text('Reflecting')),
                                      ],
                                      onChanged: (v) => setState(() => q.level = v!),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // Tier 1
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('TIER 1 (Opsi Pilihan Ganda Induk)', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 16),
                                    ...List.generate(4, (optIdx) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          children: [
                                            Radio<int>(
                                              value: optIdx, groupValue: q.correctOptionIndex, 
                                              onChanged: (v) => setState(() => q.correctOptionIndex = v!)
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: q.optionCtrls[optIdx], 
                                                decoration: InputDecoration(
                                                  labelText: 'Opsi Jawaban ${String.fromCharCode(65 + optIdx)}', 
                                                  filled: q.correctOptionIndex == optIdx,
                                                  fillColor: Colors.green.shade50,
                                                )
                                              )
                                            )
                                          ],
                                        ),
                                      );
                                    })
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),
                              
                              // Tier 2
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('TIER 2 (Daftar Pilihan Alasan/Logika)', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text('Pilih radio untuk menandai alasan yang BENAR', style: TextStyle(color: Colors.orange.shade800, fontSize: 12)),
                                    const SizedBox(height: 16),
                                    ...List.generate(4, (rsnIdx) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          children: [
                                            Radio<int>(
                                              value: rsnIdx,
                                              groupValue: q.correctReasonIndex,
                                              activeColor: Colors.orange.shade800,
                                              onChanged: (v) => setState(() => q.correctReasonIndex = v!),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: TextField(
                                                controller: q.reasonCtrls[rsnIdx], 
                                                decoration: InputDecoration(
                                                  labelText: 'Teks Alasan ke-${rsnIdx+1}',
                                                  filled: q.correctReasonIndex == rsnIdx,
                                                  fillColor: Colors.green.shade50,
                                                )
                                              )
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 1,
                                              child: TextField(
                                                controller: q.weightCtrls[rsnIdx], 
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(labelText: 'Bobot (10-40)')
                                              )
                                            )
                                          ],
                                        ),
                                      );
                                    })
                                  ],
                                ),
                              ),
                           ],
                         ),
                       )
                     );
                  }),

                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() => _questions.add(QuestionFormState()));
                    }, 
                    icon: const Icon(Icons.add), 
                    label: const Text('Tambah Lembar Soal Baru'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32)
                    ),
                  )
               ],
            ),
          ),
        ],
      ),
    );
  }
}
