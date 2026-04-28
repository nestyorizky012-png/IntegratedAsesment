import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/bottom_nav.dart';
import '../../core/routes.dart';
import '../auth/auth_gate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _kelas = TextEditingController();
  final _sekolah = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = context.read<UserProfileProvider>().profile;
    if (p != null) {
      _name.text = p.name ?? '';
      _kelas.text = p.kelas ?? '';
      _sekolah.text = p.sekolah ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _kelas.dispose();
    _sekolah.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<UserProfileProvider>().profile;
    final isComplete = p?.isComplete ?? false;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF7F8FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.deepPurple.shade900,
            title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
            centerTitle: false,
            actions: [
              GestureDetector(
                onTap: () => _updateAvatarDialog(context),
                child: Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    backgroundImage: p?.avatarUrl != null && p!.avatarUrl!.isNotEmpty 
                        ? NetworkImage(p.avatarUrl!) 
                        : null,
                    child: p?.avatarUrl == null || p!.avatarUrl!.isEmpty
                        ? const Icon(Icons.person, color: Colors.white, size: 24)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CARD 1: BIODATA
                  _buildSectionTitle('Profil Pengguna', Icons.person),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDeco(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: TextEditingController(text: p?.email ?? '-'),
                          readOnly: true,
                          decoration: _inputDeco('Email Terdaftar', Icons.email_outlined),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _name,
                          decoration: _inputDeco('Nama Lengkap', Icons.badge_outlined),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _kelas,
                          decoration: _inputDeco('Kelas', Icons.class_outlined),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _sekolah,
                          decoration: _inputDeco('Sekolah (opsional)', Icons.apartment_outlined),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () {
                            if (_name.text.trim().isEmpty || _kelas.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Kelas wajib diisi.')));
                              return;
                            }
                            context.read<UserProfileProvider>().updateProfile(name: _name.text, kelas: _kelas.text, sekolah: _sekolah.text);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan.')));
                            if (!isComplete) {
                              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan Profil', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // CARD 2: PENGATURAN AKUN
                  if (isComplete) ...[
                    _buildSectionTitle('Pengaturan Akun', Icons.security),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDeco(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final email = FirebaseAuth.instance.currentUser?.email;
                              if (email != null) {
                                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tautan reset kata sandi telah dikirim ke email Anda.')),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.lock_reset, color: Colors.deepPurple),
                            label: const Text('Ubah Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Konfirmasi Logout'),
                                  content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                                      child: const Text('Keluar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) {
                                context.read<UserProfileProvider>().clear();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AuthGate()),
                                  (route) => false,
                                );
                              }
                            },
                            icon: const Icon(Icons.logout, color: Colors.redAccent),
                            label: const Text('Keluar (Logout)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // CARD 3: INFO APLIKASI
                    _buildSectionTitle('Sistem', Icons.info_outline),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDeco(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Versi Aplikasi', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(12)),
                                child: Text('1.0.0', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900)),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          FilledButton.tonalIcon(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.appInfo);
                            },
                            icon: const Icon(Icons.developer_board),
                            label: const Text('Informasi Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isComplete ? const AppBottomNav(currentIndex: 2) : null,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
      ],
    );
  }

  BoxDecoration _cardDeco() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }

  void _updateAvatarDialog(BuildContext context) {
    final tc = TextEditingController(text: context.read<UserProfileProvider>().profile?.avatarUrl ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Foto Profil'),
        content: TextField(
          controller: tc,
          decoration: const InputDecoration(
            labelText: 'URL Gambar (https://...)',
            hintText: 'Biarkan kosong jika tidak memakai foto',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              context.read<UserProfileProvider>().updateProfile(avatarUrl: tc.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
