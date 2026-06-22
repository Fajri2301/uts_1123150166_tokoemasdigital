import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../services/digital_gold_service.dart';
import '../../../common/widgets/app_button.dart';
import '../../../common/widgets/feature_icon.dart';
import 'buy_gold_screen.dart';
import 'convert_gold_screen.dart';
import 'transaction_history_screen.dart';

class DigitalGoldScreen extends StatefulWidget {
  const DigitalGoldScreen({super.key});

  @override
  State<DigitalGoldScreen> createState() => _DigitalGoldScreenState();
}

class _DigitalGoldScreenState extends State<DigitalGoldScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DigitalGoldService _digitalGoldService = DigitalGoldService();

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
      final balance = await _digitalGoldService.getBalance();
      final price = await _digitalGoldService.getCurrentGoldPrice();

      if (mounted) {
        setState(() {
          goldBalance = balance;
          goldPrice = price;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Emas Digital',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Saldo Card
                  _buildBalanceCard(),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 32),

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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.shadowCard,
      ),
      child: Column(
        children: [
          const Text(
            'Saldo Emas Digital Anda',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.formatGram(goldBalance),
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.greenSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '≈ ${CurrencyFormatter.formatRupiah(portfolioValue)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.line2),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.trending_up_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Harga Beli: ${CurrencyFormatter.formatRupiah(goldPrice)}/gr',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        AppButton(
          text: 'Beli Emas Digital',
          icon: Icons.add_circle_outline_rounded,
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BuyGoldScreen()),
            );
            if (result == true) _loadData();
          },
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'Cetak Emas (Konversi ke Fisik)',
          icon: Icons.print_rounded,
          variant: AppButtonVariant.outline,
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConvertGoldScreen()),
            );
            if (result == true) _loadData();
          },
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'Riwayat Transaksi Lengkap',
          icon: Icons.history_rounded,
          variant: AppButtonVariant.ghost,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
            );
          },
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
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _digitalGoldService.getUserTransactions(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Terjadi kesalahan', style: TextStyle(color: AppColors.red)),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line2),
                ),
                child: const Text(
                  'Belum ada transaksi',
                  style: TextStyle(color: AppColors.slate500, fontWeight: FontWeight.w500),
                ),
              );
            }

            final transactions = snapshot.data!;
            final displayCount = transactions.length > 5 ? 5 : transactions.length;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayCount,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
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
    double amount = (transaction['grams'] as num?)?.toDouble() ?? 0.0;
    String status = transaction['status'] ?? 'pending';
    
    DateTime createdAt;
    if (transaction['created_at'] != null) {
      createdAt = DateTime.parse(transaction['created_at']);
    } else {
      createdAt = DateTime.now();
    }

    String statusTone;
    String statusLabel = status.toUpperCase();
    switch (status) {
      case 'success':
      case 'selesai':
        statusTone = 'green';
        statusLabel = 'BERHASIL';
        break;
      case 'pending':
      case 'diproses':
        statusTone = 'gold';
        statusLabel = 'DIPROSES';
        break;
      case 'failed':
      case 'batal':
        statusTone = 'red';
        statusLabel = 'GAGAL';
        break;
      default:
        statusTone = 'slate';
    }

    String iconTone = type == 'buy_digital' ? 'gold' : 'blue';
    IconData icon = type == 'buy_digital' ? Icons.account_balance_wallet_rounded : Icons.diamond_rounded;
    String title = type == 'buy_digital' ? 'Beli Emas Digital' : 
                   type == 'physical_checkout' ? 'Pembelian Emas Fisik' : 'Konversi ke Emas Fisik';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.shadowSoft,
        border: Border.all(color: AppColors.line2),
      ),
      child: Row(
        children: [
          FeatureIcon(
            icon: icon,
            tone: iconTone,
            size: 40,
            iconSize: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatDate(createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.slate400,
                    fontWeight: FontWeight.w500,
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
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tone(statusTone, 100),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tone(statusTone, 600),
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
