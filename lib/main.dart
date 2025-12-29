import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/routes.dart';
import 'providers/assessment_provider.dart';
import 'providers/user_profile_provider.dart';

import 'screens/dashboard/dashboard_screen.dart';
import 'screens/assessment/assessment_screen.dart';
import 'screens/result/result_screen.dart';
import 'screens/reflection/reflection_screen.dart';
import 'screens/portfolio/portfolio_screen.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/profile/profile_screen.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Asesmen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
      routes: {
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.assessment: (_) => const AssessmentScreen(),
        AppRoutes.result: (_) => const ResultScreen(),
        AppRoutes.reflection: (_) => const ReflectionScreen(),
        AppRoutes.portfolio: (_) => const PortfolioScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },
    );
  }
}
