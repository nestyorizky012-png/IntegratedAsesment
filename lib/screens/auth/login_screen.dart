import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _loginOrRegister({required bool register}) async {
    final email = _email.text.trim();
    final pass = _pass.text.trim();

    if (email.isEmpty || pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email wajib diisi, password minimal 6 karakter.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      if (register) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: pass,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: pass,
        );
      }
      // AuthGate akan otomatis pindah ke Dashboard
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: code=${e.code}, message=${e.message}');

      final msg = switch (e.code) {
        'invalid-email' => 'Format email tidak valid.',
        'user-not-found' => 'Akun belum terdaftar. Klik "Daftar Akun" dulu.',
        'wrong-password' => 'Password salah.',
        'email-already-in-use' => 'Email sudah terdaftar. Silakan login.',
        'weak-password' => 'Password terlalu lemah (min 6 karakter).',
        'operation-not-allowed' =>
            'Login Email/Password belum diaktifkan di Firebase Console (Authentication → Sign-in method).',
        'network-request-failed' =>
            'Koneksi bermasalah. Coba reload workspace / jalankan ulang.',
        'too-many-requests' =>
            'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.',
        'unauthorized-domain' =>
            'Domain belum diizinkan (khusus Web). Tambahkan di Firebase Auth → Settings → Authorized domains.',
        _ => (e.message ?? 'Login gagal. code=${e.code}'),
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } 
    
    
    finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Masuk ke Aplikasi Asesmen', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password (min 6 karakter)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            FilledButton(
              onPressed: _loading ? null : () => _loginOrRegister(register: false),
              child: _loading ? const CircularProgressIndicator() : const Text('Login'),
            ),
            const SizedBox(height: 10),

            OutlinedButton(
              onPressed: _loading ? null : () => _loginOrRegister(register: true),
              child: const Text('Daftar Akun'),
            ),
          ],
        ),
      ),
    );
  }
}
