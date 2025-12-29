import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/bottom_nav.dart';
import '../../core/routes.dart';


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

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Email: ${p?.email ?? "-"}'),
            const SizedBox(height: 12),

            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _kelas,
              decoration: const InputDecoration(
                labelText: 'Kelas (contoh: VII A)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _sekolah,
              decoration: const InputDecoration(
                labelText: 'Sekolah (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: () {
                if (_name.text.trim().isEmpty || _kelas.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama dan Kelas wajib diisi.')),
                  );
                  return;
                }

                context.read<UserProfileProvider>().updateProfile(
                  name: _name.text,
                  kelas: _kelas.text,
                  sekolah: _sekolah.text,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil tersimpan.')),
                );

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.dashboard,
                  (_) => false,
                );
              
              },
              icon: const Icon(Icons.save),
              label: const Text('Simpan Profil'),

            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                context.read<UserProfileProvider>().clear();
                // AuthGate otomatis balik ke LoginScreen
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ), 
      ),
    bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    ); 
  }
}
