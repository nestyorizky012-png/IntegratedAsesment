import 'package:flutter/material.dart';
import '../../services/admin_firestore_service.dart';
import '../../models/assessment_bank_model.dart';
import '../../core/routes.dart';

class AdminDashboardHome extends StatelessWidget {
  const AdminDashboardHome({super.key});

  void _confirmDelete(BuildContext context, AssessmentBankModel bank) async {
    final act = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Asesmen?'),
        content: Text('Apakah Anda yakin ingin menghapus ujian "${bank.title}"? Aksi ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Permanen'),
          ),
        ],
      )
    );

    if (act == true && context.mounted) {
      try {
        await AdminFirestoreService().deleteAssessmentBank(bank.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ujian berhasil dihapus.')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: const TextStyle(color: Colors.red))));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade700]),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Panel Pemantauan Guru', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text('Kelola ujian yang telah Anda buat, pantau pekerjaan siswa, dan berikan umpan balik.', style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bank Asesmen Anda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {
                      // Trigger Add Assessment tab by tapping the bottom nav or rail
                      // In a more complex app we'd use a provider for tab state.
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tab Input Asesmen untuk menambah soal baru.')));
                    },
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Buat Baru'),
                  )
                ],
              ),
            ),
          ),
          StreamBuilder<List<AssessmentBankModel>>(
            stream: AdminFirestoreService().getAssessmentBanksStream(), // all banks
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(child: Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red))));
              }

              final banks = snapshot.data ?? [];
              
              if (banks.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.blueGrey.shade200),
                          const SizedBox(height: 16),
                          const Text('Belum ada Asesmen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text('Masuk ke layar Input Asesmen untuk mulai membuat bank soal.'),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8).copyWith(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final bank = banks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            // Navigate to Teacher Result Monitor
                            Navigator.pushNamed(context, AppRoutes.adminResults, arguments: bank);
                          },
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: double.infinity,
                                  child: Image.network(
                                    bank.imageUrl, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: Colors.deepPurple.shade50, child: const Icon(Icons.image)),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: Text(bank.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: bank.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                                borderRadius: BorderRadius.circular(8)
                                              ),
                                              child: Text(bank.isActive ? 'Aktif' : 'Draft', style: TextStyle(fontSize: 10, color: bank.isActive ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold)),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text('${bank.subject} • ${bank.durationMinutes} Menit', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Icon(Icons.people_alt_outlined, size: 16, color: Colors.deepPurple.shade700),
                                            const SizedBox(width: 4),
                                            Text('Ketuk untuk pantau siswa', style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade700, fontWeight: FontWeight.w600)),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                                              tooltip: 'Hapus Asesmen',
                                              onPressed: () => _confirmDelete(context, bank),
                                              visualDensity: VisualDensity.compact,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: banks.length,
                  ),
                ),
              );
            }
          )
        ],
      ),
    );
  }
}
