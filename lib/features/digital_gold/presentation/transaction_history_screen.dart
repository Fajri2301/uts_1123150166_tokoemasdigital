import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../services/digital_gold_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _digitalGoldService = DigitalGoldService();

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Silakan login terlebih dahulu',
                style: TextStyle(color: Color(0xFFB0B0B0)),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _digitalGoldService.getUserTransactions(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Terjadi kesalahan: ${snapshot.error}',
                      style: const TextStyle(color: Color(0xFFF44336)),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    ),
                  );
                }

                final transactions = snapshot.data!.docs;

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada transaksi',
                      style: TextStyle(color: Color(0xFFB0B0B0)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.padding),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index].data() as Map<String, dynamic>;
                    return _buildTransactionCard(transaction);
                  },
                );
              },
            ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    String type = transaction['type'] ?? 'digital';
    double amount = (transaction['gold_amount'] ?? 0.0).toDouble();
    String status = transaction['status'] ?? 'pending';
    double? totalPrice = transaction['total_price'];
    DateTime createdAt = (transaction['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();

    Color statusColor;
    switch (status) {
      case 'selesai':
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'diproses':
        statusColor = const Color(0xFFFFD700);
        break;
      case 'dikirim':
        statusColor = const Color(0xFF2196F3);
        break;
      default:
        statusColor = const Color(0xFFB0B0B0);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.spacingMedium),
      padding: const EdgeInsets.all(AppSpacing.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: type == 'digital'
                      ? const Color(0xFFFFD700).withOpacity(0.15)
                      : const Color(0xFF2196F3).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  type == 'digital' ? Icons.account_balance_wallet : Icons.diamond,
                  size: 20,
                  color: type == 'digital' ? const Color(0xFFFFD700) : const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type == 'digital' ? 'Beli Emas Digital' : 'Konversi ke Emas Fisik',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jumlah',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB0B0B0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatGram(amount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
              if (totalPrice != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB0B0B0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatRupiah(totalPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatDate(createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB0B0B0),
            ),
          ),
        ],
      ),
    );
  }
}
