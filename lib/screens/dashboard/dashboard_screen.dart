import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes.dart';
import '../../models/assessment_bank_model.dart';
import '../../services/admin_firestore_service.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/user_profile_provider.dart';

import '../../widgets/bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showPreviewPopup(BuildContext context, AssessmentBankModel bank) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(bank.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 150, color: Colors.deepPurple.shade50, child: const Icon(Icons.image, size: 50, color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Chip(label: Text(bank.subject), backgroundColor: Colors.orange.shade50, labelStyle: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Chip(label: Text('${bank.durationMinutes} Menit', style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.deepPurple.shade50),
                ],
              ),
              const SizedBox(height: 16),
              Text(bank.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Dibuat oleh: ${bank.creatorName}', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 32),
              Consumer<AssessmentProvider>(
                builder: (context, provider, child) {
                  return FilledButton.icon(
                    icon: provider.isLoadingAssessment 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.play_arrow),
                    label: Text(provider.isLoadingAssessment ? 'Menyiapkan Soal...' : 'Mulai Ujian Sekarang', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: provider.isLoadingAssessment ? null : () async {
                      bool success = await provider.loadRealAssessment(bank.id, bank.stimulusId);
                      if (success && context.mounted) {
                        Navigator.pop(context);
                        provider.startAssessment();
                        Navigator.pushNamed(context, AppRoutes.understanding);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat soal / Ujian kosong!')));
                      }
                    },
                  );
                }
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // Portfolio status now comes from Firestore, not local provider
    final profile = context.watch<UserProfileProvider>().profile;
    
    final name = profile?.name?.trim().isNotEmpty == true ? profile!.name! : 'Pengguna';
    final kelas = profile?.kelas?.trim().isNotEmpty == true ? profile!.kelas! : '-';
    
    final dbService = AdminFirestoreService();

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF7F8FA),
      body: StreamBuilder<List<AssessmentBankModel>>(
        stream: dbService.getAssessmentBanksStream(onlyActive: true),
        builder: (context, snapshot) {
          final list = snapshot.data ?? [];
          
          // Split list to showcase recent (first) and available
          final recentList = list.isNotEmpty ? [list.first] : <AssessmentBankModel>[];
          final availableList = list.length > 1 ? list.sublist(1) : <AssessmentBankModel>[];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                elevation: 0,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Halo, $name 👋',
                                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                        maxLines: 2, overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Kelas: $kelas', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                  child: const Icon(Icons.person, color: Colors.white, size: 32),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                              child: Row(
                                children: [
                                  const Icon(Icons.folder_special, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('Lihat Portofolio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onSelected: (value) async {
                      if (value == 'profile') { Navigator.pushNamed(context, AppRoutes.profile); }
                      else if (value == 'portfolio') { Navigator.pushNamed(context, AppRoutes.portfolio); }
                      else if (value == 'logout') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Konfirmasi Logout'),
                              content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text('Keluar')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await FirebaseAuth.instance.signOut();
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('role');

                            if (context.mounted) {
                              context.read<UserProfileProvider>().clear();
                              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.roleSelection, (route) => false);
                            }
                          }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'profile', child: Text('Profil')),
                      PopupMenuItem(value: 'portfolio', child: Text('Portofolio')),
                      PopupMenuItem(value: 'logout', child: Text('Logout')),
                    ],
                  ),
                ],
              ),
              
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(48.0), child: Center(child: CircularProgressIndicator()))),
                
              if (snapshot.hasError)
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(48.0), child: Center(child: Text('Terjadi Kendala Jaringan: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))))),

              if (recentList.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Text('Baru Ditambahkan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 250,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: recentList.length,
                      itemBuilder: (context, index) {
                        final a = recentList[index];
                        return Container(
                          width: 280,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _showPreviewPopup(context, a),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Image.network(
                                    a.imageUrl, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: Colors.deepPurple.shade50, child: const Icon(Icons.image_outlined, size: 48, color: Colors.grey)),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                                          child: Text(a.subject, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const Spacer(),
                                        Text('${a.durationMinutes} Menit | Oleh ${a.creatorName}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13), maxLines: 1),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              if (availableList.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Text('Bank Soal Tersedia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(bottom: 120),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220.0, mainAxisSpacing: 16.0, crossAxisSpacing: 16.0, childAspectRatio: 0.9,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final a = availableList[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _showPreviewPopup(context, a),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Image.network(
                                    a.imageUrl, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: Colors.indigo.shade50, child: Icon(Icons.collections_bookmark_outlined, size: 40, color: Colors.indigo.shade300)),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text('${a.durationMinutes} Menit', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                        const Spacer(),
                                        Text(a.creatorName, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: availableList.length,
                    ),
                  ),
                ),
              ],
              
              if (list.isEmpty && snapshot.connectionState != ConnectionState.waiting)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(child: Text('Belum ada Bank Asesmen yang diterbitkan oleh Guru.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
                  ),
                )
            ],
          );
        }
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
