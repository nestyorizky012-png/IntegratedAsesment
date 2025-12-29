import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../models/assessment_meta.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';
import '../../widgets/bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/user_profile_provider.dart';



class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  List<AssessmentMeta> _dummyAssessments() => [
        AssessmentMeta(
          id: 'a1',
          title: 'Asesmen Algoritma Dasar',
          subject: 'Informatika SMP',
          totalQuestions: 10,
          durationMinutes: 15,
        ),
        AssessmentMeta(
          id: 'a2',
          title: 'Asesmen Struktur Data Sederhana',
          subject: 'Informatika SMP',
          totalQuestions: 8,
          durationMinutes: 12,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final hasPortfolio = context.watch<AssessmentProvider>().portfolio.isNotEmpty;
    final profile = context.watch<UserProfileProvider>().profile;
    final list = _dummyAssessments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Siswa'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.pushNamed(context, AppRoutes.profile);
              } else if (value == 'portfolio') {
                Navigator.pushNamed(context, AppRoutes.portfolio);
              } else if (value == 'about') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tentang Aplikasi (dummy)')),
                );
              } else if (value == 'logout') {
                  await FirebaseAuth.instance.signOut();
                  context.read<UserProfileProvider>().clear();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('Profil')),
              PopupMenuItem(value: 'portfolio', child: Text('Portofolio')),
              PopupMenuItem(value: 'about', child: Text('Tentang')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),          
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${profile?.name ?? "Pengguna"} 👋',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                const Text('Pilih asesmen untuk mulai mengerjakan.'),
                const SizedBox(height: 12),

                      // ===== BADGE STATUS ASESMEN =====
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          hasPortfolio ? Icons.verified : Icons.pending_actions,
                          color: hasPortfolio ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            hasPortfolio
                                ? 'Status: Sudah ada portofolio'
                                : 'Status: Belum dikerjakan',
                          ),
                        ),
                        Chip(
                          label: Text(hasPortfolio ? 'Sudah' : 'Belum'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }

          final a = list[index - 1];
          return Card(
            child: ListTile(
              title: Text(a.title),
              subtitle: Text('${a.subject} • ${a.totalQuestions} soal • ${a.durationMinutes} menit'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // untuk malam ini: langsung masuk assessment screen
                Navigator.pushNamed(context, AppRoutes.assessment);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
