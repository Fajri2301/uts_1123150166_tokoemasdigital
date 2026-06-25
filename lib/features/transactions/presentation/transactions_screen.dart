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
  String _selectedFilter = 'Semua';
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _transactionService.getTransactions();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _transactionsFuture = _transactionService.getTransactions();
    });
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF080808),
      ),
      child: Stack(
        children: [
          // Radial Glow Background
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGold.withValues(alpha: 0.08),
                    const Color(0xFF832525).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
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
                'Riwayat Transaksi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8).copyWith(bottom: 12),
                  child: Row(
                    children: [
                      _buildFilterChip('Semua'),
                      _buildFilterChip('Pembelian'),
                      _buildFilterChip('Penjualan'),
                      _buildFilterChip('Konversi'),
                    ],
                  ),
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

                var transactions = snapshot.data ?? [];
                
                // Filter logic
                if (_selectedFilter == 'Pembelian') {
                  transactions = transactions.where((t) => t.type == 'buy_digital').toList();
                } else if (_selectedFilter == 'Penjualan') {
                  transactions = transactions.where((t) => t.type == 'sell_digital').toList();
                } else if (_selectedFilter == 'Konversi') {
                  transactions = transactions.where((t) => t.type == 'physical_checkout').toList();
                }

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada transaksi.',
                      style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: AppColors.primaryGold,
                  backgroundColor: AppColors.surface,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8).copyWith(bottom: 120),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final trx = transactions[index];
                      return _buildTransactionItem(trx);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGold.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.primaryGold : Colors.white.withValues(alpha: 0.05),
          ),
          boxShadow: isActive
              ? [BoxShadow(color: AppColors.primaryGold.withValues(alpha: 0.4), blurRadius: 12)]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.primaryGold : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel trx) {
    final isBuy = trx.type == 'buy_digital';
    final isSell = trx.type == 'sell_digital';
    final isConvert = trx.type == 'physical_checkout';

    String title = 'Transaksi';
    IconData icon = Icons.sync_alt_rounded;
    Color iconColor = Colors.white;
    Color iconBg = Colors.white.withValues(alpha: 0.1);
    Color glowColor = Colors.transparent;
    
    if (isBuy) {
      title = 'Pembelian Emas';
      icon = Icons.arrow_downward_rounded;
      iconColor = Colors.greenAccent;
      iconBg = Colors.greenAccent.withValues(alpha: 0.1);
      glowColor = Colors.greenAccent;
    } else if (isSell) {
      title = 'Penjualan Emas';
      icon = Icons.arrow_upward_rounded;
      iconColor = Colors.redAccent;
      iconBg = Colors.redAccent.withValues(alpha: 0.1);
      glowColor = Colors.redAccent;
    } else if (isConvert) {
      title = 'Konversi Emas Fisik';
      icon = Icons.inventory_2_rounded;
      iconColor = AppColors.primaryGold;
      iconBg = AppColors.primaryGold.withValues(alpha: 0.1);
      glowColor = AppColors.primaryGold;
    }

    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Override colors if status is not success
    final isPending = trx.status == 'pending';
    final isFailed = trx.status == 'failed';
    
    if (isPending) {
      iconColor = Colors.orangeAccent;
      iconBg = Colors.orangeAccent.withValues(alpha: 0.1);
      glowColor = Colors.orangeAccent;
    } else if (isFailed) {
      iconColor = Colors.grey;
      iconBg = Colors.grey.withValues(alpha: 0.1);
      glowColor = Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.darkGray.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBg,
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(color: glowColor.withValues(alpha: 0.2), blurRadius: 15),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isFailed ? AppColors.textSecondary : Colors.white,
                        ),
                      ),
                    ),
                    if (isPending) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orangeAccent),
                        ),
                        child: const Text('Pending', style: TextStyle(fontSize: 9, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    if (isFailed) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Text('Gagal', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(trx.createdAt),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isSell ? '-' : isConvert ? '-' : '+'}${CurrencyFormatter.formatGram(trx.grams)}',
                style: TextStyle(
                  fontFamily: 'Roboto Mono',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFailed 
                      ? AppColors.textSecondary 
                      : (isPending ? Colors.orangeAccent : (isSell || isConvert ? Colors.redAccent : Colors.greenAccent)),
                  decoration: isFailed ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(trx.totalPrice),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: isFailed ? AppColors.textSecondary.withValues(alpha: 0.5) : AppColors.primaryGold.withValues(alpha: 0.7),
                  decoration: isFailed ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
