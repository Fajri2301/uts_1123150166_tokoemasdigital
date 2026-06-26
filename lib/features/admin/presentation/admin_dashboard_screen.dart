import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/currency_formatter.dart';
import 'package:toko_emas_digital/features/auth/services/auth_service.dart';
import 'package:toko_emas_digital/features/auth/presentation/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/admin_service.dart';

// Import sub-screens
import 'admin_products_screen.dart';
import 'admin_transactions_screen.dart';
import 'admin_gold_price_screen.dart';
import 'admin_users_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminHomeScreen(),
      const AdminProductsScreen(),
      const AdminTransactionsScreen(),
      const AdminProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.primaryGold.withOpacity(0.15), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(1, Icons.inventory_2_rounded, Icons.inventory_2_outlined, 'Produk'),
                _buildNavItem(2, Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Transaksi'),
                _buildNavItem(3, Icons.manage_accounts_rounded, Icons.manage_accounts_outlined, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final bool isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryGold.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isActive ? activeIcon : inactiveIcon,
                  color: isActive ? AppColors.primaryGold : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.primaryGold : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// ADMIN HOME SCREEN — Dashboard dengan statistik
// ──────────────────────────────────────────────
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AdminService _adminService = AdminService();

  Map<String, int> _stats = {'products': 0, 'transactions': 0, 'users': 0};
  double _currentGoldPrice = 0.0;
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final stats = await _adminService.getDashboardStats();
      final price = await _adminService.getCurrentGoldPrice();
      final trxList = await _adminService.getAllTransactions();
      if (mounted) {
        setState(() {
          _stats = stats;
          _currentGoldPrice = price;
          _recentTransactions = trxList
              .take(5)
              .map((e) => e as Map<String, dynamic>)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppColors.primaryGold,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          slivers: [
            // ── HEADER ──
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: AppColors.surface,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final isScrolled = constraints.biggest.height <= (kToolbarHeight + MediaQuery.of(context).padding.top + 10);
                  return FlexibleSpaceBar(
                    centerTitle: true,
                    title: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isScrolled ? 1.0 : 0.0,
                      child: const Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.surface,
                        AppColors.primaryGold.withOpacity(0.08),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primaryGold, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.darkGray,
                                  child: Icon(Icons.admin_panel_settings_rounded,
                                      color: AppColors.primaryGold, size: 24),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selamat Datang 👋',
                                      style: TextStyle(
                                          color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                    Text(
                                      user?.displayName ?? 'Administrator',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.verified_rounded, color: AppColors.primaryGold, size: 14),
                                    const SizedBox(width: 4),
                                    Text('ADMIN', style: TextStyle(
                                      color: AppColors.primaryGold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Gold Price Ticker
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                AppColors.primaryGold.withOpacity(0.2),
                                AppColors.primaryGold.withOpacity(0.05),
                              ]),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.trending_up_rounded, color: AppColors.primaryGold, size: 18),
                                const SizedBox(width: 8),
                                Text('Harga Emas Live: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                Text(
                                  _currentGoldPrice > 0
                                      ? CurrencyFormatter.formatRupiah(_currentGoldPrice)
                                      : '---',
                                  style: TextStyle(
                                    color: AppColors.primaryGold,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text('/gram', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                    ),
                  );
                },
              ),
            ),

            // ── BODY ──
            SliverToBoxAdapter(
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFFB38922))),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stat Cards Grid
                          Row(
                            children: [
                              _StatCard(
                                label: 'Total Produk',
                                value: _stats['products'].toString(),
                                icon: Icons.inventory_2_rounded,
                                color: AppColors.primaryGold,
                                subtitle: 'item tersedia',
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                label: 'Total Pengguna',
                                value: _stats['users'].toString(),
                                icon: Icons.people_alt_rounded,
                                color: AppColors.info,
                                subtitle: 'terdaftar',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _StatCardWide(
                            label: 'Total Transaksi',
                            value: _stats['transactions'].toString(),
                            icon: Icons.receipt_long_rounded,
                            color: AppColors.success,
                            subtitle: 'semua transaksi tercatat',
                          ),

                          const SizedBox(height: 24),

                          // Quick Menu
                          const _SectionTitle(title: 'Menu Cepat'),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.0,
                            children: [
                              _QuickMenuTile(
                                icon: Icons.price_change_rounded,
                                label: 'Update\nHarga',
                                color: AppColors.primaryGold,
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const AdminGoldPriceScreen())),
                              ),
                              _QuickMenuTile(
                                icon: Icons.people_alt_rounded,
                                label: 'Kelola\nUser',
                                color: AppColors.info,
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const AdminUsersScreen())),
                              ),
                              _QuickMenuTile(
                                icon: Icons.category_rounded,
                                label: 'Kelola\nKategori',
                                color: AppColors.violet,
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const AdminCategoriesScreen())),
                              ),
                              _QuickMenuTile(
                                icon: Icons.inventory_2_rounded,
                                label: 'Kelola\nProduk',
                                color: AppColors.warning,
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const AdminProductsScreen())),
                              ),
                              _QuickMenuTile(
                                icon: Icons.campaign_rounded,
                                label: 'Broadcast\nNotif',
                                color: AppColors.success,
                                onTap: () => _showBroadcastDialog(context),
                              ),
                              _QuickMenuTile(
                                icon: Icons.refresh_rounded,
                                label: 'Refresh\nData',
                                color: AppColors.textSecondary,
                                onTap: _loadDashboardData,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Recent Transactions
                          const _SectionTitle(title: 'Transaksi Terbaru'),
                          const SizedBox(height: 12),
                          if (_recentTransactions.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text('Belum ada transaksi',
                                  style: TextStyle(color: AppColors.textSecondary)),
                            )
                          else
                            ..._recentTransactions.map((trx) => _RecentTrxTile(trx: trx)),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBroadcastDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.campaign_rounded, color: AppColors.primaryGold),
                const SizedBox(width: 8),
                const Text('Broadcast Notifikasi',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            _InputField(controller: titleCtrl, hint: 'Judul notifikasi', label: 'Judul'),
            const SizedBox(height: 12),
            _InputField(controller: bodyCtrl, hint: 'Isi pesan...', label: 'Pesan', maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Kirim ke Semua User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (titleCtrl.text.isEmpty || bodyCtrl.text.isEmpty) return;
                  Navigator.pop(ctx);
                  try {
                    await _adminService.broadcastNotification(titleCtrl.text, bodyCtrl.text);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifikasi berhasil dikirim!'),
                          backgroundColor: Color(0xFF22C55E),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Widgets ──

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 18,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(color: AppColors.primaryGold, borderRadius: BorderRadius.circular(2))),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, subtitle;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon,
      required this.color, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Text(subtitle, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _StatCardWide extends StatelessWidget {
  final String label, value, subtitle;
  final IconData icon;
  final Color color;
  const _StatCardWide({required this.label, required this.value, required this.icon,
      required this.color, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text(subtitle, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickMenuTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTrxTile extends StatelessWidget {
  final Map<String, dynamic> trx;
  const _RecentTrxTile({required this.trx});

  @override
  Widget build(BuildContext context) {
    final String type = trx['type'] ?? '';
    final String status = trx['status'] ?? 'pending';
    final double total = (trx['total_price'] as num?)?.toDouble() ?? 0;

    Color statusColor = AppColors.warning;
    if (status == 'success' || status == 'selesai') statusColor = AppColors.success;
    if (status == 'failed') statusColor = AppColors.error;

    String typeLabel = type == 'buy_digital' ? 'Beli Emas Digital'
        : type == 'sell_digital' ? 'Jual Emas Digital'
        : type == 'physical_checkout' ? 'Beli Emas Fisik'
        : type == 'withdraw_cash' ? 'Tarik Dana'
        : type;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.swap_horiz_rounded, color: AppColors.primaryGold, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(typeLabel, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text('ID: ${trx['id']} • User: ${trx['user_id']}',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(CurrencyFormatter.formatRupiah(total),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint, label;
  final int maxLines;
  const _InputField({required this.controller, required this.hint, required this.label, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.darkGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primaryGold),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.darkGray),
            ),
          ),
        ),
      ],
    );
  }
}
