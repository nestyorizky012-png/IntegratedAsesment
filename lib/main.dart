import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'core/routes.dart';
import 'providers/assessment_provider.dart';
import 'providers/user_profile_provider.dart';

import 'screens/dashboard/dashboard_screen.dart';
import 'screens/assessment/assessment_screen.dart';
import 'screens/result/result_screen.dart';
import 'screens/reflection/reflection_screen.dart';
import 'screens/understanding/understanding_screen.dart';
import 'screens/portfolio/portfolio_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/settings/app_info_screen.dart';
import 'screens/profile/profile_screen.dart';

import 'screens/auth/role_selection_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_layout.dart';
import 'screens/admin/admin_results_screen.dart';


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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        scaffoldBackgroundColor: Colors.white,

        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme(),

        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple.shade900,
          iconTheme: const IconThemeData(color: Colors.deepPurple),
        ),

        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.white,
          shadowColor: Colors.deepPurple.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.deepPurple.shade50, width: 1),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.deepPurple.shade50.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          prefixIconColor: Colors.deepPurple,
        ),
        
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.deepPurple,
            side: const BorderSide(color: Colors.deepPurple, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),

      home: const SplashScreen(),
      routes: {
        AppRoutes.roleSelection: (_) => const RoleSelectionScreen(),
        AppRoutes.authGate: (_) => const AuthGate(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.understanding: (_) => const UnderstandingScreen(),
        AppRoutes.assessment: (_) => const AssessmentScreen(),
        AppRoutes.result: (_) => const ResultScreen(),
        AppRoutes.reflection: (_) => const ReflectionScreen(),
        AppRoutes.portfolio: (_) => const PortfolioScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.appInfo: (_) => const AppInfoScreen(),
        
        // ADMIN ROUTES
        AppRoutes.adminLogin: (_) => const AdminLoginScreen(),
        AppRoutes.adminDashboard: (_) => const AdminDashboardLayout(),
        AppRoutes.adminResults: (_) => const AdminResultsScreen(),
      },
    );
  }
}
