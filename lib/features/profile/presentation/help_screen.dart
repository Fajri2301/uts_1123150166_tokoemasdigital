import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100E0C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryGold),
        title: const Text(
          'Bantuan & Dukungan',
          style: TextStyle(fontFamily: 'Poppins', color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildFAQItem(
            'Bagaimana cara membeli emas?',
            'Anda dapat membeli emas melalui menu Portofolio lalu klik tombol "Beli", atau langsung dari Beranda dengan memilih produk Emas Digital.',
          ),
          _buildFAQItem(
            'Berapa lama proses pencairan dana (Withdraw)?',
            'Proses penarikan dana ke rekening bank Anda membutuhkan waktu maksimal 1x24 jam pada hari kerja.',
          ),
          _buildFAQItem(
            'Apakah investasi emas di Danantara aman?',
            'Tentu! Kami diawasi oleh lembaga regulasi resmi dan seluruh emas fisik Anda disimpan di brankas bersertifikasi tinggi.',
          ),
          const SizedBox(height: 48),
          const Text(
            'Butuh bantuan lebih lanjut?',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.headset_mic_rounded, color: AppColors.primaryGold, size: 32),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Customer Service', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary)),
                    SizedBox(height: 4),
                    Text('1500-888', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.1)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.primaryGold,
          collapsedIconColor: AppColors.textSecondary,
          title: Text(
            question,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
