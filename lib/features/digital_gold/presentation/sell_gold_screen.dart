import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/currency_formatter.dart';
import 'package:toko_emas_digital/common/widgets/app_button.dart';
import 'package:toko_emas_digital/common/widgets/app_field.dart';
import 'package:toko_emas_digital/common/widgets/feature_icon.dart';
import 'package:toko_emas_digital/features/digital_gold/services/transaction_service.dart';

class SellGoldScreen extends StatefulWidget {
  const SellGoldScreen({super.key});

  @override
  State<SellGoldScreen> createState() => _SellGoldScreenState();
}

class _SellGoldScreenState extends State<SellGoldScreen> {
  final _gramController = TextEditingController();
  final _transactionService = TransactionService();
  
  double _pricePerGram = 1150000.0; // Harga jual
  double _currentBalance = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balances = await _transactionService.getWalletBalance();
    if (mounted) {
      setState(() {
        _currentBalance = balances['grams'] ?? 0.0;
      });
    }
  }

  @override
  void dispose() {
    _gramController.dispose();
    super.dispose();
  }

  void _handleSell() async {
    final gramsText = _gramController.text.trim();
    if (gramsText.isEmpty) return;
    
    final grams = double.tryParse(gramsText);
    if (grams == null || grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan jumlah gram yang valid')));
      return;
    }

    if (grams > _currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saldo emas Anda tidak mencukupi')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _transactionService.sellDigitalGold(grams);
      
      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3))),
            title: const Center(
              child: FeatureIcon(icon: Icons.check_circle_rounded, tone: 'green', size: 70, iconSize: 40),
            ),
            content: Text(
              'Penjualan ${grams.toStringAsFixed(3)} gr Emas Digital berhasil!\nDana telah ditransfer ke rekening Anda.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Poppins', color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
            ),
            actions: [
              AppButton(
                label: 'Kembali ke Beranda',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final grams = double.tryParse(_gramController.text) ?? 0.0;
    final totalPrice = grams * _pricePerGram;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tukar Saldo ke Uang Tunai', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkGray)),
                    child: Column(
                      children: [
                        const Text('Harga Jual Saat Ini', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${CurrencyFormatter.formatRupiah(_pricePerGram)} / gr', style: const TextStyle(fontFamily: 'Roboto Mono', color: AppColors.primaryLightGold, fontSize: 15, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.darkGray)),
                    child: Column(
                      children: [
                        const Text('Saldo Emas Anda', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${_currentBalance.toStringAsFixed(3)} gr', style: const TextStyle(fontFamily: 'Roboto Mono', color: AppColors.primaryLightGold, fontSize: 16, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Jumlah Penukaran (Gram)', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            AppField(
              label: '',
              placeholder: '0.0',
              controller: _gramController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.darkGray, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Diterima', style: TextStyle(fontFamily: 'Poppins', color: AppColors.primaryLightGold, fontWeight: FontWeight.w700)),
                  Text(CurrencyFormatter.formatRupiah(totalPrice), style: const TextStyle(fontFamily: 'Roboto Mono', color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Tukar Sekarang',
              onPressed: (totalPrice > 0 && grams <= _currentBalance) ? _handleSell : null,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
