import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/features/digital_gold/models/transaction_model.dart';
import 'package:toko_emas_digital/features/digital_gold/services/transaction_service.dart';
import 'package:toko_emas_digital/features/orders/presentation/track_order_screen.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  final TransactionService _transactionService = TransactionService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _transactionService.getTransactions();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF151311),
      ),
      child: Stack(
        children: [
          // Radial Glow
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryGold.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    center: const Alignment(0, 0),
                    radius: 1.0,
                  ),
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Pesanan Emas Fisik',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
            body: FutureBuilder<List<TransactionModel>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('Terjadi kesalahan:\n${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
                    ),
                  );
                }

                final transactions = snapshot.data ?? [];
                final physicalTrx = transactions.where((t) => t.type == 'physical_checkout').toList();

                if (physicalTrx.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada pelacakan pesanan fisik.',
                      style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(20).copyWith(bottom: 120),
                  children: [
                    // Live Status Intro
                    _buildLiveStatusHeader(),
                    const SizedBox(height: 24),
                    // Orders List
                    ...physicalTrx.map((trx) => _buildOrderCard(trx)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FadeTransition(
              opacity: _pulseAnimation,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'STATUS REAL-TIME',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Pantau Kilau Investasimu',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Emas fisik Anda sedang dalam proses verifikasi kualitas sebelum dikirimkan oleh kurir berasuransi.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(TransactionModel trx) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF262626).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: AppColors.primaryGold.withValues(alpha: 0.05), blurRadius: 24),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ID TRANSAKSI', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('Order #${trx.id}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryGold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.2), blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('Diproses', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueAccent, letterSpacing: -0.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGold, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryGold.withValues(alpha: 0.2), blurRadius: 16),
                  ],
                ),
                child: const Icon(Icons.inventory_2_rounded, color: AppColors.ink, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ALAMAT PENGIRIMAN', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(
                      trx.address ?? 'Alamat tidak tersedia',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: AppColors.primaryGold.withValues(alpha: 0.2)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('METODE PEMBAYARAN', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.payments_rounded, color: AppColors.primaryGold, size: 16),
                  const SizedBox(width: 8),
                  Text(trx.paymentMethod, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('TOTAL NOMINAL', style: TextStyle(fontFamily: 'Roboto Mono', fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(currencyFormat.format(trx.totalPrice), style: const TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.primaryGold)),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TrackOrderScreen(transaction: trx)));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryGold),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.local_shipping_rounded, color: AppColors.primaryGold, size: 16),
                        SizedBox(width: 8),
                        Text('Lacak Paket', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryGold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
