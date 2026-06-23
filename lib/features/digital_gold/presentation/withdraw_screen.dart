import 'package:flutter/material.dart';
import 'package:toko_emas_digital/core/constants/app_colors.dart';
import 'package:toko_emas_digital/core/utils/currency_formatter.dart';
import 'package:toko_emas_digital/common/widgets/app_button.dart';
import 'package:toko_emas_digital/common/widgets/app_field.dart';
import 'package:toko_emas_digital/common/widgets/feature_icon.dart';
import 'package:toko_emas_digital/features/digital_gold/services/transaction_service.dart';
import 'package:url_launcher/url_launcher.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _transactionService = TransactionService();
  
  double _currentRupiahBalance = 0.0;
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
        _currentRupiahBalance = balances['rupiah'] ?? 0.0;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleWithdraw() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan nominal yang valid')));
      return;
    }

    if (amount > _currentRupiahBalance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saldo tunai Anda tidak mencukupi')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _transactionService.withdrawCash(amount);
      
      if (success && mounted) {
        final Uri uri = Uri.parse('dompetkampus://topup?amount=$amount');
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Gagal membuka deeplink topup: $e');
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Center(
              child: FeatureIcon(icon: Icons.check_rounded, tone: 'green', size: 70, iconSize: 40),
            ),
            content: Text(
              'Penarikan Dana sebesar ${CurrencyFormatter.formatRupiah(amount)} berhasil!\nSistem mencoba mengalihkan ke aplikasi E-Money Anda.',
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
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tarik Dana', style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.greenSurface, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('Saldo Tunai Tersedia', style: TextStyle(color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(CurrencyFormatter.formatRupiah(_currentRupiahBalance), style: const TextStyle(color: AppColors.green, fontSize: 24, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Nominal Penarikan (Rp)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.slate600)),
            const SizedBox(height: 8),
            AppField(
              label: '',
              placeholder: 'Contoh: 500000',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            const Text('Penarikan dana akan diproses dan dikirimkan ke akun E-Money Dompet Nusantara Anda.', style: TextStyle(color: AppColors.slate500, fontSize: 12)),
            const SizedBox(height: 32),
            AppButton(
              label: 'Tarik Dana Sekarang',
              onPressed: (amount > 0 && amount <= _currentRupiahBalance) ? _handleWithdraw : null,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
