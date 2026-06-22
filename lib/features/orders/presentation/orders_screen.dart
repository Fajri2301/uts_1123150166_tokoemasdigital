import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Daftar Pesanan',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: const Center(
        child: Text(
          'Belum ada pesanan.',
          style: TextStyle(color: AppColors.slate500, fontSize: 16),
        ),
      ),
    );
  }
}
