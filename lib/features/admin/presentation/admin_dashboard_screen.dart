import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/color_extension.dart';
import 'package:toko_emas_digital/features/auth/services/auth_service.dart';
import 'package:toko_emas_digital/features/auth/presentation/login_screen.dart';
import 'package:toko_emas_digital/common/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import sub-screens
import 'admin_products_screen.dart';
import 'add_edit_product_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminHomeScreen(),
    const AddEditProductScreen(),
    const AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background.toColor(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.divider.toColor(),
        selectedItemColor: AppColors.goldAccent.toColor(),
        unselectedItemColor: AppColors.textSecondary.toColor(),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// --- SUB SCREEN 1: HOME ADMIN ---
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background.toColor(),
      appBar: const CustomAppBar(title: 'Panel Admin', showBackButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatCard('Total Produk', '12', Icons.inventory_2_outlined),
            const SizedBox(height: 16),
            _buildStatCard('Transaksi Pending', '5', Icons.pending_actions),
            const SizedBox(height: 16),
            _buildStatCard('Harga Emas Hari Ini', 'Rp 1.230.000', Icons.trending_up),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.divider.toColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.goldAccent.toColor(), size: 30),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: AppColors.textSecondary.toColor(), fontSize: 14)),
              Text(value, style: TextStyle(color: AppColors.textPrimary.toColor(), fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- SUB SCREEN 3: PROFIL ADMIN ---
class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();

    return Scaffold(
      backgroundColor: AppColors.background.toColor(),
      appBar: const CustomAppBar(title: 'Profil Admin', showBackButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Profil
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.goldAccent.toColor(),
                    child: const Icon(Icons.person, size: 50, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'Administrator',
                    style: TextStyle(color: AppColors.textPrimary.toColor(), fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? 'admin@tokoemas.com',
                    style: TextStyle(color: AppColors.textSecondary.toColor(), fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Menu Pengaturan
            _buildMenuTile(Icons.edit_outlined, 'Edit Nama', () {}),
            _buildMenuTile(Icons.email_outlined, 'Edit Email', () {}),
            _buildMenuTile(Icons.lock_outline, 'Keamanan & Password', () {}),
            _buildMenuTile(Icons.notifications_none, 'Pengaturan Notifikasi', () {}),
            _buildMenuTile(Icons.info_outline, 'Tentang Aplikasi', () {}),
            
            const SizedBox(height: 40),
            
            // Tombol Logout
            ListTile(
              onTap: () async {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Keluar Akun', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.redAccent.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.goldAccent.toColor()),
          title: Text(title, style: TextStyle(color: AppColors.textPrimary.toColor())),
          trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary.toColor(), size: 16),
        ),
        Divider(color: AppColors.divider.toColor(), height: 1),
      ],
    );
  }
}
