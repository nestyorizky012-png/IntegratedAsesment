import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';

import 'package:provider/provider.dart';
import '../../providers/user_profile_provider.dart';
import '../profile/profile_screen.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<UserProfileProvider>().setFromAuth(
              uid: user.uid,
              email: user.email ?? '-',
            );
          });

          final profile = context.watch<UserProfileProvider>().profile;

// kalau profil belum ada/ belum lengkap → arahkan ke profil
          if (profile == null || !profile.isComplete) {
            return const ProfileScreen();
          }
        // sudah login
        return const DashboardScreen();
      },
    );
  }
}
