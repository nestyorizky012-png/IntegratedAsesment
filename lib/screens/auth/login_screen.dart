import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _passConfirm = TextEditingController();
  bool _loading = false;
  bool _isLogin = true;
  bool _obscurePass = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _passConfirm.dispose();
    super.dispose();
  }

  Future<void> _loginOrRegister({required bool register}) async {
    final email = _email.text.trim();
    final pass = _pass.text.trim();
    final passConfirm = _passConfirm.text.trim();

    if (email.isEmpty || pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email wajib diisi, password minimal 6 karakter.')),
      );
      return;
    }

    if (register && pass != passConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok dengan password yang dimasukkan.')),
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', 'student');
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or Icon
                const Icon(
                  Icons.assessment_rounded,
                  size: 100,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 24),
                
                // Welcome Text
                Text(
                  _isLogin ? 'Selamat Datang' : 'Daftar Akun',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin 
                    ? 'Masuk ke Integrated Assessment untuk melanjutkan'
                    : 'Buat akun untuk memulai Integrated Assessment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                const SizedBox(height: 48),

                // Email Field
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _pass,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                    labelText: 'Password (min 6 karakter)',
                  ),
                ),

                if (!_isLogin) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passConfirm,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                      labelText: 'Konfirmasi Password',
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                // Action Button
                FilledButton(
                  onPressed: _loading ? null : () => _loginOrRegister(register: !_isLogin),
                  child: _loading 
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        ) 
                      : Text(
                          _isLogin ? 'Login' : 'Mendaftar',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),

                // Toggle Button
                TextButton(
                  onPressed: _loading ? null : () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory, // Subtle click
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: _isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                      ),
                      children: [
                        TextSpan(
                          text: _isLogin ? 'Daftar Sekarang' : 'Login di sini',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Removed Admin Portal Link
              ],
            ),
          ),
        ),
      ),
    );
  }
}
