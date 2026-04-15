import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/services/firestore_service.dart';
import '../services/digital_gold_service.dart';
import '../../../common/widgets/custom_input_field.dart';
import '../../../common/widgets/gold_button.dart';
import 'buy_gold_screen.dart';
import 'convert_gold_screen.dart';
import 'transaction_history_screen.dart';

class DigitalGoldScreen extends StatefulWidget {
  const DigitalGoldScreen({Key? key}) : super(key: key);

  @override
  State<DigitalGoldScreen> createState() => _DigitalGoldScreenState();
}

class _DigitalGoldScreenState extends State<DigitalGoldScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DigitalGoldService _digitalGoldService = DigitalGoldService();
  final FirestoreService _firestoreService = FirestoreService();

  double goldBalance = 0.0;
  double goldPrice = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUserById(user.uid);
      if (userData != null && mounted) {
        setState(() {
          goldBalance = (userData['gold_balance'] ?? 0.0).toDouble();
        });
      }

      final price = await _digitalGoldService.getCurrentGoldPrice();
      if (mounted) {
        setState(() {
          goldPrice = price;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Emas Digital',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFFFD700),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.padding),
                children: [
                  // Saldo Card
                  _buildBalanceCard(),
                  const SizedBox(height: AppSpacing.spacingXLarge),

                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: AppSpacing.spacingXLarge),

                  // Transaction History
                  _buildTransactionHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    double portfolioValue = goldBalance * goldPrice;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Saldo Emas Digital',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B0B0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatGram(goldBalance),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '≈ ${CurrencyFormatter.formatRupiah(portfolioValue)}',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFB0B0B0),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingMedium,
              vertical: AppSpacing.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.show_chart,
                  size: 16,
                  color: Color(0xFFFFD700),
                ),
                const SizedBox(width: 4),
                Text(
                  'Harga: ${CurrencyFormatter.formatRupiah(goldPrice)}/gr',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        GoldButton(
          text: 'Beli Emas',
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BuyGoldScreen()),
            );
            if (result == true) {
              _loadData();
            }
          },
        ),
        const SizedBox(height: AppSpacing.spacingMedium),
        GoldButton(
          text: 'Cetak Emas (Konversi ke Fisik)',
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConvertGoldScreen()),
            );
            if (result == true) {
              _loadData();
            }
          },
          isSecondary: true,
        ),
        const SizedBox(height: AppSpacing.spacingMedium),
        GoldButton(
          text: 'Riwayat Transaksi',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
            );
          },
          isSecondary: true,
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    User? user = _auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaksi Terakhir',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.spacingMedium),
        StreamBuilder<QuerySnapshot>(
          stream: _digitalGoldService.getUserTransactions(user.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Terjadi kesalahan',
                  style: TextStyle(color: Colors.white),
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
              return Container(
                padding: const EdgeInsets.all(AppSpacing.padding),
                alignment: Alignment.center,
                child: const Text(
                  'Belum ada transaksi',
                  style: TextStyle(color: Color(0xFFB0B0B0)),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 5 ? 5 : transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index].data() as Map<String, dynamic>;
                return _buildTransactionItem(transaction);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    String type = transaction['type'] ?? 'digital';
    double amount = (transaction['gold_amount'] ?? 0.0).toDouble();
    String status = transaction['status'] ?? 'pending';
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
      child: Row(
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
          const SizedBox(width: AppSpacing.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type == 'digital' ? 'Beli Emas Digital' : 'Konversi ke Emas Fisik',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatDate(createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatGram(amount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
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
