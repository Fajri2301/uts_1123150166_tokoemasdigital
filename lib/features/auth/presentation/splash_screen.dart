import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toko_emas_digital/features/auth/services/auth_service.dart';
import 'package:toko_emas_digital/features/auth/presentation/login_screen.dart';
import 'package:toko_emas_digital/features/home/presentation/home_screen.dart';
import 'package:toko_emas_digital/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/color_extension.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Cek Role User: Admin atau User?
        String role = await _authService.getUserRole(user.uid);
        
        if (mounted) {
          if (role == 'admin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background.toColor(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.goldAccent.toColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.monetization_on,
                size: 60,
                color: AppColors.background.toColor(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Toko Emas Digital',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.goldAccent.toColor(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Investasi Emas Mudah & Aman',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.toColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
