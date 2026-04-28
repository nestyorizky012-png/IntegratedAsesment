import 'package:flutter/material.dart';
import '../../core/routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.deepPurple.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.school_rounded, size: 80, color: Colors.deepPurple.shade900),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Selamat Datang',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Siapa Anda hari ini? Pilih peran Anda untuk masuk ke dalam sistem asesmen terintegrasi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade400),
                  ),
                  const SizedBox(height: 48),
                  
                  // KARTU SISWA
                  _buildRoleCard(
                    context,
                    title: 'Saya Siswa',
                    subtitle: 'Kerjakan asesmen dan raih portofolio Anda.',
                    icon: Icons.face_rounded,
                    color: Colors.deepPurple.shade900,
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.authGate);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // KARTU GURU
                  _buildRoleCard(
                    context,
                    title: 'Saya Guru / Admin',
                    subtitle: 'Kelola asesmen, bank soal, dan pantau nilai.',
                    icon: Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    textColor: Colors.deepPurple.shade900,
                    borderColor: Colors.deepPurple.shade100,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.adminLogin);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: color == Colors.white ? Colors.deepPurple.withOpacity(0.05) : color.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color == Colors.white ? Colors.deepPurple.shade50 : Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: textColor),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 32, color: textColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
