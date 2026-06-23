import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/features/digital_gold/models/transaction_model.dart';
import 'package:toko_emas_digital/features/digital_gold/services/transaction_service.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService _transactionService = TransactionService();

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi Emas',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Terjadi kesalahan:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.red)),
              ),
            );
          }

          final transactions = snapshot.data ?? [];
          // Hanya filter transaksi emas digital
          final digitalTrx = transactions.where((t) => t.type == 'buy_digital' || t.type == 'sell_digital').toList();

          if (digitalTrx.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada transaksi emas digital.',
                style: TextStyle(color: AppColors.slate500, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.primary,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
            itemCount: digitalTrx.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final trx = digitalTrx[index];
              final isBuy = trx.type == 'buy_digital';
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.shadowSoft,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isBuy ? AppColors.greenSurface : AppColors.redSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBuy ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: isBuy ? AppColors.green : AppColors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBuy ? 'Pembelian Emas' : 'Penjualan Emas',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(trx.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isBuy ? '+' : '-'}${trx.grams.toStringAsFixed(3)} gr',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: isBuy ? AppColors.green : AppColors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(trx.totalPrice),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          );
        },
      ),
    );
  }
}
