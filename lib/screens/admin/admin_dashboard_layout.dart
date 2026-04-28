import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes.dart';
import 'integrated_assessment_form.dart';
import 'admin_dashboard_home.dart';

class AdminDashboardLayout extends StatefulWidget {
  const AdminDashboardLayout({super.key});

  @override
  State<AdminDashboardLayout> createState() => _AdminDashboardLayoutState();
}

class _AdminDashboardLayoutState extends State<AdminDashboardLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardHome(),
    const IntegratedAssessmentForm(),
  ];

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Akun Guru?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Keluar')),
        ],
      )
    );
    if (confirm != true) return;
    
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
    
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.adminLogin); // or Role Selection
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    if (isDesktop) {
      // DESKTOP LAYOUT (NavigationRail)
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: Colors.deepPurple.shade900,
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
              selectedIconTheme: const IconThemeData(color: Colors.amber),
              selectedLabelTextStyle: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              extended: true,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() => _selectedIndex = index);
              },
              leading: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.admin_panel_settings, size: 48, color: Colors.amber),
                    SizedBox(height: 8),
                    Text('Portal Guru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      onPressed: _logout,
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_add),
                  selectedIcon: Icon(Icons.assignment_turned_in),
                  label: Text('Input Asesmen'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _pages[_selectedIndex])
          ],
        ),
      );
    } else {
      // MOBILE LAYOUT (BottomNavigationBar)
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Portal Guru', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.deepPurple.shade900,
          foregroundColor: Colors.white,
          actions: [
            IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: _logout)
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple.shade900,
          unselectedItemColor: Colors.deepPurple.shade200,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_add), activeIcon: Icon(Icons.assignment_turned_in), label: 'Input Asesmen'),
          ],
        ),
      );
    }
  }
}
