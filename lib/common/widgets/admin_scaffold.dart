import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/color_extension.dart';
import 'package:toko_emas_digital/features/admin/presentation/admin_products_screen.dart';
import 'package:toko_emas_digital/features/admin/presentation/admin_transactions_screen.dart';
import 'package:toko_emas_digital/features/admin/presentation/admin_users_screen.dart';
import 'package:toko_emas_digital/features/admin/presentation/admin_categories_screen.dart';
import 'package:toko_emas_digital/features/admin/presentation/admin_gold_price_screen.dart';

class AdminScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const AdminScaffold({
    Key? key,
    required this.body,
    this.title = 'Admin Panel',
    this.actions,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background.toColor(),
      // Persistent AppBar (Navbar)
      appBar: AppBar(
        backgroundColor: AppColors.divider.toColor(),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.goldAccent.toColor(),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.stars, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'TokoEmas',
              style: TextStyle(
                color: AppColors.goldAccent.toColor(),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        leading: showBackButton 
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Belum ada notifikasi baru')),
              );
            },
          ),
          ...?(actions),
          // Sidebar Toggle
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      // Drawer (Sidebar)
      endDrawer: _buildSidebar(context),
      body: body,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.divider.toColor(),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.goldAccent.toColor(),
                    child: const Icon(Icons.admin_panel_settings, size: 40, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Administrator',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context, 
                  Icons.dashboard_outlined, 
                  'Dashboard', 
                  null // Go back or home
                ),
                const Divider(color: Colors.white10),
                _buildDrawerItem(
                  context, 
                  Icons.inventory_2_outlined, 
                  'Kelola Produk', 
                  const AdminProductsScreen()
                ),
                _buildDrawerItem(
                  context, 
                  Icons.category_outlined, 
                  'Kelola Kategori', 
                  const AdminCategoriesScreen()
                ),
                _buildDrawerItem(
                  context, 
                  Icons.receipt_long_outlined, 
                  'Kelola Transaksi', 
                  const AdminTransactionsScreen()
                ),
                _buildDrawerItem(
                  context, 
                  Icons.people_alt_outlined, 
                  'Kelola User', 
                  const AdminUsersScreen()
                ),
                _buildDrawerItem(
                  context, 
                  Icons.price_change_outlined, 
                  'Update Harga Emas', 
                  const AdminGoldPriceScreen()
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'v1.0.0',
              style: TextStyle(color: AppColors.textSecondary.toColor(), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget? screen) {
    return ListTile(
      leading: Icon(icon, color: AppColors.goldAccent.toColor()),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        } else {
          // If dashboard, we might want special handling depending on context
        }
      },
    );
  }
}
