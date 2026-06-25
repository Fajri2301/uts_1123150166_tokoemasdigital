import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/features/auth/services/auth_service.dart';
import 'package:toko_emas_digital/features/auth/presentation/login_screen.dart';
import 'package:toko_emas_digital/common/widgets/app_avatar.dart';
import 'package:toko_emas_digital/features/digital_gold/services/transaction_service.dart';
import 'package:toko_emas_digital/features/profile/services/user_service.dart';
import 'package:toko_emas_digital/features/profile/presentation/security_pin_screen.dart';
import 'package:toko_emas_digital/features/profile/presentation/bank_account_screen.dart';
import 'package:toko_emas_digital/features/profile/presentation/kyc_screen.dart';
import 'package:toko_emas_digital/features/profile/presentation/help_screen.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, double>> _walletFuture;
  final UserService _userService = UserService();
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _walletFuture = TransactionService().getWalletBalance();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await _userService.getProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Keluar Sesi', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Investor Danantara';
    final userEmail = user?.email ?? 'investor@danantara.id';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF100E0C),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Akun Saya',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_rounded, color: AppColors.primaryGold),
              onPressed: () {},
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16).copyWith(bottom: 120),
          children: [
            // Profile Hero Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4), width: 2),
                          boxShadow: [
                            BoxShadow(color: AppColors.primaryGold.withValues(alpha: 0.4), blurRadius: 15),
                            BoxShadow(color: AppColors.primaryGold.withValues(alpha: 0.2), blurRadius: 10),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: AppAvatar(name: userName, size: 110, bg: Colors.transparent),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8),
                            ],
                          ),
                          child: const Icon(Icons.verified_rounded, color: AppColors.ink, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.workspace_premium_rounded, color: AppColors.primaryGold, size: 16),
                        SizedBox(width: 4),
                        Text('ELITE MEMBER', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGold, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Wallet Summary Card
            _buildWalletSummaryCard(),

            const SizedBox(height: 48),

            // Account Menu
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text('Preferensi Akun', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF262626).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
              ),
              child: _isLoadingProfile 
                ? const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: AppColors.primaryGold)))
                : Column(
                children: [
                  _buildMenuTile(
                    Icons.security_rounded, 
                    'Keamanan',
                    onTap: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPinScreen()));
                      if (result == true) _fetchProfile();
                    },
                    trailingText: _userProfile?['has_pin'] == true ? 'PIN AKTIF' : 'BUAT PIN',
                    trailingColor: _userProfile?['has_pin'] == true ? Colors.greenAccent : Colors.redAccent,
                  ),
                  Divider(height: 1, color: AppColors.primaryGold.withValues(alpha: 0.05)),
                  _buildMenuTile(
                    Icons.account_balance_rounded, 
                    'Rekening Bank',
                    onTap: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => BankAccountScreen(
                        initialBankName: _userProfile?['bank_name'] ?? '',
                        initialBankAccount: _userProfile?['bank_account'] ?? '',
                      )));
                      if (result == true) _fetchProfile();
                    },
                    trailingText: (_userProfile?['bank_account']?.toString().isNotEmpty ?? false) ? 'TERDAFTAR' : 'BELUM ADA',
                    trailingColor: (_userProfile?['bank_account']?.toString().isNotEmpty ?? false) ? AppColors.primaryGold : Colors.redAccent,
                  ),
                  Divider(height: 1, color: AppColors.primaryGold.withValues(alpha: 0.05)),
                  _buildMenuTile(
                    Icons.assignment_ind_rounded, 
                    'Verifikasi KYC', 
                    trailingText: _userProfile?['kyc_status'] == 'verified' ? 'TERVERIFIKASI' : 'BELUM VERIFIKASI', 
                    trailingColor: _userProfile?['kyc_status'] == 'verified' ? Colors.greenAccent : AppColors.textSecondary,
                    onTap: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KycScreen(
                        isVerified: _userProfile?['kyc_status'] == 'verified',
                      )));
                      if (result == true) _fetchProfile();
                    },
                  ),
                  Divider(height: 1, color: AppColors.primaryGold.withValues(alpha: 0.05)),
                  _buildMenuTile(
                    Icons.help_center_rounded, 
                    'Bantuan',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Logout Button
            GestureDetector(
              onTap: () => _handleLogout(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: Colors.redAccent.withValues(alpha: 0.1), blurRadius: 12),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout_rounded, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Keluar Sesi', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Versi 2.4.0 • Danantara Gold Digital',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.textSecondary, letterSpacing: 1.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSummaryCard() {
    return FutureBuilder<Map<String, double>>(
      future: _walletFuture,
      builder: (context, snapshot) {
        final balances = snapshot.data ?? {'grams': 0.0, 'rupiah': 0.0};
        final grams = balances['grams']!;
        final rupiah = balances['rupiah']!;
        final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF262626).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(color: AppColors.primaryGold.withValues(alpha: 0.05), blurRadius: 25),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.account_balance_wallet_rounded, color: AppColors.textSecondary, size: 14),
                      SizedBox(width: 8),
                      Text('Total Saldo', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 150,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(currencyFormat.format(rupiah), style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('GOLD EQUIV.', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 10, color: AppColors.primaryLightGold, letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text('${grams.toStringAsFixed(3)} g', style: const TextStyle(fontFamily: 'Roboto Mono', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {String? trailingText, Color? trailingColor, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryGold, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.white)),
                  if (trailingText != null) ...[
                    const SizedBox(height: 4),
                    Text(trailingText, style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 10, fontWeight: FontWeight.bold, color: trailingColor, letterSpacing: 1.0)),
                  ]
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.primaryGold.withValues(alpha: 0.4), size: 24),
          ],
        ),
      ),
    );
  }
}
