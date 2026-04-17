import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/color_extension.dart';
import 'package:toko_emas_digital/features/auth/services/auth_service.dart';
import 'package:toko_emas_digital/features/auth/presentation/login_screen.dart';
import 'package:toko_emas_digital/common/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_emas_digital/common/widgets/admin_scaffold.dart';
import '../services/admin_service.dart';

// Import sub-screens
import 'admin_products_screen.dart';
import 'admin_transactions_screen.dart';
import 'admin_gold_price_screen.dart';
import 'admin_users_screen.dart';
import 'admin_categories_screen.dart';
import 'edit_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminHomeScreen(),
    const AdminProductsScreen(),
    const AdminTransactionsScreen(),
    const AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
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
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AdminService _adminService = AdminService();
  
  Map<String, int> _stats = {'products': 0, 'transactions': 0, 'users': 0};
  double _currentGoldPrice = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final stats = await _adminService.getDashboardStats();
      final price = await _adminService.getCurrentGoldPrice();
      if (mounted) {
        setState(() {
          _stats = stats;
          _currentGoldPrice = price;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.goldAccent.toColor(),
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang, Admin',
                style: TextStyle(color: AppColors.textPrimary.toColor(), fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildStatCard('Total Produk', _stats['products'].toString(), Icons.inventory_2_outlined, Colors.blue),
                      const SizedBox(height: 16),
                      _buildStatCard('Total Transaksi', _stats['transactions'].toString(), Icons.receipt_long, Colors.green),
                      const SizedBox(height: 16),
                      _buildStatCard('Harga Emas / gr', 'Rp ${_currentGoldPrice.toInt()}', Icons.trending_up, Colors.orange),
                      const SizedBox(height: 24),
                      
                      // Quick Actions
                      const Text(
                        'Aksi Cepat',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildQuickAction(context, 'Update Harga', Icons.price_change, () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGoldPriceScreen()));
                          }),
                          const SizedBox(width: 16),
                          _buildQuickAction(context, 'Kelola User', Icons.people_alt, () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildQuickAction(context, 'Kelola Kategori', Icons.category_outlined, () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCategoriesScreen()));
                          }),
                          const SizedBox(width: 16),
                          _buildQuickAction(context, 'Refresh Data', Icons.refresh, _loadDashboardData),
                        ],
                      ),
                    ],
                  ),
            ],
          ),
        ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.divider.toColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.goldAccent.toColor().withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.goldAccent.toColor()),
              const SizedBox(height: 8),
              Text(
                title, 
                style: const TextStyle(color: Colors.white, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.divider.toColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: AppColors.textSecondary.toColor(), fontSize: 14)),
              Text(value, style: TextStyle(color: AppColors.textPrimary.toColor(), fontSize: 22, fontWeight: FontWeight.bold)),
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

    return SingleChildScrollView(
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
            _buildMenuTile(Icons.person_outline, 'Edit Profil', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            }),
            _buildMenuTile(Icons.notifications_none, 'Pengaturan Notifikasi', () {}),
            _buildMenuTile(Icons.info_outline, 'Tentang Aplikasi', () {}),
            
            const SizedBox(height: 40),
            
            // Tombol Logout
            ListTile(
              onTap: () async {
                // Tambahkan dialog konfirmasi untuk keamanan
                bool? confirmLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1A1A1A),
                    title: const Text('Keluar Akun', style: TextStyle(color: Colors.white)),
                    content: const Text('Apakah Anda yakin ingin keluar dari panel admin?', style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal', style: TextStyle(color: Colors.white70)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Keluar', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );

                if (confirmLogout == true) {
                  try {
                    await authService.signOut();
                    if (context.mounted) {
                      // Gunakan Navigator secara eksplisit untuk pindah halaman
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal keluar: $e')),
                      );
                    }
                  }
                }
              },
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Keluar Akun', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.redAccent.withOpacity(0.1),
            ),
          ],
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
