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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Center(
              child: FeatureIcon(icon: Icons.check_rounded, tone: 'green', size: 70, iconSize: 40),
            ),
            content: Text(
              'Penjualan ${grams.toStringAsFixed(3)} gr Emas Digital berhasil!\nDana telah ditransfer ke rekening Anda.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w500),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Jual Emas Digital', style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 17)),
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppColors.shadowSoft),
                    child: Column(
                      children: [
                        const Text('Harga Jual Saat Ini', style: TextStyle(color: AppColors.slate500, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${CurrencyFormatter.formatRupiah(_pricePerGram)} / gr', style: const TextStyle(color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppColors.shadowSoft),
                    child: Column(
                      children: [
                        const Text('Saldo Emas Anda', style: TextStyle(color: AppColors.slate500, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${_currentBalance.toStringAsFixed(3)} gr', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Jumlah Jual (Gram)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.slate600)),
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
              decoration: BoxDecoration(color: AppColors.greenSurface, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Diterima', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
                  Text(CurrencyFormatter.formatRupiah(totalPrice), style: const TextStyle(color: AppColors.green, fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Jual Sekarang',
              onPressed: (totalPrice > 0 && grams <= _currentBalance) ? _handleSell : null,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
