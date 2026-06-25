import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/features/profile/services/user_service.dart';

class KycScreen extends StatefulWidget {
  final bool isVerified;

  const KycScreen({super.key, required this.isVerified});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final UserService _userService = UserService();
  bool _isLoading = false;

  Future<void> _verifyKYC() async {
    setState(() => _isLoading = true);
    try {
      await _userService.verifyKYC();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verifikasi KYC Berhasil!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100E0C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryGold),
        title: const Text(
          'Verifikasi Identitas (KYC)',
          style: TextStyle(fontFamily: 'Poppins', color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isVerified ? Icons.verified_user_rounded : Icons.admin_panel_settings_rounded,
              size: 100,
              color: widget.isVerified ? Colors.greenAccent : AppColors.primaryGold,
            ),
            const SizedBox(height: 24),
            Text(
              widget.isVerified ? 'Akun Terverifikasi' : 'Verifikasi Akun Anda',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isVerified 
                  ? 'Identitas Anda telah berhasil diverifikasi. Anda dapat menikmati seluruh fitur Danantara Gold tanpa batas.'
                  : 'Untuk mematuhi regulasi finansial dan membuka seluruh fitur penarikan dana, Anda wajib melakukan verifikasi identitas.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 48),
            if (!widget.isVerified)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyKYC,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink))
                      : const Text('Mulai Verifikasi', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
