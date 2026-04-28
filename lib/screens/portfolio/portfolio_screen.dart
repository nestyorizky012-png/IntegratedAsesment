import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/routes.dart';
import '../../models/assessment_result_model.dart';
import '../../widgets/bottom_nav.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  String _fmt(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd $hh:$mi';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF7F8FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.deepPurple.shade900,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.folder_special, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 16),
                            const Text('Portofolio Digital', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (user == null)
            const SliverFillRemaining(child: Center(child: Text('Harap Login.')))
          else
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('assessment_results').where('userId', isEqualTo: user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(child: Center(child: Text('Error: ${snapshot.error}')));
                }

                final docs = snapshot.data?.docs.toList() ?? [];
                docs.sort((a, b) {
                  final tA = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  final tB = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  if (tA == null || tB == null) return 0;
                  return tB.compareTo(tA);
                });

                if (docs.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_off_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('Belum ada portofolio.', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('Selesaikan asesmen untuk membuat catatan.', style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(24).copyWith(bottom: 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final e = AssessmentResultModel.fromFirestore(docs[i]);
                        final persen = e.scorePercentage.round();
                        final dist = e.categoryDistribution;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: ExpansionTile(
                              iconColor: Colors.deepPurple,
                              collapsedIconColor: Colors.grey.shade400,
                              tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.deepPurple.shade50, shape: BoxShape.circle),
                                    child: Text('$persen%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800, fontSize: 12)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Skor: ${e.totalScore.toStringAsFixed(1)} / ${e.maxPossibleScore.toStringAsFixed(1)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        Text(_fmt(e.createdAt), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    _catBadge('BB', dist['BB'] ?? 0, Colors.green),
                                    _catBadge('BS', dist['BS'] ?? 0, Colors.orange),
                                    _catBadge('SB', dist['SB'] ?? 0, Colors.amber.shade700),
                                    _catBadge('SS', dist['SS'] ?? 0, Colors.red),
                                  ],
                                ),
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              expandedCrossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(height: 24),

                                // Refleksi Global
                                if (e.globalReflectionHardest != null) ...[
                                  _block('Bagian tersulit', e.globalReflectionHardest!, Icons.warning_amber),
                                ],
                                if (e.globalReflectionStrategy != null) ...[
                                  _block('Strategi belajar', e.globalReflectionStrategy!, Icons.lightbulb_outline),
                                ],

                                // Feedback Guru
                                if (e.teacherFeedback != null && e.teacherFeedback!.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      border: Border.all(color: Colors.amber.shade300),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          const Icon(Icons.workspace_premium, color: Colors.orange, size: 20),
                                          const SizedBox(width: 8),
                                          Text('Umpan Balik Guru', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                                        ]),
                                        const SizedBox(height: 8),
                                        Text(e.teacherFeedback!, style: TextStyle(color: Colors.orange.shade900, height: 1.4)),
                                      ],
                                    ),
                                  ),
                                ],

                                // Hapus
                                const SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    label: const Text('Hapus Riwayat'),
                                    onPressed: () async {
                                      final act = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Hapus Portofolio?'),
                                          content: const Text('Catatan ini akan dihapus permanen.'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                            FilledButton(
                                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (act == true && context.mounted) {
                                        await FirebaseFirestore.instance.collection('assessment_results').doc(e.id).delete();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Portofolio dihapus.')));
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: docs.length,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _catBadge(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
        child: Text('$label:$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  Widget _block(String title, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple))),
          ]),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(12)),
            child: Text(text, style: TextStyle(color: Colors.deepPurple.shade900)),
          ),
        ],
      ),
    );
  }
}
